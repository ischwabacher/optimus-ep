# Part of the Optimus package for managing E-Prime data
# 
# Copyright (C) 2008-09 Board of Regents of the University of Wisconsin System
# 
# Written by Nathan Vack <njvack@wisc.edu>, at the Waisman Laborotory for Brain
# Imaging and Behavior, University of Wisconsin - Madison

require 'log_file_parser'
require 'excel_parser'
require 'eprimetab_parser'
require 'raw_tab_parser'

module Optimus
  
  # A class that should open any type of E-Prime text file and read it into
  # an E-Prime data structure.
  class Reader
    
    attr_reader :type, :parser, :input
    attr_accessor :options
    
    PARSERS = [LogfileParser, ExcelParser, OptimustabParser, RawTabParser]

    def initialize(input = nil, options = {})
      @options = options || {}
      set_input(input) unless input.nil?
    end
    
    def input=(input)
      set_input(input)
    end
    
    def optimus_data
      @optimus_data ||= @parser.to_optimus
      return @optimus_data
    end
    
    def options=(options)
      @options = options || {}
    end
    
    private
    def set_input(input)
      @input = input
      read_input!
    end
    
    # Reads the input, sets @type and @parser.
    def read_input!
      begin
        set_type(@input)
      rescue Exception => e
        raise UnknownTypeError.new(e.message)
      end
    end
    
    
    # Sets @type to one of Optimus::Reader::TYPES or raises an Optimus::UnknownTypeError
    # Does not change file position.
    def set_type(file)
      @file = file
      original_pos = @file.pos
      @file.rewind
      first_lines = Array.new
      # We can tell what kind of file this is from the first two lines
      # If there aren't two lines, this can't be a good file.
      2.times do
        first_lines << @file.gets
      end
      @file.pos = original_pos
      @type = determine_file_type(first_lines)
      if @type.nil?
        raise UnknownTypeError.new("Can't determine the type of #{file.path}")
      end
      @optimus_data = nil
      @parser = @type.new(@file, @options)
    end
    
    # Determines the type of an optimus file, based on its first two lines.
    # Returns one of the elements of PARSERS or nil
    def determine_file_type(first_lines)
      # Log files start with *** Header Start ***
      #
      # Excel files have a filename on the first line (no tabs); the second line
      # contains at least three elements, tab-delimted
      #
      # optimus CSV files will have at least three tab-delimited elements on the first line
      
      return PARSERS.detect { |parser_class| 
        parser_class.can_parse?(first_lines)
      }
    end
  end
end