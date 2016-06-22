require 'vagrant'

module VagrantPlugins
  module VSphereDDNS
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :host
      attr_accessor :ssh_timeout

      def initialize
        @host = nil
        @ssh_timeout = nil
      end
      
      def finalize!
        @ssh_timeout = 120 if @ssh_timeout.nil?
      end
      
      def validate(machine)
        errors = _detected_errors
        { 'vagrant-vsphere-ddns' => errors }
      end
    end
  end
end
