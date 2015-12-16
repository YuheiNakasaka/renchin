# Renchin

Renchin is a convinient cli wrapper to convert movie to image/movie/gif or convert image to image/movie/gif with imagemagick and ffmpeg.

## Requirements

- FFmpeg
- Imagemagick

## Installation

```ruby
gem 'renchin'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install renchin

## Usage

### Timelapse

```
renchin tlapse  -i MOVIE_FILE_PATH -o OUTPUT_MOVIE_FILE_PATH
```

#### Options

- --ofps
  - set output movie fps(default: 30)
- --iex
  - set temporary image file extension(default: png)

example)

```
renchin tlapse  -i /tmp/example.mp4 -o /tmp/renchin_output_tlapse.mp4
```

### Single sprite image from movie

```
renchin sprite  -i MOVIE_FILE_PATH -o OUTPUT_FILE_PATH
```

#### Options

- --cfps
  - captured frame per second

example)

```
renchin sprite  -i /tmp/example.mp4 -o /tmp/renchin_output_sprite.jpg
```

### Reverse movie

```
renchin reverse  -i MOVIE_FILE_PATH -o OUTPUT_FILE_PATH -s START_TIME -e END_TIME
```

example)

```
renchin reverse  -i /tmp/example.mp4 -o /tmp/renchin_output_reverse.mp4 -s 0 -e 40
```

The example, output movie starts from 40 second and finishes to 0 second.

### cinemagraph

create cinemagraph gif from gif animation

```
renchin cgraph -i GIF_FILE -o OUTPUT_GIF_FILE -x ANIMATED_POSITION_X -y ANIMATED_POSITION_Y -w ANIMATED_PART_WIDTH -h ANIMATED_PART_HEIGHT
```

example)

```
renchin  cgraph  -i /tmp/example.gif  -o /tmp/output_gif_file.gif -x 250 -y 100 -w 50 -h 100
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/YuheiNakasaka/renchin.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

