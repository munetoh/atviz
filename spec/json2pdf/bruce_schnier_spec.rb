# -*- coding: UTF-8 -*-
#
# rspec spec/json2pdf/bruce_schnier_spec.rb

require 'spec_helper'

require 'atviz'

describe Atviz::Main do

  it ': figure 1' do
    json_filename = 'examples/bruce_schnier_fig1.json'
    pdf_filename  = 'examples/bruce_schnier_fig1.pdf'
    atv = Atviz::Main.new
    atv.load_json(json_filename)
    atv.save_pdf(pdf_filename)
    File.exist?(pdf_filename).should eq true
    puts "evince #{pdf_filename}"
  end

  it ': figure 2' do
    json_filename = 'examples/bruce_schnier_fig2.json'
    pdf_filename  = 'examples/bruce_schnier_fig2.pdf'
    atv = Atviz::Main.new
    atv.load_json(json_filename)
    atv.update
    atv.save_pdf(pdf_filename)
    File.exist?(pdf_filename).should eq true
    puts "evince #{pdf_filename}"
  end

  it ': figure 3' do
    json_filename = 'examples/bruce_schnier_fig3.json'
    pdf_filename  = 'examples/bruce_schnier_fig3.pdf'
    atv = Atviz::Main.new
    atv.load_json(json_filename)
    atv.update
    atv.save_pdf(pdf_filename)
    File.exist?(pdf_filename).should eq true
    puts "evince #{pdf_filename}"
  end

  it ': figure 4' do
    json_filename = 'examples/bruce_schnier_fig4.json'
    pdf_filename  = 'examples/bruce_schnier_fig4.pdf'
    atv = Atviz::Main.new
    atv.load_json(json_filename)
    atv.update
    atv.save_pdf(pdf_filename)
    File.exist?(pdf_filename).should eq true
    puts "evince #{pdf_filename}"
  end

  it ': figure 5' do
    json_filename = 'examples/bruce_schnier_fig5.json'
    pdf_filename  = 'examples/bruce_schnier_fig5.pdf'
    atv = Atviz::Main.new
    atv.load_json(json_filename)
    atv.update
    atv.save_pdf(pdf_filename)
    File.exist?(pdf_filename).should eq true
    puts "evince #{pdf_filename}"
  end

  it ': figure 6' do
    json_filename = 'examples/bruce_schnier_fig6.json'
    pdf_filename  = 'examples/bruce_schnier_fig6.pdf'
    atv = Atviz::Main.new
    atv.load_json(json_filename)
    atv.update
    atv.save_pdf(pdf_filename)
    File.exist?(pdf_filename).should eq true
    puts "evince #{pdf_filename}"
  end

  it ': figure 7' do
    json_filename = 'examples/bruce_schnier_fig7.json'
    pdf_filename  = 'examples/bruce_schnier_fig7.pdf'
    atv = Atviz::Main.new
    atv.load_json(json_filename)
    atv.update
    atv.save_pdf(pdf_filename)
    File.exist?(pdf_filename).should eq true
    puts "evince #{pdf_filename}"
  end

  it ': figure 8' do
    json_filename = 'examples/bruce_schnier_fig8.json'
    pdf_filename  = 'examples/bruce_schnier_fig8.pdf'
    atv = Atviz::Main.new
    atv.load_json(json_filename)
    atv.update
    atv.save_pdf(pdf_filename)
    File.exist?(pdf_filename).should eq true
    puts "evince #{pdf_filename}"
  end
end
