require 'aws-sdk'
require_relative 'actions/connect_aws'
require_relative 'actions/check_state'
require_relative 'actions/wait_for_state'
require_relative 'actions/find_host'
require_relative 'actions/run_instance'
require_relative 'actions/start_instance'
require_relative 'actions/terminate_instance'

module VagrantPlugins
  module Ec2
    module Actions
      include Vagrant::Action::Builtin

      def self.read_state
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use ConnectAWS
          builder.use CheckState, true
        end
      end

      def self.find_host
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use ConnectAWS
          builder.use FindHost
        end
      end

      def self.ssh
        Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use ConnectAWS
          builder.use Call, CheckState do |env, b|
            if env[:result] == :running
              b.use SSHExec
            end
          end
        end
      end

      def self.resume
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use ConnectAWS
          builder.use Call, CheckState do |env, b|
            if env[:result] == :stopped || env[:result] == :stopping
              b.use WaitForState, :stopped if env[:result] == :stopping
              b.use StartInstance
              b.use WaitForState, :running
            elsif env[:result] == :running
              raise env[:result]
            else
              raise "The instance #{env[:machine].id} is #{env[:result]} this is unexpected"
            end
          end
        end
      end

      def self.destroy
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use Call, DestroyConfirm do |env, b|
            if env[:result]
              b.use ConfigValidate
              b.use ConnectAWS
              b.use Call, CheckState do |env2, b2|
                if env2[:result] != :not_created
                  b2.use TerminateInstance
                  b2.use WaitForState, :terminated
                end
              end
            else
              puts "Welp no destroy"
            end
          end
        end
      end

      def self.up
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use ConnectAWS
          builder.use Call, CheckState do |env, b|
            if env[:result] == :not_created
              b.use RunInstance
            elsif env[:result] == :stopped || env[:result] == :stopping
              b.use WaitForState, :stopped if env[:result] == :stopping
              b.use StartInstance
            else
              if env[:result] == :running
                raise env[:result]
              else
                raise "The instance #{env[:machine].id} is #{env[:result]} this is unexpected"
              end
            end
            b.use WaitForState, :running
          end
        end
      end
    end
  end
end
