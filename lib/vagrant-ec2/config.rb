module VagrantPlugins
  module Ec2
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :ami

      def initialize
        @ami = UNSET_VALUE
      end

      def finalize!
        #Default to "Ubuntu Server 14.04 LTS (HVM), SSD Volume Type"
        @ami = 'ami-d05e75b8' if @ami == UNSET_VALUE
      end

      def validate(machine)
        errors = []

        { 'EC2 Provider' => errors }
      end
    end
  end
end
