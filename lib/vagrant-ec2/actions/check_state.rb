require 'aws-sdk'

module VagrantPlugins
  module Ec2
    module Actions
      class CheckState
        def initialize(app, env)
          @app = app
        end

        def call(env)
          if ! env[:machine].id
            env[:machine_state] = :not_created
          elsif ! env[:machine_state]
            ec2 = Aws::EC2::Resource.new(env[:connection_options])
            instance = ec2.instance(env[:machine].id)
            if ! instance.exists?
              env[:machine].id = nil
              env[:machine_state] = :not_created
            else
              env[:machine_state] = instance.state.name.to_sym
            end
            Provider.set_instance_state(env[:machine], env[:machine_state])
          end

          @app.call(env)
        end
      end
    end
  end
end
