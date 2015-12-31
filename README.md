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

![timelapse](http://img.gifmagazine.net/gifmagazine/images/693433/original.gif)

```
renchin = Renchin.new
renchin.tlapse( "/tmp/zOx3LRvtz22XIfhE.mp4" , "/tmp/output.mp4")
```

### CLI

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

It creates a single sprite image from movie.

The image is useful to create gif like animation with javascript in [this library](http://nbnote.github.io/flipbook/).

```
renchin = Renchin.new
renchin.sprite( "/tmp/zOx3LRvtz22XIfhE.mp4" , "/tmp/output.jpg")
```

### CLI

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

![reverse movie](http://img.gifmagazine.net/gifmagazine/images/496200/original.gif?1438912596)

```
renchin = Renchin.new
renchin.reverse( "/tmp/zOx3LRvtz22XIfhE.mp4" , "/tmp/output.mp4", {start: 0, end_sec: 10})
```

#### Options

- start
  - start time
- _end
  - end time

### CLI

```
renchin reverse  -i MOVIE_FILE_PATH -o OUTPUT_FILE_PATH -s START_TIME -e END_TIME
```

example)

```
renchin reverse  -i /tmp/example.mp4 -o /tmp/renchin_output_reverse.mp4 -s 0 -e 40
```

The example, output movie starts from 40 second and finishes to 0 second.

### cinemagraph

![cinemagraph](http://img.gifmagazine.net/gifmagazine/images/676045/original.gif)

create cinemagraph gif from gif animation

```
renchin = Renchin.new
renchin.cgraph( "/tmp/zOx3LRvtz22XIfhE.gif" , "/tmp/output.gif", {overlay_x: 320, overlay_y: 150, overlay_w: 411, overlay_h: 315, viewport_w: 411, viewport_h: 315})
```

#### Options

- overlay_x
  - animated part x
- overlay_y
  - animated part y
- overlay_w
  - animated part width
- overlay_h
  - animated part height
- viewport_w
  - final output width
- viewport_h
  - final output height

### CLI

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

