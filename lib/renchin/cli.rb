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
      system("ffmpeg -f image2 -r #{frame_per_second(ext)} -i #{image_directory_path}/%7d.#{ext} -r #{output_fps} -an -vcodec libx264 -pix_fmt yuv420p #{result_file}")

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

    desc "reverse -i MOVIE_FILE -o MOVIE_FILE -start START_TIME -end END_TIME", "Generate a reverse playback movie"
    method_option :input, aliases: "-i", desc: "Input movie file path"
    method_option :output, aliases: "-o", desc: "Output result file"
    method_option :start, aliases: "-s", desc: "Movie start time"
    method_option :end, aliases: "-e", desc: "Movie end time"
    def reverse
      movie_file = options[:input]
      result_file = options[:output]
      start_sec = options[:start] || 0
      end_sec = options[:end] || 10

      image_directory_path = image_directory(__method__)

      system("ffmpeg -i #{movie_file} -vf trim=#{start_sec}:#{end_sec},reverse,setpts=PTS-STARTPTS  -an #{result_file}")

      say("Renchin generated reverse movie! ~> #{result_file}", :green)
    end

    private
    def frame_count(expr)
      Dir.glob(expr).count
    end

    def frame_per_second(ext)
      frame_count("*\.#{ext}") > 10 ? frame_count("*\.#{ext}") / 10 : 1
    end
  end
end