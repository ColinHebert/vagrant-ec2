require 'aws-sdk'
require_relative 'action/check_state'
require_relative 'action/connect_aws'
require_relative 'action/find_host'
require_relative 'action/run_instance'
require_relative 'action/start_instance'
require_relative 'action/stop_instance'
require_relative 'action/terminate_instance'
require_relative 'action/wait_for_state'

module VagrantPlugins
  module Ec2
    module Actions
      include Vagrant::Action::Builtin

      # Checks the state of the instance and caches it for later usage
      def self.read_state
        Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use ConnectAWS
          builder.use CheckState, true
        end
      end

      # Checks the ip/hostname of the instance used for SSH access
      def self.find_host
        Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use ConnectAWS
          builder.use FindHost
        end
      end

      # Creates a SSH connection to the instance
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

      # Creates a SSH connection to the instance
      def self.ssh_run
        Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use ConnectAWS
          builder.use Call, CheckState do |env, b|
            if env[:result] != :running
              env[:ui].info I18n.t('vagrant_ec2.info.state.not_running')
              next
            end
            b.use SSHRun
          end
        end
      end

      # Runs the provisioning
      def self.provision
        Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use ConnectAWS
          builder.use Call, CheckState do |env, b|
            case env[:result]
            when :running
              b.use Provision
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

      # Restarts the running instance
      def self.reload
        Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use ConnectAWS
          builder.use Call, CheckState do |env, b|
            case env[:result]
            when :running
              b.use Provision
              b.use SyncedFolders
              b.use Call, GracefulHalt, :not_created, :running do |env2, b2|
                next if env2[:result]
                b2.use StopInstance
                b2.use WaitForState, :stopped
              end
              b.use StartInstance
              b.use WaitForState, :running
            when :stopped, :not_created
              env[:ui].info I18n.t('vagrant_ec2.info.state.not_running')
              next
            else
              env[:ui].info I18n.t('vagrant_ec2.info.state.unexpected_state', :state => env[:result])
              next
            end
          end
        end
      end

      # Stops the running instance
      def self.halt
        Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use ConnectAWS
          builder.use Call, CheckState do |env, b|
            case env[:result]
            when :running
              b.use Call, GracefulHalt, :not_created, :running do |env2, b2|
                next if env2[:result]
                b2.use StopInstance
                b2.use WaitForState, :stopped
              end
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

      # Terminates the instance
      def self.destroy
        Vagrant::Action::Builder.new.tap do |builder|
          builder.use Call, DestroyConfirm do |env, b|
            if !env[:result]
              env[:ui].info I18n.t('vagrant_ec2.info.not_destroying')
              next
            end
            b.use ConfigValidate
            b.use ConnectAWS
            b.use Call, CheckState do |env2, b2|
              if env2[:result] == :not_created
                env2[:ui].info I18n.t('vagrant_ec2.info.state.not_created')
                next
              end
              b2.use TerminateInstance
              b2.use WaitForState, :terminated
            end
          end
        end
      end

      # Creates a new instance or starts the stopped instance
      def self.up
        Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use ConnectAWS
          builder.use Call, CheckState do |env, b|
            case env[:result]
            when :not_created
              b.use Provision
              b.use SyncedFolders
              b.use RunInstance
            when :stopped
              b.use Provision
              b.use SyncedFolders
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
