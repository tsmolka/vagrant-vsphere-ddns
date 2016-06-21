# coding: utf-8
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'vagrant-vsphere-ddns/version'

Gem::Specification.new do |s|
    s.name = 'vagrant-vsphere-ddns'
    s.version = VagrantPlugins::VSphereDDNS::VERSION
    s.authors = ['Tobias']
    s.email = ['tsmolka@gmail.com']
    s.homepage = 'https://github.com/tsmolka/vagrant-vsphere-ddns'
    s.license = 'GPL-2.0'
    s.summary = 'VMWare vSphere DDNS plugin'
    s.description = 'Enables Vagrant to connect to vSphere VMs via dynamic domain names based on MAC addresses'
    root_path      = File.dirname(__FILE__)
    s.add_dependency 'vagrant-vsphere', '~> 1.9'
    
    s.add_dependency 'rake'
  
    s.files = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
    s.executables = s.files.grep(/^bin\//) { |f| File.basename(f) }
    s.require_path = 'lib'
end
