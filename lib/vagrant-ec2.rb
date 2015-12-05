require 'pathname'

require 'vagrant-ec2/version'
require 'vagrant-ec2/plugin'

module VagrantPlugins
  module Ec2
    # This returns the path to the source of this plugin.
    #
    # @return [Pathname]
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end
  end
end
