require 'dependence/js_module'
require  File.join(File.dirname(__FILE__), 'spec_helper')

describe JsModule do
  def write_module(path, compress, bare)
    JsModule.new( :source_dir => path,
                 :output_dir => path,
                 :source_type => "**/*.js",
                 :compress => compress,
                 :bare => bare).to_file
  end

  describe "#to_file" do
    it "should output file bare and uncompressed" do
      write_test_files do |path, files|
        write_module(path, false, true)
        module_file = File.join(path, File.basename(path))
        output = File.read("#{module_file}.js")
        output.should == "#{FILE_C}#{FILE_A}#{FILE_B}"
      end
    end


    it "should output file wrapped in module closure" do
      write_test_files do |path, files|
        write_module(path, false, false)
        module_file = File.join(path, File.basename(path))
        output = File.read("#{module_file}.js")
        output.should == ModuleInjector.modularize(File.basename(path), "#{FILE_C}#{FILE_A}#{FILE_B}")
      end
    end


    it "should output compressed file" do
      write_test_files do |path, files|
        write_module(path, true, true)
        module_file = File.join(path, File.basename(path))
        output = File.read("#{module_file}.min.js")
        output.should == "function b(){alert(\"something\")};\n"
      end
    end
  end
end
