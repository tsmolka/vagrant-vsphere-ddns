[![Build Status](https://travis-ci.org/tsmolka/vagrant-vsphere-ddns.svg?branch=master)](https://travis-ci.org/tsmolka/vagrant-vsphere-ddns) [![Gem Version](https://badge.fury.io/rb/vagrant-vsphere-ddns.svg)](http://badge.fury.io/rb/vagrant-vsphere-ddns)

# Vagrant vSphere DDNS plugin

This is a PoC [Vagrant](http://www.vagrantup.com) plugin that enables Vagrant to connect to vSphere VMs via dynamic domain names based on MAC addresses. 
This trivial plugin enables SSH connection to VMs that do not have guest tools installed. 

This plugin does not work out of the box and requires custom DHCP and DNS settings. 
This configuration is however not implemented in the plugin itself and has to be performed manually in advance. 

## Requirements

* [Vagrant] (http://www.vagrantup.com)
* [vagrant-vsphere](https://github.com/nsidc/vagrant-vsphere) plugin

## Usage

Plugin can be configured by following settings:
 * `ddns.host`
   * Hostname that will be used for SSH connections instead of guest IP address
   * Patterns mac0, mac1, ... will be replaced by VMs MAC address
 * `ddns.timeout`
   * Defines how long the plugin will wait for successfull DNS resolution (default is 120 seconds)
   
```ruby
Vagrant.configure("2") do |config|
  config.vm.box = 'dummy-vsphere-box'
  
  config.ddns.host = "%{mac0}.local"
  config.ddns.timeout = 120
  
  config.vm.provider :vsphere do |vsphere|
    vsphere.host = 'HOST NAME OF YOUR VSPHERE INSTANCE'
    vsphere.compute_resource_name = 'YOUR COMPUTE RESOURCE'
    vsphere.resource_pool_name = 'YOUR RESOURCE POOL'
    vsphere.template_name = '/PATH/TO/YOUR VM TEMPLATE'
    vsphere.name = 'NEW VM NAME'
    vsphere.user = 'YOUR VMWARE USER'
    vsphere.password = 'YOUR VMWARE PASSWORD'
  end
end
```

After running `vagrant up --provider=vsphere` Vagrant will attempt to reach VM using specified domain name
(e.g. `005056a44d89.local`) and fail if it can not be resolved for 2 minutes. 

## DHCP and DNS settings

 * Allow dynamic DNS updates in Bind in `/etc/bind/named.conf.local`
```bash
...
include "/etc/bind/ddns.key";

zone ".local" {
    type master;
    forwarders {};
	file "/var/lib/bind/db.local";
    allow-update { key dhcpupdate; };
};
...
```
 * Execute [custom script](./scripts/dns_update.py) on DHCP events in `/etc/dhcp/dhcpd.conf`
```bash
...
on commit {
    execute("/etc/dhcp/dns_update.py", 
        "--action", "commit", 
        "--ip", binary-to-ascii(10, 8, ".", leased-address),
        "--mac", binary-to-ascii(16, 8, ":", substring(hardware, 1, 6)),
        "--zone", config-option domain-name,
        "--key_file", "/etc/dhcp/ddns.key"
    );
}
on release {
    execute("/etc/dhcp/dns_update.py",
        "--action", "release", 
        "--ip", binary-to-ascii(10, 8, ".", leased-address),
        "--mac", binary-to-ascii(16, 8, ":", substring(hardware, 1, 6)),
        "--zone", config-option domain-name,
        "--key_file", "/etc/dhcp/ddns.key"
    );
}
on expiry {
    execute("/etc/dhcp/dns_update.py", 
        "--action", "expiry", 
        "--ip", binary-to-ascii(10, 8, ".", leased-address),
        "--mac", binary-to-ascii(16, 8, ":", substring(hardware, 1, 6)),
        "--zone", config-option domain-name,
        "--key_file", "/etc/dhcp/ddns.key"
    );
}
...
```
