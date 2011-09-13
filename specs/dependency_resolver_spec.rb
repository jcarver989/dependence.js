require 'dependence/dependency_resolver'
include Dependence
require 'tmpdir'
require  File.join(File.dirname(__FILE__), 'spec_helper')

describe DependencyResolver do
  describe "#sorted_files" do 
    it "should give back files in correct dependency order" do
      write_test_files() do |path, files|
        resolver = DependencyResolver.new(files, path)
        ordered_files = resolver.sorted_files.map {|file| File.basename(file) }
        ordered_files.should == ["file_c.js", "file_a.js", "file_b.js"]
      end
    end
  end
end
