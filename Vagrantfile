# -*- mode: ruby -*-
# vi: set ft=ruby :

coreos_linux_update_channel = "alpha"

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # always use Vagrant's insecure key
  config.ssh.insert_key = false

  config.vm.box = "coreos-%s" % coreos_linux_update_channel
  config.vm.box_version = ">= 766.0.0"
  config.vm.box_url = "http://%s.release.core-os.net/amd64-usr/current/coreos_production_vagrant.json" % coreos_linux_update_channel

  # plugin conflict
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end

  config.vm.define vm_name = "rkt-machine" do |machine|
    machine.vm.hostname = vm_name

    machine.vm.provider :virtualbox do |vb|
      vb.cpus = 1
      vb.gui = false
      vb.memory = 2048
    end

    machine.vm.network :private_network, ip: "172.17.5.100"
    machine.vm.synced_folder "_output/", "/vagrant"
  end
end
