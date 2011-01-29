require File.join(File.dirname(__FILE__),'dependency_resolver')
require File.join(File.dirname(__FILE__),'colors')

class JsCompiler
  def initialize(source_path) 
    @source_path = source_path
  end

  def compile(output_file)
    @cmd = cmd_prefix
    @source_files = get_source_files 
    dep_resolver = DependencyResolver.new(@source_files,@source_path)
    file_order = dep_resolver.sorted_files
    puts "#{Colors.green('Source Files')}: #{file_order.to_s}"
    puts ""
    puts Colors.red "Compiler Output:"
    file_order.each {|source_file| add_file source_file }
    execute_compile(output_file)
  end

  private
  def	add_file(filename)
    @cmd += " --js=#{filename}"
  end

  def get_source_files
    Dir.glob File.join(@source_path,"/**/*.js")
  end

  def execute_compile(output_file)
    @cmd += " --js_output_file #{output_file}"
    `#{@cmd}`
    puts Colors.green("compilted #{@source_files.size} javascript files into #{output_file}")
    puts "------------------------------------------------------"
  end

  def cmd_prefix
    "java -jar compiler/compiler.jar" 
    # --create_source_map js_map
  end
end

