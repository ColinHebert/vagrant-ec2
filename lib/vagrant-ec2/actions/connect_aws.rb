require 'aws-sdk'

module VagrantPlugins
  module Ec2
    module Actions
      class ConnectAWS
        def initialize(app, env)
          @app = app
        end

        def call(env)
          Aws.use_bundled_cert!

          env[:connection_options] = {}
          if env[:machine].provider_config.region
            env[:connection_options][:region] = env[:machine].provider_config.region
          end
          if env[:machine].provider_config.credentials
            env[:connection_options][:credentials] = create_credentials(env[:machine].provider_config.credentials)
          end

          @app.call(env)
        end

        def create_credentials(credentials)
          obtained_credentials = nil
          if credentials[:type] == :credentials
            # Basic credentials
            obtained_credentials = Aws::Credentials.new(
              credentials[:access_key_id],
              credentials[:secret_access_key],
              credentials[:session_token]
            )
          elsif credentials[:type] == :shared
            # Shared credentials from AWS-CLI
            obtained_credentials = Aws::SharedCredentials.new(credentials[:options])
          elsif credentials[:type] == :instance_profile
            # Instance profile credentials
            obtained_credentials = Aws::InstanceProfileCredentials.new(credentials[:options])
          elsif credentials[:type] == :assume_role
            # Assume role

            # Obtain nested credentials to assume role
            if credentials[:credentials]
              credentials[:options][:credentials] = create_credentials(credentials[:credentials])
            end

            obtained_credentials = Aws::AssumeRoleCredentials.new(
              client: Aws::STS::Client.new(credentials[:options]),
              role_arn: credentials[:arn],
              role_session_name: credentials[:session_name]
            )
          end

          return obtained_credentials
        end
      end
    end
  end
end
