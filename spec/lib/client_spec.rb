require 'spec_helper'

def fixture_file(filename)
  File.join(File.dirname(__FILE__), 'fixtures', filename)
end

def delete_file(filename)
  File.delete(filename)
end

describe "Renchin::Client" do
  context "tlapse" do
    subject(:renchin) { Renchin::Client.new }
    it "return generated file path" do
      res = renchin.tlapse( fixture_file("zOx3LRvtz22XIfhE.mp4") , "/tmp/output.mp4")
      expect(res).to eq('/tmp/output.mp4')
      delete_file(res)
    end

    it "return false if input file is not existed", focus: true do
      res = renchin.tlapse( fixture_file("not.mp4") , "/tmp/output.mp4")
      expect(res).to eq(false)
    end
  end
end