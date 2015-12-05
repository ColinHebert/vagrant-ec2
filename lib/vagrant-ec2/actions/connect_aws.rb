module VagrantPlugins
  module Ec2
    module Actions
      class ConnectAWS
        def initialize(app, env)
          @app = app
        end

        def call(env)
          puts "hello"
          @app.call(env)
        end
      end
    end
  end
end
