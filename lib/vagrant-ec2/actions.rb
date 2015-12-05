require_relative 'actions/connect_aws'

module VagrantPlugins
  module Ec2
    module Actions
      include Vagrant::Action::Builtin

      def self.up
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use ConnectAWS
          puts "This UP worked"
        end
      end
    end
  end
end
