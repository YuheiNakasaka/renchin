require 'spec_helper'
require 'open3'

def fixture_file(filename)
  File.join(File.dirname(__FILE__), 'fixtures', filename)
end

def delete_file(filename)
  File.delete(filename)
end

describe "Renchin::Client" do
  context "tlapse" do
    subject(:renchin) { Renchin::Client.new }

    before do
      @output = "/tmp/output.mp4"
      if File.exist?(@output)
        File.delete(@output)
      end
      @options = {
        ofps: nil,
        iex: 'png',
        debug: 0,
        force: ''
      }
    end

    it "return generated file path" do
      res = renchin.tlapse( fixture_file("zOx3LRvtz22XIfhE.mp4") , "/tmp/output.mp4", @options)
      expect(res).to eq('/tmp/output.mp4')
    end

    it "return false if input file is not existed" do
      res = renchin.tlapse( fixture_file("not.mp4") , "/tmp/output.mp4", @options)
      expect(res).to eq(false)
    end

    it "return stdout if set debug options to 1" do
      @options[:ofps] = 60
      @options[:iex] = 'png'
      @options[:debug] = 1
      expect {renchin.tlapse( fixture_file("zOx3LRvtz22XIfhE.mp4") , "/tmp/output.mp4", @options)}.to output.to_stdout
    end

    it "generate XX fps movie if set XX fps" do
      @options[:ofps] = 80
      res = renchin.tlapse( fixture_file("zOx3LRvtz22XIfhE.mp4") , "/tmp/output.mp4", @options)
      o,e,i = Open3.capture3("ffmpeg -i #{res}")
      matched = e.match(/(\d+)\sfps/)
      expect(matched[1]).to eq('80')
    end

    it "generate a movie from XX ext images if set XX ext" do
      @options[:ofps] = 60
      @options[:iex] = 'jpg'
      res = renchin.tlapse( fixture_file("zOx3LRvtz22XIfhE.mp4") , "/tmp/output.mp4", @options)
      expect(res).to eq('/tmp/output.mp4')
    end

    after do
      File.delete(@output) if File.exist?(@output)
    end

  end

  context "sprite" do
    subject(:renchin) { Renchin::Client.new }

    before do
      @output = "/tmp/output.jpg"
      if File.exist?(@output)
        File.delete(@output)
      end
      @options = {
        cfps: 2,
        debug: 0
      }
    end

    it "return generated file path" do
      res = renchin.sprite( fixture_file("zOx3LRvtz22XIfhE.mp4") , "/tmp/output.jpg", @options)
      expect(res).to eq('/tmp/output.jpg')
    end

    it "return false if input file is not existed" do
      res = renchin.sprite( fixture_file("not.mp4") , "/tmp/output.jpg", @options)
      expect(res).to eq(false)
    end

    it "return stdout if set debug options to 1" do
      @options[:debug] = 1
      expect {renchin.sprite( fixture_file("zOx3LRvtz22XIfhE.mp4") , "/tmp/output.jpg", @options)}.to output.to_stdout
    end

    after do
      File.delete(@output) if File.exist?(@output)
    end

  end

  context "reverse" do
    subject(:renchin) { Renchin::Client.new }

    before do
      output = "/tmp/output.mp4"
      if File.exist?(output)
        File.delete(output)
      end
      @options = {
        start: 0,
        _end: 0,
        debug: 0,
        force: ""
      }
    end

    it "return generated file path" do
      res = renchin.reverse( fixture_file("zOx3LRvtz22XIfhE.mp4") , "/tmp/output.mp4", @options)
      expect(res).to eq('/tmp/output.mp4')
    end

    it "return false if input file is not existed" do
      res = renchin.reverse( fixture_file("not.mp4") , "/tmp/output.mp4", @options)
      expect(res).to eq(false)
    end

    it "return stdout if set debug options to 1" do
      @options[:_end] = 10
      @options[:debug] = 1
      expect {renchin.reverse( fixture_file("zOx3LRvtz22XIfhE.mp4") , "/tmp/output.mp4", @options)}.to output.to_stdout
    end

    it "generate expected movie file if set start and end" do
      @options[:start] = 5
      @options[:_end] = 10
      @options[:force] = '-y'
      res = renchin.reverse( fixture_file("zOx3LRvtz22XIfhE.mp4") , "/tmp/output.mp4", @options)
      o,e,i = Open3.capture3("ffmpeg -i #{res}")
      matched = e.match(/Duration:\s(\d+):(\d+):(\d+)/)
      expect(matched[3]).to eq('04') # Duration: 00:00:04:99
    end

  end

  context "cgraph" do
    subject(:renchin) { Renchin::Client.new }

    before do
      output = "/tmp/output.gif"
      if File.exist?(output)
        File.delete(output)
      end
      @options = {viewport_w: 411, viewport_h: 315}
    end

    it "return generated file path" do
      res = renchin.cgraph( fixture_file("cat_sozai.gif") , "/tmp/output.gif", @options)
      expect(res).to eq('/tmp/output.gif')
    end

    it "return false if input file is not existed" do
      res = renchin.cgraph( fixture_file("not.gif") , "/tmp/output.gif", @options)
      expect(res).to eq(false)
    end

    it "return stdout if set debug options to 1" do
      @options[:debug] = 1
      expect {renchin.cgraph( fixture_file("cat_sozai.gif") , "/tmp/output.gif", @options)}.to output.to_stdout
    end

  end

  context "movie_to_gif" do
    subject(:renchin) { Renchin::Client.new }

    before do
      output = "/tmp/output.gif"
      if File.exist?(output)
        File.delete(output)
      end
      @options = {
        debug: 0,
        force: ""
      }
    end

    it "return generated file path" do
      res = renchin.movie_to_gif( fixture_file("zOx3LRvtz22XIfhE.mp4") , "/tmp/output.gif", @options)
      expect(res).to eq('/tmp/output.gif')
    end
  end

  context "frame_reduction" do
    subject(:renchin) { Renchin::Client.new }

    before do
      @output = ''
      if File.exist?(@output)
        File.delete(@output)
      end
      @options = {
        reduction_rate: 0.3
      }
    end

    it "return generated file path" do
      @output = renchin.frame_reduction( fixture_file("cat_sozai.gif"), @options)
      expect(@output).to match(%r!/tmp/renchin_frame_reduction_output_(\d+_\d+).gif!)
    end

    it "change result file path" do
      @options[:output_path] = '/tmp/output.gif'
      @output = renchin.frame_reduction( fixture_file("cat_sozai.gif"), @options)
      expect(@output).to eq('/tmp/output.gif')
    end

    after do
      File.delete(@output) if File.exist?(@output)
    end
  end

end