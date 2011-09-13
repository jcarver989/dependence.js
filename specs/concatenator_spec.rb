require 'dependence/concatenator'
require  File.join(File.dirname(__FILE__), 'spec_helper')

include Dependence

  describe Concatenator do
    describe "#concat_files" do
      it "should concatenate files" do
        write_test_files do |path, files|
          concat = Concatenator.new(files.sort())
          output = concat.concat_files
          output.should == "#{FILE_A}#{FILE_B}#{FILE_C}"
        end
      end

      it "should concatenate files with processing" do
        counter = 0
        write_test_files do |path, files|
          concat = Concatenator.new(files.sort())

          output = concat.concat_files do |file, content|
            counter += 1
            counter.to_s
          end

          output.should == "123" 
        end
      end
    end
  end
