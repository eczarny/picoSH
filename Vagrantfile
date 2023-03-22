Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu2204"

  config.vm.provider :libvirt do |v|
    v.memory = 4096
  end

  config.vm.synced_folder ".", "/vagrant", type: "rsync",
    rsync__exclude: ".git/"

  config.vm.provision :docker

  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y build-essential multistrap qemu-user-static
  SHELL
end
