module VagrantPlugins
  module Ec2
    class Config < Vagrant.plugin('2', :config)
      # The ID of the AMI to use.
      #
      # @return [String]
      attr_accessor :ami

      # AWS region in which the instances run.
      #
      # @return [String]
      attr_accessor :region

      def initialize
        @ami    = UNSET_VALUE
        @region = UNSET_VALUE
      end

      def finalize!
        @ami    = nil if @ami == UNSET_VALUE
        @region = nil if @region == UNSET_VALUE
      end

      def validate(machine)
        errors = []

        { 'EC2 Provider' => errors }
      end
    end
  end
end
