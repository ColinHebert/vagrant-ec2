require 'aws-sdk'

module VagrantPlugins
  module Ec2
    module Actions
      class RunInstance
        def initialize(app, env)
          @app = app
        end

        def call(env)
          ec2 = Aws::EC2::Resource.new(env[:connection_options])

          instance = ec2.create_instances(env[:machine].provider_config.run_options)[0]
          env[:machine].id = instance.id
          instance.wait_until_running
          env[:machine_state] = instance.state.name.to_sym
          Provider.set_instance_state(env[:machine], env[:machine_state])

          @app.call(env)
        end
      end
    end
  end
end
