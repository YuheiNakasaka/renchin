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
      output = "/tmp/output.mp4"
      if File.exist?(output)
        File.delete(output)
      end
    end

    it "return generated file path" do
      res = renchin.tlapse( fixture_file("zOx3LRvtz22XIfhE.mp4") , "/tmp/output.mp4")
      expect(res).to eq('/tmp/output.mp4')
    end

    it "return false if input file is not existed", focus: true do
      res = renchin.tlapse( fixture_file("not.mp4") , "/tmp/output.mp4")
      expect(res).to eq(false)
    end

    it "return stdout if set debug options to 1" do
       expect {renchin.tlapse( fixture_file("zOx3LRvtz22XIfhE.mp4") , "/tmp/output.mp4", 60, "png", 1)}.to output.to_stdout
    end

    it "generate XX fps movie if set XX fps" do
      res = renchin.tlapse( fixture_file("zOx3LRvtz22XIfhE.mp4") , "/tmp/output.mp4", 80)
      o,e,i = Open3.capture3("ffmpeg -i #{res}")
      matched = e.match(/(\d+)\sfps/)
      expect(matched[1]).to eq('80')
    end

    it "generate a movie from XX ext images if set XX ext" do
      res = renchin.tlapse( fixture_file("zOx3LRvtz22XIfhE.mp4") , "/tmp/output.mp4", 60, 'jpg')
      expect(res).to eq('/tmp/output.mp4')
    end

  end

  context "sprite" do
    subject(:renchin) { Renchin::Client.new }

    before do
      output = "/tmp/output.jpg"
      if File.exist?(output)
        File.delete(output)
      end
    end

    it "return generated file path" do
      res = renchin.sprite( fixture_file("zOx3LRvtz22XIfhE.mp4") , "/tmp/output.jpg")
      expect(res).to eq('/tmp/output.jpg')
    end

    it "return false if input file is not existed" do
      res = renchin.sprite( fixture_file("not.mp4") , "/tmp/output.jpg")
      expect(res).to eq(false)
    end

    it "return stdout if set debug options to 1" do
       expect {renchin.sprite( fixture_file("zOx3LRvtz22XIfhE.mp4") , "/tmp/output.jpg", 2, 1)}.to output.to_stdout
    end

  end
end