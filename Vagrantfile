Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
    vb.customize ["modifyvm", :id, "--memory", "4096"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]
  end

  config.vm.provision :docker

  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y build-essential multistrap qemu-user-static
  SHELL
end
