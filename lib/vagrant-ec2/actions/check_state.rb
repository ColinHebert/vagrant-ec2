module VagrantPlugins
  module Ec2
    module Actions
      class CheckState
        def initialize(app, env)
          @app = app
        end

        def call(env)
          env[:machine_state] = @machine.state.id
          @app.call(env)
        end
      end
    end
  end
end
