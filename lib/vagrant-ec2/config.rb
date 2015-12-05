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

      # Run options for the instance
      #
      # @return [Hash]
      attr_accessor :run_options

      # Tags associated with the instance
      #
      # @return [Hash]
      attr_accessor :tags

      def initialize
        @ami         = UNSET_VALUE
        @region      = UNSET_VALUE
        @credentials = UNSET_VALUE
        @run_options = UNSET_VALUE
        @tags        = UNSET_VALUE
      end

      def finalize!
        @ami         = nil if @ami == UNSET_VALUE
        @region      = nil if @region == UNSET_VALUE
        @credentials = nil if @credentials == UNSET_VALUE
        @run_options = nil if @run_options == UNSET_VALUE
        @tags        = {}  if @tags == UNSET_VALUE

        if run_options.is_a?(Hash)
          @run_options[:image_id] = @ami if @ami != nil
          @run_options[:min_count] = 1
          @run_options[:max_count] = 1
        end
      end

      def validate(machine)
        errors = []

        errors += validate_credentials(@credentials)
        errors += validate_run_options(@run_options)
        errors << 'Tags should be a hash of key-values' if ! tags.is_a?(Hash)

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

      def validate_run_options(run_options)
        errors = []

        if run_options == nil || ! run_options.is_a?(Hash)
          return ['run_options not set properly!']
        end

        errors << 'image_id not set' if ! run_options[:image_id]
        errors << 'instance_type not set' if ! run_options[:instance_type]
        return errors
      end
    end
  end
end
