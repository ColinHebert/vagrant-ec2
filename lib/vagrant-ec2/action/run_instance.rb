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

          if env[:machine].provider_config.tags.any?
            ec2.create_tags({
              resources: [env[:machine].id],
              tags: env[:machine].provider_config.tags.map { |key, value| {key: key, value: value} },
            })
          end
          env[:ui].info I18n.t('vagrant_ec2.info.action.run_instance', :instance_id => env[:machine].id)

          @app.call(env)
        end
      end
    end
  end
end
