require 'aws-sdk'

module VagrantPlugins
  module Ec2
    module Actions
      class FindHost
        def initialize(app, env)
          @app = app
        end

        def call(env)
          if env[:machine].id && ! env[:machine_host]
            ec2 = Aws::EC2::Resource.new(env[:connection_options])
            instance = ec2.instance(env[:machine].id)

            if env[:machine].provider_config.host_attribute == :public_ip
              env[:machine_host] = instance.public_ip_address
            elsif env[:machine].provider_config.host_attribute == :public_dns
              env[:machine_host] = instance.public_dns_name
            elsif env[:machine].provider_config.host_attribute == :private_ip
              env[:machine_host] = instance.private_ip_address
            elsif env[:machine].provider_config.host_attribute == :private_dns
              env[:machine_host] = instance.private_dns_name
            else
              env[:machine_host] = instance.public_ip_address
              env[:machine_host] ||= instance.public_dns_name[/.+/]
              env[:machine_host] ||= instance.private_ip_address
              env[:machine_host] ||= instance.private_dns_name[/.+/]
            end
          end

          @app.call(env)
        end
      end
    end
  end
end
