require 'fileutils'
require "dependence/colors"

module Dependence
  # Take a load path + file glob and concat them into 1 file per directory
  class Concatenator
    @@defaults = {
      :load_path    => ".",
      :source_type  => "**/*.js"
    }

    def initialize(opts = {})
      @options = @@defaults.merge(opts)
    end

    def concat(&block)
      get_dirs.each { |dir| concat_module(dir, &block) }
    end

    private

    def concat_module(dir, &block)
      module_name = File.basename(dir)

      files = Dir.glob File.join(dir, @options[:source_type])
      no_files_error if files.empty?

      files_list = get_files_in_dependency_order(dir, files)

      block.call module_name, concat_files(files_list)
    end

    def no_files_error
      puts Colors.red("No files of the specified type #{File.extname(@options[:source_type])} were found in #{@options[:load_path]}")
      throw :no_files_to_concatenate
    end

    def get_files_in_dependency_order(dir, files)
      resolver = DependencyResolver.new(files, dir)
      resolver.sorted_files
    end

    def concat_files(file_list)
      content = ""
      file_list.each { |f| content << File.read(f); content << "\n" }
      content
    end

    # Top level dirs only
    def get_dirs
      Dir.glob("#{@options[:load_path]}/*/**/")
    end

  end
end
