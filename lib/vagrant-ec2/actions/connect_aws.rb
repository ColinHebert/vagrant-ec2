require "aws-sdk"

module VagrantPlugins
  module Ec2
    module Actions
      class ConnectAWS
        def initialize(app, env)
          @app = app
        end

        def call(env)
          Aws.use_bundled_cert!
          if env[:machine].provider_config.region
            Aws.config.update({region: env[:machine].provider_config.region})
          end
          @app.call(env)
        end
      end
    end
  end
end
