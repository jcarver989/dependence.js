class FileWatcher
  def initialize(glob_str, &block)
    @dir = glob_str 
    recreate_timetable
    poll(block)
  end

  private
  def poll(&block)
    while true
      if fs_modified?
        block.call
        recreate_timetable
      end
      sleep 3 
    end
  end

  def fs_modified?
    new_files = get_files
    return true if new_files.length != @files.length 
    new_timetable = create_file_modified_timetable(new_files)

    modified = false
    new_timetable.each do |filename,time|
      if time != @timetable[filename] 
        modified = true
        break
      end
    end
    modified
  end

  def get_files
    Dir.glob @dir
  end

  def recreate_timetable
    @files = get_files
    @timetable = create_file_modified_timetable(@files)
  end

  def create_file_modified_timetable(filenames)
    filenames.inject({}) do |table, filename|
      table[filename] = File.mtime(filename) if File.exists? filename
      table
    end
  end
end
