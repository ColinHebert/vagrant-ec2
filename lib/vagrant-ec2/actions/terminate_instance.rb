require 'aws-sdk'

module VagrantPlugins
  module Ec2
    module Actions
      class TerminateInstance
        def initialize(app, env)
          @app = app
        end

        def call(env)
          ec2 = Aws::EC2::Resource.new(env[:connection_options])

          instance = ec2.instance(env[:machine].id)
          instance.terminate

          @app.call(env)
        end
      end
    end
  end
end