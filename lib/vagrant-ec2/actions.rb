require 'aws-sdk'
require_relative 'actions/connect_aws'
require_relative 'actions/check_state'
require_relative 'actions/wait_for_state'
require_relative 'actions/run_instance'
require_relative 'actions/start_instance'

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

      def self.resume
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use ConnectAWS
          builder.use Call, CheckState do |env, b|
            if env[:machine_state] == :stopped || env[:machine_state] == :stopping
              b.use WaitForState, :stopped if env[:machine_state] == :stopping
              b.use StartInstance
              b.use WaitForState, :running
            elsif env[:machine_state] == :running
              raise env[:machine_state]
            else
              raise "The instance #{env[:machine].id} is #{env[:machine_state]} this is unexpected"
            end
          end
        end
      end

      def self.up
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use ConnectAWS
          builder.use Call, CheckState do |env, b|
            if env[:machine_state] == :not_created
              b.use RunInstance
            elsif env[:machine_state] == :stopped || env[:machine_state] == :stopping
              b.use WaitForState, :stopped if env[:machine_state] == :stopping
              b.use StartInstance
            else
              if env[:machine_state] == :running
                raise env[:machine_state]
              else
                raise "The instance #{env[:machine].id} is #{env[:machine_state]} this is unexpected"
              end
            end
            b.use WaitForState, :running
          end
        end
      end
    end
  end
end
