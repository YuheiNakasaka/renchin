require "renchin/version"
require "renchin/cli"
require "renchin/client"

module Renchin
  def self.options
    @options ||= {
      command_path: nil
    }
  end
end
