module Dependence
  class Concatenator
    def initialize(file_list)
      @files = file_list
    end

    def concat_files(&block)
      content = ""

      @files.each do |f|
        file_content = File.read(f)
        # processing
        file_content = block.call(f, file_content) if block

        content << file_content
      end
      content
    end
  end
end
