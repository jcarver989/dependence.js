require "dependence/colors"

class JsCompressor
  def initialize(source_file, output_file = nil)
    output_file = source_file.gsub(".js", ".min.js") unless output_file
    @source = source_file
    @output = output_file
  end

  def compress
    @cmd = cmd_prefix
    puts Colors.green("Compressing: #{@source}")
    puts Colors.red "Compressor Output:"
    execute_compile
  end

  private
  def execute_compile
    @cmd += " --js #{@source} --js_output_file #{@output}"
    `#{@cmd}`
    puts Colors.green("compressed #{@source} to #{@output}")
  end

  def cmd_prefix
    path = File.join(File.dirname(__FILE__), "../", "../", "compiler", "compiler.jar")
    "java -jar #{path} --output_wrapper '(function(){%output%})();'"
    # --create_source_map js_map
  end
end

