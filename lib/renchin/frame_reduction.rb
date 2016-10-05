require "fileutils"
module Renchin
  class FrameReduction
    def initialize(input, output, options)
      @opts = {
        div_count: 10,
        div_count_rate: nil,
        root_path: "/tmp",
        delay: nil,
        threadhold_width: 500,
        threadhold_height: 500,
        threadhold_file_weight: 512000
      }.merge(options)

      @input_path = input
      @output_path = output
      @command_path = Renchin.options[:command_path].nil? ? '' : Renchin.options[:command_path]+'/'
      @timestamp = "#{Time.now.to_i}_#{rand(10000)}" # used as unique indetifier
      @working_directory = working_directory

      # validate params
      return false unless File.exists?(@input_path)
    end

    def run
      frame_paths = create_frames_path
      resize_output_image
      delete_files(frame_paths)
      @output_path
    end

    private
    # make working directory
    # return dir name
    def working_directory
      puts "Creating working directory"
      timestamp_image_dir = "#{@opts[:root_path]}/renchin_decrease_frames_#{@timestamp}"
      Dir::mkdir(timestamp_image_dir, 0777) unless File.exists?(timestamp_image_dir)
      timestamp_image_dir
    end

    # get total frame size
    def get_total_frame_count
      puts "Fetching total frame count"
      o, e, s = Open3.capture3("#{@command_path}identify -format '%n,' #{@input_path}")
      o.split(",")[0].to_i
    end

    # get file size
    def file_size
      puts "Getting input file size"
      File.size(@input_path)
    end

    # get original delay
    def get_original_delay
      puts "Getting original gif delay"
      if @opts[:delay].nil?
        delays = IO.popen("#{@command_path}identify -format '%T,' #{@input_path}",'r+') {|io|io.gets}.split(',')
        .reject{|delay| delay =~ /\n/}
        .map{|delay| delay.to_i == 0 ? 9 : delay.to_f}
        avg_delay = (delays.inject(:+) / delays.size).to_i
        (avg_delay / @opts[:div_count_rate]).to_i
      else
        @opts[:delay].to_i
      end
    end

    # create frames path
    # return frame_paths
    def create_frames_path
      puts "Creating frames path"
      frame_paths = []
      file_weight = file_size
      total_frame_count = get_total_frame_count
      delay = get_original_delay

      div_frame_count = @opts[:div_count_rate].nil? ? @opts[:div_count] : (total_frame_count * @opts[:div_count_rate].to_f).floor
      if file_weight > @opts[:threadhold_file_weight]
        # divisions to fetch gif frames
        # if total frames is more than div_count, use all frames so keep_div is 1
        keep_div = (total_frame_count.to_f / div_frame_count).floor
        keep_index = keep_div
        keep_frames = []
        total_frame_count.times do |i|
          if keep_index == i
            keep_frames << keep_index
            keep_index += keep_div
            next
          end
        end

        # extract each frames from original image
        keep_frames.each do |i|
          frame_path = "#{@working_directory}/#{@timestamp}_#{i}.gif"
          frame_paths << frame_path
          o,e,s = Open3.capture3("#{@command_path}gifsicle --unoptimize #{@input_path} \"##{i}\" -o #{frame_path}")
        end

        # create a new gif from that extracted frames
        o,e,s = Open3.capture3("#{@command_path}gifsicle --delay #{delay} #{@output_path} #{frame_paths.join(' ')} > #{@output_path}")
      else
        # when total_frame_count is less than div_count
        # use original gif as output gif
        FileUtils.copy(@input_path, @output_path)
      end

      frame_paths
    end

    # resize and execute optimization to output gif
    def resize_output_image
      puts "Resizing output image"
      o,e,s = Open3.capture3("#{@command_path}gifsicle -b -O2 --resize-fit #{@opts[:threadhold_width]}x#{@opts[:threadhold_height]} #{@output_path}")
    end

    # clean directory
    def delete_files(frame_paths)
      puts "Deleting waste files"
      frame_paths.each do |path|
        File.delete(path) # delete frame gif
      end
      Dir::unlink(@working_directory)
    end
  end
end