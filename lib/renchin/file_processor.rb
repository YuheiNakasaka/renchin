require 'fileutils'
module Renchin
  module FileProcessor
    # create temporary directory for frame images
    def image_directory(method_name)
      timestamp_image_dir = "/tmp/renchin_#{method_name}_#{Time.now.to_i}"
      Dir::mkdir(timestamp_image_dir,0777)
      timestamp_image_dir
    end

    # delete all files in directory
    def delete_directory(image_directory_path,expr)
      if exists?(image_directory_path)
        Dir::foreach(image_directory_path) do |file|
          File.delete(image_directory_path + '/' + file) if (/#{expr}$/ =~ file)
        end
        Dir::rmdir(image_directory_path)
      end
    end

    def exists?(filename)
      File.exist?(filename)
    end

    def init_file(filename)
      unless File.exist?(filename)
        dir = File.dirname(filename)
        unless File.exist?(dir)
          FileUtils.mkdir_p(dir)
        end
      end
      true
    end

  end
end