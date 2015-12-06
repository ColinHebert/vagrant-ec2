require 'aws-sdk'

module VagrantPlugins
  module Ec2
    module Actions
      class CheckState
        def initialize(app, env, refresh = false)
          @app = app
          @refresh = refresh
        end

        def call(env)
          if refresh && env[:machine].id
            ec2 = Aws::EC2::Resource.new(env[:connection_options])
            instance = ec2.instance(env[:machine].id)
            if instance.exists? && instance.state.name != "shutting-down" && instance.state.name != "terminated"
              Provider.set_instance_state(env[:machine], instance.state.name.to_sym])
            else
              Provider.set_instance_state(env[:machine], :not_created])
              env[:machine].id = nil
            end
          end
          env[:result] = Provider.get_instance_state(env[:machine])

          @app.call(env)
        end
      end
    end
  end
end
