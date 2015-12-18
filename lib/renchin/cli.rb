require "renchin"
require "thor"
require "renchin/file_processor"
require "open3"

module Renchin
  class CLI < Thor
    include Renchin::FileProcessor

    desc "tlapse -i MOVIE_FILE -o OUTPUT_FILE_NAME", "Generate a timelapse movie"
    method_option :input, aliases: "i", desc: "Input movie file path"
    method_option :output, aliases: "o", desc: "Output result file name"
    method_option :ofps, default: '30', desc: "Set output movie fps"
    method_option :iex, default: 'png', desc: "frame image extension"
    method_option :debug, default: 0, desc: "Print stdout"
    def tlapse
      movie_file = options[:input]
      result_file = options[:output]
      output_fps = options[:ofps]
      ext = options[:iex]
      debug = options[:debug].to_i

      image_directory_path = image_directory(__method__)
      Dir.chdir("#{image_directory_path}")

      # Split a movie to png images.
      o1, e1, i1 = Open3.capture3("ffmpeg -i #{movie_file} -f image2 #{image_directory_path}/%7d.#{ext}")
      # Generate timelapse movie from frame images.
      o2, e2, i2 = Open3.capture3("ffmpeg -f image2 -r #{frame_per_second(ext)} -i #{image_directory_path}/%7d.#{ext} -r #{output_fps} -an -vcodec libx264 -pix_fmt yuv420p #{result_file}")

      if debug == 1
        puts e1
        puts e2
      end

      delete_directory(image_directory_path, "\.#{ext}")
      say("Renchin generated timelapse! ~> #{result_file}", :green)
    end

    desc "sprite -i MOVIE_FILE -o IMAGE_FILE", "Generate a sprite image which movie frames are merged to"
    method_option :input, aliases: "i", desc: "Input movie file path"
    method_option :output, aliases: "o", desc: "Output result file"
    method_option :cfps, default: '2', desc: "Frame per second to capture"
    def sprite
      movie_file = options[:input]
      result_file = options[:output]
      captured_frame_per_sec = options[:cfps]

      image_directory_path = image_directory(__method__)

      system("ffmpeg -i #{movie_file} -r #{captured_frame_per_sec} -s qvga -f image2 #{image_directory_path}/renchin-original-%3d.png")
      system("convert #{image_directory_path}/renchin-original-*.png -quality 30 #{image_directory_path}/renchin-converted-%03d.jpg")
      system("convert #{image_directory_path}/renchin-converted-*.jpg -append #{result_file}")

      delete_directory(image_directory_path, "\.(jpg|png)")
      say("Renchin generated sprite file! ~> #{result_file}", :green)
    end

    desc "reverse -i MOVIE_FILE -o MOVIE_FILE -start START_TIME -end END_TIME", "Generate a reverse playback movie"
    method_option :input, aliases: "-i", desc: "Input movie file path"
    method_option :output, aliases: "-o", desc: "Output result file"
    method_option :start, aliases: "-s", default: 0, desc: "Movie start time"
    method_option :end, aliases: "-e", default: 10, desc: "Movie end time"
    def reverse
      movie_file = options[:input]
      result_file = options[:output]
      start_sec = options[:start]
      end_sec = options[:end]

      image_directory_path = image_directory(__method__)

      system("ffmpeg -i #{movie_file} -vf trim=#{start_sec}:#{end_sec},reverse,setpts=PTS-STARTPTS  -an #{result_file}")

      say("Renchin generated reverse movie! ~> #{result_file}", :green)
    end

    desc "cgraph -i GIF_FILE -o OUTPUT_GIF_FILE", "Generate a cinemagraph from gifs"
    method_option :input, aliases: "i", desc: "Input gif file path"
    method_option :output, aliases: "o", desc: "Output result file"
    method_option :frame_start, default: 1, desc: "which frame to pick as starting frame from inputfile?"
    method_option :frame_end, default: 10, desc: "which frame to stop?"
    method_option :frame_bg, default: 1, desc: "which frame should function as background 'still' ?"
    method_option :overlay_x, aliases: 'x', default: 0, desc: "which part should be animated?"
    method_option :overlay_y, aliases: 'y', default: 0, desc: "which part should be animated?"
    method_option :overlay_w, aliases: 'w', default: 50, desc: "which part should be animated?"
    method_option :overlay_h, aliases: 'h', default: 50, desc: "which part should be animated?"
    method_option :viewport_x, default: 0, desc: "crop final output"
    method_option :viewport_y, default: 0, desc: "crop final output"
    method_option :viewport_w, desc: "crop final output"
    method_option :viewport_h, desc: "crop final output"
    method_option :duration, aliases: 'd', default: 4, desc: "duration"
    def cgraph
      gif_file = options[:input]
      result_file = options[:output]
      gif_configs = (`identify ~/Downloads/notch_belt.gif`).split("\n")
      pingpong = 0 # comment this if you dont want a pingpong loop
      frame_start = options[:frame_start]
      frame_stop = options[:frame_end]
      frame_bg = options[:frame_bg]
      overlay_x = options[:overlay_x]
      overlay_y = options[:overlay_y]
      overlay_w = options[:overlay_w]
      overlay_h = options[:overlay_h]
      viewport_x = options[:viewport_x]
      viewport_y = options[:viewport_y]
      viewport_w = options[:viewport_w] || gif_configs[0].split(" ")[2].split("x")[0]
      viewport_h = options[:viewport_h] || gif_configs[0].split(" ")[2].split("x")[1]
      speed_current = options[:duration]
      frames = ""
      offset = 0

      image_directory_path = image_directory(__method__)

      # movie_to_frame
      system("convert #{gif_file}[#{frame_bg}] #{image_directory_path}/bg.png")
      system("convert #{gif_file} -repage 0x0 -crop #{overlay_w}x#{overlay_h}+#{overlay_x}+#{overlay_y} +repage #{image_directory_path}/frame.png")

      # frames_to_gif && iterate_frames
      frame_stop = (`identify #{gif_file} | wc -l`).chomp.gsub(/\s/,'').to_i
      for i in frame_start...frame_stop do
        frames = "#{frames} -delay #{speed_current} #{image_directory_path}/frame-out-#{offset}.png"
        system("convert #{image_directory_path}/bg.png #{image_directory_path}/frame-#{i}.png -geometry +#{overlay_x}+#{overlay_y} -compose over -composite #{image_directory_path}/frame-out-#{offset}.png")
        offset += 1
      end
      system("convert #{frames} -loop 0 -crop #{viewport_w}x#{viewport_h}+#{viewport_x}+#{viewport_y} -layers Optimize #{result_file}")


      delete_directory(image_directory_path, "\.(jpg|png)")
      say("Renchin generated sprite file! ~> #{result_file}", :green)
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