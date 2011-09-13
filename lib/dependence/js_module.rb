require 'dependence/js_compressor'
require 'dependence/module_injector'

module Dependence
  class JsModule
    attr_reader :name 

    def initialize(config)
      raise "need to pass :source_dir to constructor" unless config[:source_dir]
      raise "need to pass :source_type to constructor" unless config[:source_type]

      @config = config
      @name = File.basename(config[:source_dir])
      @output_file = File.join(@config[:output_dir], "#{@name}.js")

      @file_list = get_file_list_for_module(@config[:source_dir], @config[:source_type])
      @concat = Concatenator.new(@file_list)
    end


    def to_file
      File.open(@output_file, 'w') do |f|
        f.syswrite build()
      end

      JsCompressor.new(@output_file).compress if @config[:compress] == true
      stdout_compile_complete_msg(@name, @output_file)
    end

    private

    def build
      stdout_compile_msg(@name)
      output = @concat.concat_files do |file_path, file_contents|
        extension = File.extname(file_path) 
        compile(extension, file_contents)
      end

      output = ModuleInjector.modularize(@name, output) unless @config[:bare] == true
      output
    end

    def compile(extension, source)
      Compiler.get_compiler_for(extension).new.compile(source)
    end

    def get_file_list_for_module(dir, source_type)
      files = Dir.glob File.join(dir, source_type)
      no_files_error(dir) if files.empty?
      DependencyResolver.new(files, dir).sorted_files
    end

    def no_files_error(dir)
      puts Colors.red("No source files were found in #{dir}")
      throw :no_files_to_concatenate
    end


    def stdout_compile_msg(module_name)
      puts Colors.green("Compiling Module: #{module_name}")
    end

    def stdout_compile_complete_msg(module_name, output)
      puts Colors.green("Compiled #{module_name} to #{output}")
    end
  end
end
