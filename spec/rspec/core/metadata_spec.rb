require 'spec_helper'

module Rspec
  module Core
    describe Metadata do
      describe "#generated_name" do
        it "generates name for top level example group" do
          m = Metadata.new
          m.process("description", :caller => caller(0))
          m[:behaviour][:name].should == "description"
        end

        it "concats args to describe()" do
          m = Metadata.new
          m.process(String, "with dots", :caller => caller(0))
          m[:behaviour][:name].should == "String with dots"
        end

        it "concats nested names" do
          m = Metadata.new(:behaviour => {:name => 'parent'})
          m.process(String, "child", :caller => caller(0))
          m[:behaviour][:name].should == "parent child"
        end

        it "strips the name" do
          m = Metadata.new
          m.process("  description  \n", :caller => caller(0))
          m[:behaviour][:name].should == "description"
        end
      end

      describe "#determine_file_path" do
        it "finds the first spec file in the caller array" do
          m = Metadata.new
          m.process(:caller => [
            "foo",
            "#{__FILE__}:#{__LINE__}",
            "bar_spec.rb:23",
            "baz"
          ])
          m[:behaviour][:file_path].should == __FILE__
        end
      end

      describe "#determine_line_number" do
        it "finds the line number with the first spec file " do
          m = Metadata.new
          m.process(:caller => [
            "foo",
            "#{__FILE__}:#{__LINE__}",
            "bar_spec.rb:23",
            "baz"
          ])
          m[:behaviour][:line_number].should == __LINE__ - 4
        end
        it "uses the number after the first : for ruby 1.9" do
          m = Metadata.new
          m.process(:caller => [
            "foo",
            "#{__FILE__}:#{__LINE__}:999",
            "bar_spec.rb:23",
            "baz"
          ])
          m[:behaviour][:line_number].should == __LINE__ - 4
        end
      end

      describe "#metadata_for_example" do
        let(:caller_to_use)      { caller(0) }
        let(:caller_line_number) { __LINE__ - 1 }
        let(:metadata)           { Metadata.new.process(:caller => caller_to_use) }
        let(:mfe)                { metadata.for_example("this description", {:caller => caller_to_use, :arbitrary => :options}) }

        it "stores the description" do
          mfe[:description].should == "this description"
        end

        it "creates an empty execution result" do
          mfe[:execution_result].should == {}
        end

        it "stores the caller" do
          mfe[:caller].should == caller_to_use
        end

        it "extracts file path from caller" do
          mfe[:file_path].should == __FILE__ 
        end

        it "extracts line number from caller" do
          mfe[:line_number].should == caller_line_number 
        end

        it "merges arbitrary options" do
          mfe[:arbitrary].should == :options 
        end

      end
    end
  end
end
