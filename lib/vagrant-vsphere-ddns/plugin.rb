begin
    require 'vagrant'
rescue LoadError
    raise 'The plugin must be run within Vagrant.'
end

module VagrantPlugins
    module VSphereDDNS
        class Plugin < Vagrant.plugin('2')
            name 'vsphere-ddns'
            description 'Enables Vagrant to connect to vSphere VMs via dynamic domain names based on MAC addresses'
            
            config(:ddns) do
                require_relative 'config'
                init!
                Config
            end
            
            action_hook :get_ssh_info, :machine_action_get_ssh_info do |hook|
                require_relative 'action'
                hook.after VagrantPlugins::VSphere::Action::GetSshInfo, VagrantPlugins::VSphereDDNS::Action::action_get_ssh_info
            end
            
            protected
            
            def self.init!
                return if defined?(@_init)
                I18n.load_path << File.expand_path('locales/en.yml', VagrantPlugins::VSphereDDNS.source_root)
                I18n.reload!
                @_init = true
            end
            
        end
    end
end
