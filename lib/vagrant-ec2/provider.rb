require_relative 'actions'

module VagrantPlugins
  module Ec2
    class Provider < Vagrant.plugin('2', :provider)
      def self.set_instance_state(machine, instance_state)
        @instance_states ||= {}
        @instance_states[machine.id.to_sym] = instance_state
      end

      def self.get_instance_state(machine)
        @instance_states ||= {}
        if ! machine.id
          state = :not_created
        elsif @instance_states.has_key?(machine.id.to_sym)
          state = @instance_states[machine.id.to_sym]
        else
          state = machine.action('read_state')[:machine_state]
        end

        return state
      end

      def initialize(machine)
        @machine = machine
      end

      def action(action_method)
        return Actions.send(action_method) if Actions.respond_to?(action_method)
        nil
      end

      # This method is called if the underying machine ID changes. Providers
      # can use this method to load in new data for the actual backing
      # machine or to realize that the machine is now gone (the ID can
      # become `nil`). No parameters are given, since the underlying machine
      # is simply the machine instance given to this object. And no
      # return value is necessary.
      def machine_id_changed
      end

      # This should return a hash of information that explains how to
      # SSH into the machine. If the machine is not at a point where
      # SSH is even possible, then `nil` should be returned.
      #
      # The general structure of this returned hash should be the
      # following:
      #
      #     {
      #       :host => "1.2.3.4",
      #       :port => "22",
      #       :username => "mitchellh",
      #       :private_key_path => "/path/to/my/key"
      #     }
      #
      # **Note:** Vagrant only supports private key based authenticatonion,
      # mainly for the reason that there is no easy way to exec into an
      # `ssh` prompt with a password, whereas we can pass a private key
      # via commandline.
      def ssh_info
        return {
          :host => '127.0.0.1',
          :port => '22',
          :username => 'root',
          :private_key_path => nil
        }
      end

      # This should return the state of the machine within this provider.
      # The state must be an instance of {MachineState}. Please read the
      # documentation of that class for more information.
      def state
        state = Provider.get_instance_state(@machine)
        long = short = state.to_s
        Vagrant::MachineState.new(state, short, long)
      end
    end
  end
end
