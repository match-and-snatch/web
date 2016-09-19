# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'ubuntu/trusty64'
  config.vm.provision 'ansible' do |ansible|
    ansible.playbook = 'deploy/vagrant.yml'
    ansible.inventory_path = 'deploy/inventory_vagrant'
    ansible.sudo = true
    ansible.extra_vars = {ansible_ssh_user: 'vagrant'}
    ansible.verbose = 'vvvv'
  end

  config.vm.network :forwarded_port, guest: 3000, host: 3001
  config.vm.network :forwarded_port, guest: 1080, host: 1081

  config.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id, '--memory', '2048', '--name', 'connectpal_dev']
  end

  config.vm.synced_folder ".", "/home/vagrant/app"

  config.ssh.forward_agent = true
end
