# -*- coding: UTF-8 -*-
#
# rspec spec/json2pdf/webapp_spec.rb

require 'spec_helper'

require 'atviz'

describe Atviz::Main do

  it ': webapp(common), STRIDE' do
    json_filename = 'examples/webapp_stride.json'
    pdf_filename  = 'examples/webapp_stride.pdf'

    atv = Atviz::Main.new
    atv.load_json(json_filename)
    atv.update
    atv.save_pdf(pdf_filename)
    File.exist?(pdf_filename).should eq true

    puts "evince #{pdf_filename}"
  end

  it ': webapp(common), ASF' do
    json_filename = 'examples/webapp_asf.json'
    pdf_filename  = 'examples/webapp_asf.pdf'

    atv = Atviz::Main.new
    atv.load_json(json_filename)
    atv.update
    atv.save_pdf(pdf_filename)
    File.exist?(pdf_filename).should eq true

    puts "evince #{pdf_filename}"
  end

  it ': webapp(rails) based on ASF' do
    json_filename = 'examples/webapp_asf_rails.json'
    pdf_filename  = 'examples/webapp_asf_rails.pdf'

    atv = Atviz::Main.new
    atv.load_json(json_filename)
    atv.update
    atv.save_pdf(pdf_filename)
    File.exist?(pdf_filename).should eq true

    puts "evince #{pdf_filename}"
  end

  it ': webapp(common), OWASP 2013' do
    json_filename = 'examples/webapp_owasp13.json'
    pdf_filename  = 'examples/webapp_owasp13.pdf'

    atv = Atviz::Main.new
    atv.load_json(json_filename)
    atv.update
    atv.save_pdf(pdf_filename)
    File.exist?(pdf_filename).should eq true

    puts "evince #{pdf_filename}"
  end

  it ': webapp(common), CWE/SANS 2011' do
    json_filename = 'examples/webapp_sans11.json'
    pdf_filename  = 'examples/webapp_sans11.pdf'

    atv = Atviz::Main.new
    atv.load_json(json_filename)
    atv.update
    atv.save_pdf(pdf_filename)
    File.exist?(pdf_filename).should eq true

    puts "evince #{pdf_filename}"
  end

end
