# Part of the Optimus package for managing E-Prime data
# 
# Copyright (C) 2008 Board of Regents of the University of Wisconsin System
# 
# Written by Nathan Vack <njvack@wisc.edu>, at the Waisman Laborotory for Brain
# Imaging and Behavior, University of Wisconsin - Madison

# Add our lib to the search path
$: << File.expand_path(File.join(File.dirname(__FILE__), "..", "lib"))

require 'eprime_data'
require 'version'
require 'tabfile_writer'
require 'eprime_reader'

module Eprime

  # Raised whenever an input file's type can't be detemined by Eprime::Reader
  class UnknownTypeError < Exception; end
  
  # Raised whenever an input file seems to be damaged
  class DamagedFileError < Exception; end
  
end