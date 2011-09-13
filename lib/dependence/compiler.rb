module Dependence
  class Compiler
    class << self
      @@compilers ||= []

      def inherited(compiler)
        @@compilers << compiler
      end

      def get_compiler_for(extension)
        extension.gsub!(/^\./, "")
        @@compilers.find do |compiler|
          compiler.extensions.include?(extension.to_sym)
        end
      end

      def supported_extensions
        @@compilers.map { |c| c.extensions }.flatten.map {|e| ".#{e.to_s}" }
      end

      def compile(*args)
        self.new.compile(*args)
      end
    end

    def compile
      raise "abstract method"
    end
  end

  class CoffeeScriptCompiler < Compiler
    @@extensions = [:cs, :coffee]

    def self.extensions
      @@extensions
    end

    def compile(source_string, options = {})
      CoffeeScript.compile(source_string, options)
    end
  end

  class JavaScriptCompiler < Compiler
    @@extensions = [:js]

    def self.extensions
      @@extensions
    end

    def compile(source_string, options = {})
      source_string
    end
  end
end 
