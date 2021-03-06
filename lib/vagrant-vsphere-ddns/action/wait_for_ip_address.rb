require 'timeout'
require 'log4r'
require 'resolv'

module VagrantPlugins
    module VSphereDDNS
        module Action
            class WaitForIPAddress
                def initialize(app, env)
                    @app = app
                    @logger = Log4r::Logger.new("vagrant::vsphere-ddns::wait_for_ip_address")
                end

                def call(env)
                    return if env[:machine_ssh_info].nil?
                    
                    host = env[:machine_ssh_info][:host]
                    timeout = env[:machine].config.ddns.ssh_timeout
                    @logger.info("Trying to resolve #{host} (timeout #{timeout} seconds)")
                    
                    Timeout.timeout(timeout) do
                        while true
                            # If a ctrl-c came through, break out
                            return if env[:interrupted]

                            begin
                                ip_address = Resolv.getaddress(host)
                                @logger.info("Host #{host} resolved to #{ip_address}")
                                break
                            rescue Resolv::ResolvError
                                @logger.warn("Could not resolve: #{host}")
                            end
                            sleep 1
                        end
                    end
                    return if env[:interrupted]
                    @app.call(env)
                    
                rescue Timeout::Error
                    raise Errors::IPAddrTimeout, host: host, timeout: timeout
                end
                
            end
        end
    end
end
