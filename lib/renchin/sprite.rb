require "renchin"
require "thor"

module Renchin
  class Sprite < Thor
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