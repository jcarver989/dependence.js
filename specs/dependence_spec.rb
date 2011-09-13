
require  File.join(File.dirname(__FILE__), 'spec_helper')

describe "Dependence" do

  def test_dependence(options, expected_output)
    write_test_files do |path, files|
      system "ruby bin/dependence #{path}/../ -o #{path}/../ #{options}"
      ext = options.include?("-c") ? ".min.js" : ".js"
      output = File.read("#{path}/../module#{ext}")
      output.should == expected_output 
    end
  end

  it "should not wrap with module code when -b" do
    test_dependence("-b", "#{FILE_C}#{FILE_A}#{FILE_B}")
  end

  it "should compress when -c" do
    test_dependence("-b -c", "function b(){alert(\"something\")};\n")
  end

  it "should have module by default" do
    test_dependence("", ModuleInjector.modularize("module", "#{FILE_C}#{FILE_A}#{FILE_B}"))
  end

end
