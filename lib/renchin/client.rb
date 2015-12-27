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
      o3, e3, i3 = Open3.capture3("convert #{image_directory_path}/renchin-converted-*.jpg -append #{result_file}")

      if debug == 1
        puts e1
        puts e2
        puts e3
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