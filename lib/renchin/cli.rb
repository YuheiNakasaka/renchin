require "renchin"
require "thor"
require "renchin/file_processor"

module Renchin
  class CLI < Thor
    include Renchin::FileProcessor

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

      image_directory_path = image_directory(__method__)
      Dir.chdir("#{image_directory_path}")

      # Split a movie to png images.
      system("ffmpeg -i #{movie_file} -f image2 #{image_directory_path}/%7d.#{ext}")
      # Generate timelapse movie from frame images.
      system("ffmpeg -f image2 -r #{playback_time(ext)} -i #{image_directory_path}/%7d.#{ext} -r #{output_fps} -an -vcodec libx264 -pix_fmt yuv420p #{result_file}")

      delete_directory(image_directory_path, "\.#{ext}")
      say("Renchin generated timelapse! ~> #{result_file}", :green)
    end

    desc "sprite -i MOVIE_FILE -o IMAGE_FILE", "Generate a sprite image which movie frames are merged to"
    method_option :input, aliases: "-i", desc: "Input movie file path"
    method_option :output, aliases: "-o", desc: "Output result file"
    def sprite
      movie_file = options[:input]
      result_file = options[:output]

      image_directory_path = image_directory(__method__)

      system("ffmpeg -i #{movie_file} -r 12 -s qvga -f image2 #{image_directory_path}/renchin-original-%3d.png")
      system("convert #{image_directory_path}/renchin-original-*.png -quality 30 #{image_directory_path}/renchin-converted-%03d.jpg")
      system("convert #{image_directory_path}/renchin-converted-*.jpg -append #{result_file}")

      delete_directory(image_directory_path, "\.(jpg|png)")
      say("Renchin generated sprite file! ~> #{result_file}", :green)
    end

    private
    def frame_count(expr)
      Dir.glob(expr).count
    end

    def playback_time(ext)
      frame_count("*\.#{ext}") > 10 ? frame_count("*\.#{ext}") / 10 : 1
    end
  end
end