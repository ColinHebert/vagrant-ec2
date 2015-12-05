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

      # Credentials used to log in.
      #
      # @return [Hash]
      attr_accessor :credentials

      def initialize
        @ami         = UNSET_VALUE
        @region      = UNSET_VALUE
        @credentials = UNSET_VALUE
      end

      def finalize!
        @ami    = nil if @ami == UNSET_VALUE
        @region = nil if @region == UNSET_VALUE
        @credentials = nil if @credentials == UNSET_VALUE
      end

      def validate(machine)
        errors = []

        errors += validate_credentials(@credentials)

        { 'EC2 Provider' => errors }
      end

      def validate_credentials(credentials)
        errors = []

        if credentials == nil
          # Nothing can make it fail here.
        elsif ! credentials.is_a?(Hash)
          errors << 'The credentials should be in a hash'
        elsif credentials[:type] == :credentials
          errors << 'An Access Key ID MUST be given' if !credentials[:access_key_id]
          errors << 'An Access Key secret MUST be given' if !credentials[:secret_access_key]
        elsif credentials[:type] == :shared
          # Nothing can make it fail here.
        elsif credentials[:type] == :instance_profile
          # Nothing can make it fail here.
        elsif credentials[:type] == :assume_role
          errors << 'A role ARN to assume MUST be given' if !credentials[:arn]
          credentials[:session_name] ||= 'vagrant-ec2_session'
          credentials[:options] ||= Hash.new
          errors += validate_credentials(credentials[:credentials])
        else
          errors << 'Invalid credential type {}'
        end

        return errors
      end
    end
  end
end
