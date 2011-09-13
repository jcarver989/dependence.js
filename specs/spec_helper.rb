  FILE_A = <<-FILE_A
      // @import file_c.js
  FILE_A

  FILE_B = <<-FILE_B
      // @import file_a.js

      function b() { alert('something'); }
  FILE_B

  FILE_C = <<-FILE_C
      // no imports
      // file c
  FILE_C

  TEST_FILES = [
    ["file_a.js", FILE_A],
    ["file_b.js", FILE_B],
    ["file_c.js", FILE_C],
  ]

  def write_test_files(&block)
    dir = "module"
    Dir.mktmpdir do |path|
      module_path = File.join(path, dir)
      Dir.mkdir(module_path)

      TEST_FILES.each do |array|
        name, content = array
        output = File.join(module_path, name)
        File.open(output, 'w') { |f| f.syswrite content }
      end

      files = Dir.glob(module_path + "/**/*.js")
      block.call(module_path, files)
    end
  end
