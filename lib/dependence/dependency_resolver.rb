require 'rgl/adjacency'
require 'rgl/topsort'

class DependencyResolver
  def initialize(file_list, file_path)
    @files = file_list
    @file_path = file_path
    @graph = RGL::DirectedAdjacencyGraph.new
  end

  def sorted_files
    @files.each do |file|
      @graph.add_vertex(file)
      dependencies = get_dependencies_in(file)
      dependencies.each {|dependency| @graph.add_edge(dependency,file) }
    end
    @graph.topsort_iterator.to_a
  end

  private
  def get_dependencies_in(file)
    dependencies = []

    File.foreach(file) do |s|
      if s.include?("@import")
        file_name = s.match(/@import (.*)/)[1].strip
        dependencies << File.join(@file_path, file_name) 
      end
    end 
    return dependencies
  end
end

