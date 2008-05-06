# Part of the Optimus package for managing E-Prime data
# 
# Copyright (C) 2008 Board of Regents of the University of Wisconsin System
# 
# Written by Nathan Vack <njvack@wisc.edu>, at the Waisman Laborotory for Brain
# Imaging and Behavior, University of Wisconsin - Madison

require File.join(File.dirname(__FILE__),'spec_helper')
require File.join(File.dirname(__FILE__), '../lib/eprime')
include EprimeTestHelper

describe Eprime::Reader::ExcelParser do
  
  # We don't need to do much here; the superclass handles almost everything
  
  before :each do
    @file = File.open(EXCEL_FILE, 'r')
    @reader = Eprime::Reader::ExcelParser.new(@file)
  end
  
  it "should read the sample excel file" do
    lambda {
      @reader.to_eprime
    }.should_not raise_error
  end
end