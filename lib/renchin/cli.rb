require "renchin"
require "thor"

module Renchin
  class CLI < Thor
    desc "tlapse -i MOVIE_FILE -o OUTPUT_FILE_NAME", "Generate a timelapse movie"
    method_option :input, aliases: "-i", desc: "Input movie file path"
    method_option :output, aliases: "-o", desc: "Output result file name"
    method_option :output_fps, aliases: "-ofps", desc: "Set output movie fps"
    method_option :img_ext, aliases: "-iex", desc: "frame image extension"

    def tlapse
      movie_file = options[:input]
      result_file = options[:output]
      output_fps = options[:output_fps] || '30'
      ext = options[:img_ext] || "png"

      timestamp_image_dir = "/tmp/renchin_#{Time.now.to_i}"
      Dir::mkdir(timestamp_image_dir,0777)

      # Split a movie to png images.
      system("ffmpeg -i #{movie_file} -f image2 #{timestamp_image_dir}/%7d.#{ext}")
      Dir.chdir("#{timestamp_image_dir}")
      frame_count = Dir.glob("*\.#{ext}").count
      playback_time = frame_count > 10 ? frame_count / 10 : 1

      # Generate timelapse movie from frame images.
      system("ffmpeg -f image2 -r #{playback_time} -i #{timestamp_image_dir}/%7d.#{ext} -r #{output_fps} -an -vcodec libx264 -pix_fmt yuv420p #{result_file}")

      # delete all files in directory
      Dir::foreach(timestamp_image_dir) do |file|
        File.delete(timestamp_image_dir + '/' + file) if (/\.#{ext}$/ =~ file)
      end
      Dir::rmdir(timestamp_image_dir)
      say("Renchin generated timelapse! ~> #{result_file}", :green)
    end


    desc "sprite -i MOVIE_FILE -o IMAGE_FILE", "Generate a sprite image which movie frames are merged to"
    method_option :input, aliases: "-i", desc: "Input movie file path"
    method_option :output, aliases: "-o", desc: "Output result file"
    def sprite
      movie_file = options[:input]
      result_file = options[:output]

      timestamp_image_dir = "/tmp/renchin_#{Time.now.to_i}"
      Dir::mkdir(timestamp_image_dir,0777)

      system("ffmpeg -i #{movie_file} -r 12 -s qvga -f image2 #{timestamp_image_dir}/renchin-original-%3d.png")
      system("convert #{timestamp_image_dir}/renchin-original-*.png -quality 30 #{timestamp_image_dir}/renchin-converted-%03d.jpg")
      system("convert #{timestamp_image_dir}/renchin-converted-*.jpg -append #{result_file}")

      # delete all files in directory
      Dir::foreach(timestamp_image_dir) do |file|
        File.delete(timestamp_image_dir + '/' + file) if (/(\.jpg|\.png)$/ =~ file)
      end
      Dir::rmdir(timestamp_image_dir)
      say("Renchin generated sprite file! ~> #{result_file}", :green)
    end
  end
end