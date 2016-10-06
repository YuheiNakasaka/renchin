require "fileutils"
module Renchin
  class FrameReduction
    def initialize(input, options)
      @opts = {
        div_count: 10,
        div_count_rate: nil,
        root_path: "/tmp",
        output_path: nil,
        delay: nil,
        threadhold_width: 500,
        threadhold_height: 500,
        threadhold_file_weight: 512000
      }.merge(options)

      @working_directory = working_directory
      @input_path = input_path(input)
      @output_path = output_path
      @command_path = Renchin.options[:command_path].nil? ? '' : Renchin.options[:command_path]+'/'
      @unique_identifier = "#{Time.now.to_i}_#{rand(10000)}" # used as unique indetifier

      # validate params
      return false unless File.exists?(@input_path)
    end

    def run
      create_frame_reduced_gif
      resize_output_image
      @output_path
    end

    # delete waste files
    def delete(options = {})
      # In default, delete frame files and working directory
      opts = {
        del_input: false,
        del_output: false
      }.merge(options)
      File.unlink(@input_path) if opts[:del_input]
      File.unlink(@output_path) if opts[:del_output]
      delete_files
    end

    private
    # make working directory
    # return dir name
    def working_directory
      puts "Creating working directory"
      timestamp_image_dir = "#{@opts[:root_path]}/renchin_frame_reduction_#{@unique_identifier}"
      Dir::mkdir(timestamp_image_dir, 0777) unless File.exists?(timestamp_image_dir)
      timestamp_image_dir
    end

    # given url or local path,
    # return local path
    def input_path(input)
      input =~ /\A#{URI::regexp(['http', 'https'])}\z/ ? download(input) : input
    end

    def output_path
      @opts[:output_path].nil? ? "#{@opts[:root_path]}/renchin_frame_reduction_output_#{@unique_identifier}.gif" : @opts[:output_path]
    end

    def download(input_url)
      puts "Downloading #{input_url}"
      local_input_path = "#{@opts[:root_path]}/renchin_frame_reduction_input_#{@unique_identifier}.gif"
      ret = 0
      begin
        open(local_input_path,'wb') do |file|
          open(input_url) do |data|
            file.write(data.read)
          end
        end
      rescue
        if ret < 4
          retry
        else
          raise "Original file not downloaded"
        end
      end
      local_input_path
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

    # create frame reduced gif
    # return frame_paths
    def create_frame_reduced_gif
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
          frame_path = "#{@working_directory}/#{@unique_identifier}_#{i}.gif"
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
    end

    # resize and execute optimization to output gif
    def resize_output_image
      puts "Resizing output image"
      o,e,s = Open3.capture3("#{@command_path}gifsicle -b -O2 --resize-fit #{@opts[:threadhold_width]}x#{@opts[:threadhold_height]} #{@output_path}")
    end

    # clean directory
    def delete_files
      puts "Deleting waste files"
      Dir::entries(@working_directory).each {|f| File.unlink("#{@working_directory}/#{f}") if f.match(/.+\..+$/)}
      Dir::unlink(@working_directory)
    end
  end
end