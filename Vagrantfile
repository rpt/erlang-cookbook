# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.hostname = 'erlang'

  config.vm.box = 'centos-6.4-64-minimal'
  # config.vm.box = 'ubuntu-12.04.2-64-server'

  # config.berkshelf.enabled = true

  config.vm.provision :chef_solo do |chef|
    # chef.add_recipe 'apt'
    chef.add_recipe 'erlang'
  end
end
