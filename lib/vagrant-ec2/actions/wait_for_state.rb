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

          case @state
          when :running
            instance.wait_until_running
            Provider.set_instance_state(env[:machine], instance.state.name.to_sym)
          when :stopped
            instance.wait_until_stopped
            Provider.set_instance_state(env[:machine], instance.state.name.to_sym)
          when :terminated
            instance.wait_until_terminated
            Provider.set_instance_state(env[:machine], :not_created)
            env[:machine].id = nil
          else
            #TODO: Lolwut?
          end

          @app.call(env)
        end
      end
    end
  end
end
