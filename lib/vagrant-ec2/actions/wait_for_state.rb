require 'aws-sdk'

module VagrantPlugins
  module Ec2
    module Actions
      class WaitForState
        def initialize(app, env, state)
          @app = app
          @state = state
        end

        def call(env)
          ec2 = Aws::EC2::Resource.new(env[:connection_options])
          instance = ec2.instance(env[:machine].id)

          if @state == :running
            instance.wait_until_running
            env[:machine_state] = instance.state.name.to_sym
          elsif @state == :stopped
            instance.wait_until_stopped
            env[:machine_state] = instance.state.name.to_sym
          elsif @state == :terminated
            instance.wait_until_terminated
            env[:machine_state] = :not_created
          else
            #Lolwut?
          end

          Provider.set_instance_state(env[:machine], env[:machine_state])
          env[:machine].id = nil if env[:machine_state] === :not_created

          @app.call(env)
        end
      end
    end
  end
end
