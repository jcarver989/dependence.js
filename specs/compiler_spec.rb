require 'dependence/compiler'
include Dependence

describe Compiler do
  def should_have_compiler_for_extension(ext, klass)
    compiler = Compiler.get_compiler_for(ext)
    compiler.should == klass
  end

  # For testing new compilers get registered
  class FooCompiler < Compiler
    @@extensions = [:foo]

    def self.extensions 
      @@extensions
    end
  end

  describe "#supported_extensions" do
    it "returns the correct extensions" do
      Compiler.supported_extensions.should == [".cs", ".coffee", ".js", ".foo"]
    end
  end

  describe "#get_compiler_for" do
    it "should be a CoffeeScript compiler for .cs" do
      should_have_compiler_for_extension ".cs", CoffeeScriptCompiler
    end

    it "should be a CoffeeScript compiler for .coffee" do
      should_have_compiler_for_extension ".coffee", CoffeeScriptCompiler
    end

    it "should be a Javascript compiler for .js" do
      should_have_compiler_for_extension ".js", JavaScriptCompiler
    end

    it "should have added the FooCompiler for .foo" do
      should_have_compiler_for_extension ".foo", FooCompiler
    end
  end
end


describe CoffeeScriptCompiler do
  describe "#compile" do
    it "should compile a simple coffee function" do
      result = CoffeeScriptCompiler.compile("x = () -> alert('hi')")
      result.should == "var x;\nx = function() {\n  return alert('hi');\n};"
    end
  end
end


describe JavaScriptCompiler do
  describe "#compile" do
    it "should compile a simple js function" do 
      result = JavaScriptCompiler.compile("var x;\nx = function() {\n  return alert('hi');\n};")
      result.should == "var x;\nx = function() {\n  return alert('hi');\n};"
    end
  end
end
