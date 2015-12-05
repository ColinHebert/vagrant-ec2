require 'aws-sdk'

module VagrantPlugins
  module Ec2
    module Actions
      class DisconnectAWS
        def initialize(app, env)
          @app = app
        end

        def call(env)
          Aws.config{}
          @app.call(env)
        end
      end
    end
  end
end
