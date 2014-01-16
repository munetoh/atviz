# -*- coding: UTF-8 -*-
#
# mode
#  simple tree
#  consolidate same sinks
#

require 'json'
require 'ruby-graphviz'

module Atviz
  # main class
  class Main
    def initialize
      @json = nil
      @gv = nil
      @node_list = {}
      @default_shape = nil
      @operations = nil
      @json_tree_type = nil
      @cost_currency = '$'
      @cost_unit = 'K'
      @cost_threshold = 0
      @rankdir = 'TB'
    end
    attr_accessor :json

    def load_json(filename)
      open(filename) do |f|
        @json = JSON.load(f)
      end

      if @json['include'].nil?
        if !@json['tree'].nil?
          @json_tree_type = 'tree'
          @json_tree = @json['tree']
        elsif !@json['flat_tree'].nil?
          @json_tree_type = 'flat_tree'
          @json_tree = @json['flat_tree']
        end
      else
        # Include
        include_filename = File.dirname(filename) + '/' + @json['include']
        puts "include #{include_filename}"
        include_json(include_filename)
        if !@json['flat_tree'].nil?
          @json_tree.merge!(@json['flat_tree'])
        else
          puts 'ERROR: flat_tree only'
        end
      end

      unless @json['cost'].nil?
        @cost_currency  = @json['cost']['currency'] unless @json['cost']['currency'].nil?
        @cost_unit      = @json['cost']['unit'] unless @json['cost']['unit'].nil?
        @cost_threshold = @json['cost']['threshold'] unless @json['cost']['threshold'].nil?
      end

      @rankdir = @json['rankdir'] unless @json['rankdir'].nil?
    end

    # include flat_tree
    def include_json(filename)
      json2 = nil
      open(filename) do |f|
        json2 = JSON.load(f)
      end
      if !json2['flat_tree'].nil?
        @json_tree_type = 'flat_tree'
        @json_tree = json2['flat_tree']
      else
        puts 'ERROR: include must be a flat_tree'
        exit
      end
    end

    # print
    def print_json
      puts JSON.pretty_generate(@json)
    end

    # Update tree
    def update
      @operations = json['operations']

      unless  @operations.nil?
        trace_possibility if @operations['trace possibility']
        trace_cost if @operations['trace cost']
        trace_cost_and_equipment  if @operations['trace cost and equipment']
      end
    end

    # Flat tree -> Tree
    # assumptions:
    #
    def gen_tree
      new_tree = {}
      node_list = {}
      @json_tree.each do |k, v|
        if v['child_of'].nil?
          # top
          new_tree[k] = v
          node_list[k] = new_tree[k]
        else
          parent = v['child_of']
          if v['condition'] == 'and'
            node_list[parent]['and'] ||= {}
            node_list[parent]['and'][k] = v
            node_list[k] = node_list[parent]['and'][k]
          elsif v['condition'] == 'or'
            node_list[parent]['or'] ||= {}
            node_list[parent]['or'][k] = v
            node_list[k] = node_list[parent]['or'][k]
          else
            # TODO: sink?
            node_list[parent]['or'] ||= {}
            node_list[parent]['or'][k] = v
            node_list[k] = node_list[parent]['or'][k]
          end
        end
      end

      @json_tree_type = 'tree'
      @json_tree = new_tree
    end

    # Flat hash -> tree
    # bottom up?
    # update
    # AND
    # OR
    def trace_possibility
      gen_tree if @json_tree_type == 'flat_tree'

      @json_tree.each do |k, v|
        v['possibility'] = trace_possibility2(v)
      end
    end

    def trace_possibility2(node)
      if !node['or'].nil?
        # OR
        node['or'].each do |k, v|
          if trace_possibility2(v) == 'possible'
            node['possibility'] = 'possible'
            return node['possibility']
          end
        end
      elsif !node['and'].nil?
        # AND
        node['and'].each do |k, v|
          if trace_possibility2(v) == 'impossible'
            node['possibility'] = 'impossible'
            return node['possibility']
          end
          if trace_possibility2(v) == 'unknown'
            node['possibility'] = 'unknown'
            return node['possibility']
          end
        end

        node['possibility'] = 'possible'
        return node['possibility']
      else
        if node['possibility'].nil?
          node['possibility'] = 'unknown'
          return node['possibility']
        else
          return node['possibility']
        end
      end
    end

    # Cost
    #   AND +
    #   OR min
    # Equipment
    #  SE AND SE   => SE
    #  SE AND NSE  => SE
    #  NSE AMD NSE = NSE
    #
    #  SE OR SE => SE
    #  SE OR NSE => SE
    #  SE OR SE => SE
    def trace_cost
      gen_tree if @json_tree_type == 'flat_tree'

      @json_tree.each do |k, v|
        v['cost'] = trace_cost2(v)
      end
    end

    def trace_cost2(node)
      if !node['or'].nil?
        # OR
        min_cost = nil
        max_cost = nil
        node['or'].each do |k, v|
          cost =  trace_cost2(v)
          # First
          min_cost ||= cost
          max_cost ||= cost

          # Update
          min_cost = cost if cost < min_cost
          max_cost = cost if cost > max_cost
        end
        node['cost'] = min_cost
        return min_cost
      elsif !node['and'].nil?
        # AND
        cost = 0
        node['and'].each do |k, v|
          cost += trace_cost2(v)
        end
        node['cost'] = cost
        return cost
      else
        if node['cost'].nil?
          node['cost'] = 0
          return node['cost']
        else
          return node['cost']
        end
      end
    end

    # Cost w/ Equipment
    #
    # Cost
    #   AND +
    #   OR min
    # Equipment
    #  SE AND SE   => SE
    #  SE AND NSE  => SE
    #  NSE AMD NSE = NSE
    #
    #  OR use E of selected child
    def trace_cost_and_equipment
      gen_tree if @json_tree_type == 'flat_tree'

      @json_tree.each do |k, v|
        v['cost'], v['equipment'] = trace_cost_and_equipment2(v)
      end
    end

    def trace_cost_and_equipment2(node)
      equipment = 'TBD'
      if !node['or'].nil?
        # OR
        # step 1 check NSE and cheap one
        # step 2 check cheap one
        # step 1
        min_cost = nil
        max_cost = nil
        equipment = nil
        node['or'].each do |k, v|
          c, e =  trace_cost_and_equipment2(v)
          if e == 'NSE'
            # First
            min_cost  ||= c
            max_cost  ||= c
            equipment ||= e
            # Update
            if c < min_cost
              min_cost = c
              equipment = e
            end
            max_cost = c if c > max_cost
          end
        end
        unless equipment.nil?
          # HIT
          node['cost'] = min_cost
          node['equipment'] = equipment
          return min_cost, equipment
        end

        # step 2
        min_cost = nil
        max_cost = nil
        equipment = nil
        node['or'].each do |k, v|
          cost, e =  trace_cost_and_equipment2(v)
          # First
          min_cost  ||= cost
          max_cost  ||= cost
          equipment ||= e
          # Update
          if cost < min_cost
            min_cost = cost
            equipment = e
          end
          max_cost = cost if cost > max_cost
        end

        node['cost'] = min_cost
        node['equipment'] = equipment
        return min_cost, equipment
      elsif !node['and'].nil?
        # AND
        cost = 0
        equipment = 'NSE'
        node['and'].each do |k, v|
          c, e = trace_cost_and_equipment2(v)
          cost += c
          equipment = 'SE' if e == 'SE'
        end

        node['cost'] = cost
        node['equipment'] = equipment
        return cost, equipment
      else
        # Sink?
        if node['cost'].nil?
          node['cost'] = 0
          return node['cost'], node['equipment']
        else
          return node['cost'], node['equipment']
        end
      end
    end

    # --------------------------------------------------------------------------
    # JSON to GV
    def json2gv
      @default_shape = json['default_shape']

      if @json_tree_type == 'tree'
        jsontree2gv(@json_tree)
      elsif @json_tree_type == 'flat_tree'
        jsonflattree2gv(@json_tree)
      end
    end

    # common defs
    def get_label(k, v)
      label = k
      label += "\n" + v['description'] unless v['description'].nil?
      label += "\n" + v['possibility'] unless v['possibility'].nil?
      label += "\n" + v['equipment'] unless v['equipment'].nil?
      label += "\n#{@cost_currency}#{ v['cost']}#{@cost_unit}" unless v['cost'].nil?
      return label
    end

    def get_penwidth(k, v)
      width = 1
      width += 1 if !v['cost'].nil? && (v['cost'] < @cost_threshold)
      width += 1 if !v['equipment'].nil? && (v['equipment'] == 'NSE')
      return width
    end

    def get_shape(children_type)
      if !@default_shape.nil?
        @default_shape
      elsif children_type == 'and'
        'ellipse'
      elsif children_type == 'or'
        'diamond'
      elsif children_type == 'child'
        'ellipse'
      elsif children_type == 'sink'
        'house'
      elsif children_type == 'top'
        'invhouse'
      end
    end

    # URL or href are not work with pdf??
    # https://github.com/glejeune/Ruby-Graphviz/issues/8
    def add_node(k, v, children_type)
      label    = get_label(k, v)
      penwidth = get_penwidth(k, v)
      shape    = get_shape(children_type)

      href = v['url']
      if href.nil?
        @gv.add_nodes(label, shape: shape, penwidth: penwidth)
      else
        # puts "url #{href}"
        @gv.add_nodes(label, shape: shape, penwidth: penwidth, URL: href)
      end
    end

    def add_edge(k, v, children_type, parent, child)
      label = nil
      penwidth = get_penwidth(k, v)

      if children_type == 'and'
        label = 'and'
      elsif children_type == 'or'
        label = 'or'
      end

      if label.nil?
        @gv.add_edges(parent, child, penwidth: penwidth)
      else
        @gv.add_edges(parent, child, label: label, penwidth: penwidth)
      end
    end

    # --------------------------------------------------------------------------
    # Tree => Grahviz
    def jsontree2gv(tree)
      @gv = GraphViz.new(:G, type: :digraph, rankdir: @rankdir)

      # Top -> Sink
      tree.each do |k0, v0|
        children = nil
        description = nil
        children_type = nil

        v0.each do |k1, v1|
          if k1 == 'description'
            description = v1
          elsif k1 == 'or' || k1 == 'and' || k1 == 'child'
            children = v1
            children_type = k1
          end
        end

        p = add_node(k0, v0, 'top')
        add_children(p, children, children_type) unless children.nil?
      end

      # TODO: consolidate common sink
      # groupe sink
    end

    def add_children(parent, children, children_type)
      children.each do |k0, v0|
        children2 = nil
        children2_type = nil
        type = nil
        description = nil

        v0.each do |k1, v1|
          if k1 == 'type'
            type == v1
          elsif k1 == 'description'
            description = v1
          elsif k1 == 'or' || k1 == 'and' || k1 == 'child' || k1 == 'sink'
            children2 = v1
            children2_type = k1
          end
        end

        p = add_node(k0, v0, children_type)
        add_edge(k0, v0, children_type, parent, p)
        add_children(p, children2, children2_type) unless children2.nil?
      end
    end

    # --------------------------------------------------------------------------
    # Flat hash list => Tree => Graphviz
    def jsonflattree2gv(hash)
      @gv = GraphViz.new(:G, type: :digraph, rankdir: @rankdir)

      # pass 1 => node
      hash.each do |k, v|
        children_type = v['condition']
        children_type ||= 'or'
        @node_list[k] = add_node(k, v, children_type)
      end

      # pass 2 => edge
      hash.each do |k, v|
        children_type = v['condition']
        children_type ||= 'or'
        parent = v['child_of']
        add_edge(k, v, children_type, @node_list[parent], @node_list[k]) unless @node_list[parent].nil?
      end
    end

    # --------------------------------------------------------------------------
    def save_pdf(filename)
      json2gv
      @gv.output(pdf: filename)
    end

    def save_png
    end

    def save_eps
    end
  end
end
