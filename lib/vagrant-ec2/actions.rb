require 'aws-sdk'
require_relative 'actions/connect_aws'
require_relative 'actions/check_state'
require_relative 'actions/run_instance'

module VagrantPlugins
  module Ec2
    module Actions
      include Vagrant::Action::Builtin

      def self.read_state
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use ConnectAWS
          builder.use CheckState
        end
      end

      def self.up
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use ConnectAWS
          builder.use Call, CheckState do |env, b|
            if env[:machine_state] == :not_created
              b.use RunInstance
            else
              puts env[:machine_state]
            end
          end
        end
      end
    end
  end
end
