require 'aws-sdk'

module VagrantPlugins
  module Ec2
    module Actions
      class StartInstance
        def initialize(app, env)
          @app = app
        end

        def call(env)
          ec2 = Aws::EC2::Resource.new(env[:connection_options])

          instance = ec2.instance(env[:machine].id)
          instance.start
          env[:ui].info I18n.t('vagrant_ec2.info.action.start_instance', :instance_id => env[:machine].id)

          @app.call(env)
        end
      end
    end
  end
end
