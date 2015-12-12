module VagrantPlugins
  module Ec2
    class Plugin < Vagrant.plugin('2')
      name 'Ec2'
      description <<-DESC
        This plugin installs a provider that allows Vagrant to manage machines
        using the AWS API.
      DESC

      config(:aws, :provider) do
        require_relative 'config'
        Config
      end

      provider(:aws) do
        require_relative 'provider'
        Provider
      end
    end
  end
end
