require 'vagrant'
require 'vagrant/action/builder'

module VagrantPlugins
  module VSphereDDNS
    module Action
      include Vagrant::Action::Builtin

      def self.action_get_ssh_info
        Vagrant::Action::Builder.new.tap do |b|
          b.use GetSshInfo
          b.use WaitForIPAddress
        end
      end
      
      # autoload
      action_root = Pathname.new(File.expand_path('../action', __FILE__))
      autoload :GetSshInfo, action_root.join('get_ssh_info')
      autoload :WaitForIPAddress, action_root.join('wait_for_ip_address')
    end
  end
end
