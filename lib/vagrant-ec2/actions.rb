require 'aws-sdk'
require_relative 'actions/connect_aws'

module VagrantPlugins
  module Ec2
    module Actions
      include Vagrant::Action::Builtin

      def self.up
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use ConnectAWS
          builder.use Call, CheckState do |env, b|
            if env[:machine_state] == :not_created
            end
          end
        end
      end
    end
  end
end
