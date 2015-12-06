require 'aws-sdk'
require_relative 'actions/check_state'
require_relative 'actions/connect_aws'
require_relative 'actions/find_host'
require_relative 'actions/run_instance'
require_relative 'actions/start_instance'
require_relative 'actions/stop_instance'
require_relative 'actions/terminate_instance'
require_relative 'actions/wait_for_state'

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
            if env[:result] != :running
              env[:ui].info I18n.t('vagrant_ec2.info.state.not_running')
              next
            end
            b.use SSHExec
          end
        end
      end

      def self.resume
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use ConnectAWS
          builder.use Call, CheckState do |env, b|
            case env[:result]
            when :stopped
              b.use StartInstance
              b.use WaitForState, :running
            when :running
              env[:ui].info I18n.t('vagrant_ec2.info.state.already_running')
              next
            when :not_created
              env[:ui].info I18n.t('vagrant_ec2.info.state.not_created')
              next
            else
              env[:ui].info I18n.t('vagrant_ec2.info.state.unexpected_state', :state => env[:result])
              next
            end
          end
        end
      end

      def self.suspend
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use ConnectAWS
          builder.use Call, CheckState do |env, b|
            case env[:result]
            when :running
              b.use StopInstance
              b.use WaitForState, :stopped
            when :stopped
              env[:ui].info I18n.t('vagrant_ec2.info.state.already_stopped')
              next
            when :not_created
              env[:ui].info I18n.t('vagrant_ec2.info.state.not_created')
              next
            else
              env[:ui].info I18n.t('vagrant_ec2.info.state.unexpected_state', :state => env[:result])
              next
            end
          end
        end
      end

      def self.destroy
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use Call, DestroyConfirm do |env, b|
            if !env[:result]
              env[:ui].info I18n.t('vagrant_ec2.info.not_destroying')
              next
            end
            b.use ConfigValidate
            b.use ConnectAWS
            b.use Call, CheckState do |env2, b2|
              if env2[:result] == :not_created
                env[:ui].info I18n.t('vagrant_ec2.info.state.not_created')
                next
              end
              b2.use TerminateInstance
              b2.use WaitForState, :terminated
            end
          end
        end
      end

      def self.up
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use ConnectAWS
          builder.use Call, CheckState do |env, b|
            case env[:result]
            when :not_created
              b.use RunInstance
            when :stopped
              b.use StartInstance
            when :running
              env[:ui].info I18n.t('vagrant_ec2.info.state.already_running')
              next
            else
              env[:ui].info I18n.t('vagrant_ec2.info.state.unexpected_state', :state => env[:result])
              next
            end
            b.use WaitForState, :running
          end
        end
      end
    end
  end
end
