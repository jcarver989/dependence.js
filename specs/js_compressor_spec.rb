require 'dependence/js_compressor' 
require  File.join(File.dirname(__FILE__), 'spec_helper')

describe JsCompressor do
  describe "#compress" do
    it "should compress a file" do 
      write_test_files do |path, files|
        file = files[1] # FILE_B from spec_helper
        JsCompressor.new(file).compress
        compressed_file = File.read(file.gsub(".js", ".min.js"))
        compressed_file.should == "function b(){alert(\"something\")};\n"
      end
    end
  end
end
