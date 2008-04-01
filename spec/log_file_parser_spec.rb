# Part of the Optimus package for managing E-Prime data
# 
# Copyright (C) 2008 Board of Regents of the University of Wisconsin System
# 
# Written by Nathan Vack <njvack@wisc.edu>, at the Waisman Laborotory for Brain
# Imaging and Behavior, University of Wisconsin - Madison

require File.join(File.dirname(__FILE__),'spec_helper')
require File.join(File.dirname(__FILE__), '../lib/eprime')
include EprimeTestHelper

LOG_COLUMNS = ["ExperimentName", "Subject", "Session", "RFP.StartTime", "BlockTitle", "PeriodA", "CarriedVal[Session]", "BlockList", "Trial", 
"NameOfPeriodList", "NumPeriods", "PeriodB", "Procedure[Block]", "Block", "Group", 
"CarriedVal[Block]", "BlockList.Sample", "SessionTime", "Clock.Scale", "BlockList.Cycle", 
"Stim1.OnsetTime", "CarriedVal[Trial]", "Display.RefreshRate", "Running[Block]", 
"StartDelay", "CarriedVal", "Stim1.OffsetTime", "Running[Trial]", "ScanStartTime", 
"Periods", "TypeA", "BlockElapsed", "RFP.LastPulseTime", "BlockTime", "Procedure[Trial]", 
"SessionDate", "TypeB", "Procedure", "StartTime", "RandomSeed", "Running"]

describe Eprime::Reader::LogFileParser do
  describe "parsing a good file" do
    before :each do
      @file = File.open(LOG_FILE, 'r')
      @reader = Eprime::Reader::LogFileParser.new(@file)
      @reader.make_frames!
    end
  
    it "should create six frames from the example file" do
      @reader.frames.size.should == 6
    end
  
    it "should have data in every frame" do
      @reader.frames.detect{ |c| c.keys.size == 0}.should be_nil
    end
  
    it "should have a level 3 frame at the start" do
      @reader.frames.first.level.should == 3
    end
  
    it "should have a level 1 frame at the end" do
      @reader.frames.last.level.should == 1
    end
  
    it "should have a known TypeA key in first frame" do
      @reader.frames.first["TypeA"].should_not be_nil
    end
  
    it "should not have a known Gibberish key in first frame" do
      @reader.frames.first["Gibberish"].should be_nil
    end
  
    it "should have a known RandomSeed key in last frame" do
      @reader.frames.last["RandomSeed"].should_not be_nil
    end
  
    it "should not have a known StartR.OnsetTime key in last frame" do
      @reader.frames.last["StartR.OnsetTime"].should be_nil
    end
    
    it "should read levels from the header" do
      @reader.levels.should include("Session")
    end
    
    it "should find a top_level of 3" do
      @reader.top_level.should == 3
    end
    
    it "should have three top frames" do
      @reader.top_frames.length.should == 3
    end
  
    it "should have a parent in the first frame" do
      @reader.frames.first.parent.should_not be_nil
    end
  
    describe "making eprime data" do
      before :each do
        @eprime = @reader.to_eprime
      end
    
      it "should generate three rows from the example file" do
        @eprime.length.should == 3
      end
      
      it "should ignore extra colons in input data" do
        @eprime.first['SessionTime'].should == '11:11:11'
      end
    
      it "should append level name to ambiguous columns" do
        @eprime.columns.should include("CarriedVal[Session]")
      end
      
      it "should not include ambiguous columns without level name" do
        @eprime.columns.should_not include("CarriedVal")
      end
      
      it "should mark ambiguous columns for skip" do
        @reader.skip_columns.should include("CarriedVal")
      end
    
      it "should include columns from level 2 and level 1 frames" do
        @eprime.columns.should include("RandomSeed")
        @eprime.columns.should include("BlockTitle")
      end
      
      it "should rename Experiment to ExperimentName" do
        @eprime.columns.should include("ExperimentName")
        @eprime.columns.should_not include("Experiment")
      end
    
      it "should compute task counters" do
        @eprime.first["Block"].should == 1
        @eprime.last["Block"].should == 2
        @eprime.last["Trial"].should == 2
      end
    
      it "should have a counter column" do
        @eprime.columns.should include("Trial")
      end
    end
  end
  
  describe "with sorted columns" do
    before :each do
      @file = File.open(LOG_FILE, 'r')
      @reader = Eprime::Reader::LogFileParser.new(@file, :columns => LOG_COLUMNS)
      @reader.make_frames!
      @eprime = @reader.to_eprime
    end
    
    after :each do
      @file.close
    end
    
    it "should have ExperimentName first" do
      @eprime.columns.first.should == "ExperimentName"
    end
    
    it "should have three rows" do
      @eprime.length.should == 3
    end
    
    
  end
  
  describe "parsing bad files" do
    before :each do
      @file = File.open(CORRUPT_LOG_FILE, 'r')
      @reader = Eprime::Reader::LogFileParser.new(@file)
    end
    after :each do
      @file.close
    end
    
    it "should throw an error when the last frame is not closed" do
      lambda {@reader.make_frames!}.
        should raise_error(Eprime::DamagedFileError)
    end
    
  end
  
end