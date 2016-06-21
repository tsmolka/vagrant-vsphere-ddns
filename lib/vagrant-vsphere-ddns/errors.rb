require 'vagrant'

module VagrantPlugins
  module VSphereDNS
    module Errors
      class VSphereDDNSError < Vagrant::Errors::VagrantError
        error_namespace("vagrant-vsphere-ddns.errors")
      end

      class IPAddrTimeout < VSphereDDNSError
        error_key(:ip_addr_timeout)
      end
    end
  end
end
