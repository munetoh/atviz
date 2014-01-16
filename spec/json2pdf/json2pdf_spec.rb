# -*- coding: UTF-8 -*-
#
# rspec spec/json2pdf/json2pdf_spec.rb

require 'spec_helper'

require 'atviz'

describe Atviz::Main do

  atv = nil

  it ': load example JSON' do
    json_filename = 'examples/tree_sample.json'
    atv = Atviz::Main.new
    atv.load_json(json_filename)

    atv.json['tree']['T0001']['type'].should eq 'threat'
  end

  it ': save example pdf' do
    pdf_filename = 'examples/tree_sample.pdf'
    atv.save_pdf(pdf_filename)

    # File?
    File.exist?(pdf_filename).should eq true
    puts "evince #{pdf_filename}"
  end
end
