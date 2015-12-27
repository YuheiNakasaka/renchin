require "open3"
module Renchin
  class Client
    include Renchin::FileProcessor
    def tlapse(input, output, ofps=nil, iex='png', debug=0, force='')
      movie_file = input
      result_file = output
      output_fps = ofps || frame_per_second(60)
      ext = iex

      # validate params
      return false unless exists?(movie_file)
      # create dir for output file
      init_file(result_file)

      image_directory_path = image_directory(__method__)
      Dir.chdir("#{image_directory_path}")

      # Split a movie to png images.
      o1, e1, i1 = Open3.capture3("ffmpeg -i #{movie_file} -f image2 #{image_directory_path}/%7d.#{ext}")
      # Generate timelapse movie from frame images.
      o2, e2, i2 = Open3.capture3("ffmpeg #{force} -f image2 -r #{output_fps} -i #{image_directory_path}/%7d.#{ext} -r #{output_fps} -an -vcodec libx264 -pix_fmt yuv420p #{result_file}")

      if debug == 1
        puts e1
        puts e2
      end

      delete_directory(image_directory_path, "\.#{ext}")
      result_file
    end

    def sprite(input, output, cfps=2, debug=0)
      movie_file = input
      result_file = output
      captured_frame_per_sec = cfps

      # validate params
      return false unless exists?(movie_file)
      # create dir for output file
      init_file(result_file)

      image_directory_path = image_directory(__method__)
      Dir.chdir("#{image_directory_path}")

      o1, e1, i1 = Open3.capture3("ffmpeg -i #{movie_file} -r #{captured_frame_per_sec} -s qvga -f image2 #{image_directory_path}/renchin-original-%3d.png")
      o2, e2, i2 = Open3.capture3("convert #{image_directory_path}/renchin-original-*.png -quality 30 #{image_directory_path}/renchin-converted-%03d.jpg")
      o3, e3, i3 = Open3.capture3("convert #{image_directory_path}/renchin-converted-*.jpg -append #{result_file}") # if overwrite, use mogrify

      if debug == 1
        puts e1
        puts e2
        puts e3
      end

      delete_directory(image_directory_path, "\.(jpg|png)")
      result_file
    end

    def reverse(input, output, start=0, _end=10, debug=0, force="")
      movie_file = input
      result_file = output
      start_sec = start
      end_sec = _end

      # validate params
      return false unless exists?(movie_file)
      # create dir for output file
      init_file(result_file)

      image_directory_path = image_directory(__method__)
      Dir.chdir("#{image_directory_path}")

      o1, e1, i1 = Open3.capture3("ffmpeg #{force} -i #{movie_file} -vf trim=#{start_sec}:#{end_sec},reverse,setpts=PTS-STARTPTS  -an #{result_file}")

      if debug == 1
        puts e1
      end

      Dir::rmdir(image_directory_path)
      result_file
    end

    def cgraph(input, output, options={})
      # validate input params
      return false unless exists?(input)

      opts = {
        viewport_w: 100,
        viewport_h: 100,
        duration: 4,
        frame_start: 1,
        frame_end: 10,
        frame_bg: 1,
        overlay_x: nil,
        overlay_y: nil,
        overlay_w: 50,
        overlay_h: 50,
        viewport_x: 0,
        viewport_y: 0,
        debug: 0
      }.merge(options)
      gif_file = input
      result_file = output
      gif_configs = (`identify #{gif_file}`).split("\n")
      viewport_w = opts[:viewport_w] || gif_configs[0].split(" ")[2].split("x")[0]
      viewport_h = opts[:viewport_h] || gif_configs[0].split(" ")[2].split("x")[1]
      speed_current = opts[:duration]
      frame_start = opts[:frame_start]
      frame_stop = opts[:frame_end]
      frame_bg = opts[:frame_bg]
      overlay_x = opts[:overlay_x]
      overlay_y = opts[:overlay_y]
      overlay_w = opts[:overlay_w]
      overlay_h = opts[:overlay_h]
      viewport_x = opts[:viewport_x]
      viewport_y = opts[:viewport_y]
      frames = ""
      offset = 0

      # create dir for output file
      init_file(result_file)

      image_directory_path = image_directory(__method__)
      Dir.chdir("#{image_directory_path}")

      # movie_to_frame
      o1, e1, i1 = Open3.capture3("convert #{gif_file}[#{frame_bg}] #{image_directory_path}/bg.png")
      o2, e2, i2 = Open3.capture3("convert #{gif_file} -repage 0x0 -crop #{overlay_w}x#{overlay_h}+#{overlay_x}+#{overlay_y} +repage #{image_directory_path}/frame.png")

      # frames_to_gif && iterate_frames
      frame_stop = (`identify #{gif_file} | wc -l`).chomp.gsub(/\s/,'').to_i
      for i in frame_start...frame_stop do
        frames = "#{frames} -delay #{speed_current} #{image_directory_path}/frame-out-#{offset}.png"
        o3, e3, i3 = Open3.capture3("convert #{image_directory_path}/bg.png #{image_directory_path}/frame-#{i}.png -geometry +#{overlay_x}+#{overlay_y} -compose over -composite #{image_directory_path}/frame-out-#{offset}.png")
        offset += 1
      end
      o4, e4, i4 = Open3.capture3("convert #{frames} -loop 0 -crop #{viewport_w}x#{viewport_h}+#{viewport_x}+#{viewport_y} -layers Optimize #{result_file}")

      if opts[:debug] == 1
        puts e1, e2, e3, e4
      end

      delete_directory(image_directory_path, "\.(jpg|png)")
      result_file
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