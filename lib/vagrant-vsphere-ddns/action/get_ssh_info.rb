require 'rbvmomi'
require 'vSphere/util/vim_helpers'

module VagrantPlugins
    module VSphereDDNS
        module Action
            class GetSshInfo
                include VagrantPlugins::VSphere::Util::VimHelpers

                def initialize(app, env)
                    @app = app
                    @logger = Log4r::Logger.new("vagrant::vsphere-ddns::get_ssh_info")
                end

                def call(env)
                    env[:machine_ssh_info] = get_ssh_info(env[:vSphere_connection], env[:machine])
                    if !env[:machine_ssh_info].nil?
                        @logger.debug("SSH info: #{env[:machine_ssh_info]}")
                    else
                        @logger.debug("SSH info is nil")
                    end
                    @app.call env
                end
                
                private
                
                def get_ssh_info(connection, machine)
                    @logger.debug("machine.config.ddns.host is nil, plugin disabled") if machine.config.ddns.host.nil?
                    return nil if machine.config.ddns.host.nil?
                    @logger.warn("machine.id is nil") if machine.id.nil?
                    return nil if machine.id.nil?
                    vm = get_vm_by_uuid connection, machine
                    @logger.warn("get_vm_by_uuid is nil") if vm.nil?
                    return nil if vm.nil?
                    
                    format_data = {}
                    vm.config.hardware.device.grep(RbVmomi::VIM::VirtualEthernetCard).each_with_index do |card, id| 
                        break if card.nil?
                        format_data["mac#{id}".to_sym] = (card.macAddress.scan /[a-f0-9]/).join
                    end
                    @logger.debug("format_data: #{format_data}")
                    
                    {
                        host: machine.config.ddns.host % format_data,
                        port: (machine.config.ssh.port.nil? ? 22 : machine.config.ssh.port)
                    }
                end
                
            end
        end
    end
end
