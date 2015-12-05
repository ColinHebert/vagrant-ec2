module VagrantPlugins
  module Ec2
    class Plugin < Vagrant.plugin('2')
      name 'Ec2'
      description <<-DESC
        This plugin installs a provider that allows Vagrant to manage machines
        using the AWS API.
      DESC

      config(:ec2, :provider) do
        require_relative 'config'
        Config
      end
    end
  end
end
