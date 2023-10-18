Vagrant.require_version ">= 2.4.0"

RKE2_VERSION               = "v1.28.2+rke2r1"
RKE2_TOKEN                 = "vagrant-rke2"
K9S_VERSION                = "v0.27.4"
DOMAIN                     = "rke2.lab"
RKE2_SERVER_DOMAIN         = "server.#{DOMAIN}"
RKE2_SERVER_URL            = "https://#{RKE2_SERVER_DOMAIN}:9345"
NUMBER_OF_NIX_SERVER_NODES = 1
NUMBER_OF_NIX_AGENT_NODES  = 0
NUMBER_OF_WIN_AGENT_NODES  = 1

def generate_nodes(count, name_prefix, cpu, memory)
  (1..count).map do |n|
    name = "#{name_prefix}#{n}"
    fqdn = "#{name}.#{DOMAIN}"
    [name, fqdn, cpu, memory, n]
  end
end

NIX_SERVER_NODES = generate_nodes(NUMBER_OF_NIX_SERVER_NODES, 'nixs', 2, 4*1024)
NIX_AGENT_NODES  = generate_nodes(NUMBER_OF_NIX_AGENT_NODES, 'nixa', 2, 4*1024)
WIN_AGENT_NODES  = generate_nodes(NUMBER_OF_WIN_AGENT_NODES, 'wina', 4, 8*1024)

Vagrant.configure("2") do |config|
  # configure ssh
  config.ssh.insert_key = false

  # set common Vagrant settings
  config.vagrant.plugins = ["vagrant-hostmanager"]

  # configure hostmanager
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true
  config.hostmanager.manage_guest = true

  # set common Hyper-V settings
  config.vm.provider "hyperv"
  config.vm.provider "hyperv" do |h|
    h.linked_clone = true
    h.maxmemory = nil # disables dynamic memory
  end

  # set default Hyper-V switch to use
  config.vm.network "private_network", bridge: "Default Switch"

  # disable default synced folder
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # define rke2 linux servers
  NIX_SERVER_NODES.each do |name, fqdn, cpu, memory, n|
    config.vm.define name do |config|
      config.vm.box = "generic/ubuntu2204"
      config.vm.guest = :linux
      config.vm.hostname = fqdn
      config.vm.provider "hyperv" do |h|
        h.cpus = cpu
        h.memory = memory
      end

      config.hostmanager.aliases = [RKE2_SERVER_DOMAIN, "sample.rke2-test.lab", "longhorn.rke2-test.lab" , "cm-xm.rke2-test.lab", "id-xm.rke2-test.lab"]

      config.vm.provision "configure", type: "shell", path: "server/configure.sh"
      config.vm.provision "install RKE2 server", type: "shell", path: "server/install-server.sh", args: [n == 1 ? "cluster-init" : "cluster-join", RKE2_VERSION, RKE2_TOKEN, RKE2_SERVER_URL]
      config.vm.provision "install k9s", type: "shell", path: "server/install-k9s.sh", args: [K9S_VERSION]
    end
  end

  # define rke2 linux agents
  NIX_AGENT_NODES.each do |name, fqdn, cpu, memory, n|
    config.vm.define name do |config|
      config.vm.box = "generic/ubuntu2204"
      config.vm.guest = :linux
      config.vm.hostname = fqdn
      config.vm.provider "hyperv" do |h|
        h.cpus = cpu
        h.memory = memory
      end

      config.vm.provision "configure", type: "shell", path: "agent/linux/configure.sh"
      config.vm.provision "install RKE2 agent", type: "shell", path: "agent/linux/install-agent.sh", args: [RKE2_VERSION, RKE2_TOKEN, RKE2_SERVER_URL]
    end
  end

  # define rke2 windows agents
  WIN_AGENT_NODES.each do |name, fqdn, cpu, memory, n|
    config.vm.define name do |config|
      config.vm.box = "gusztavvargadr/windows-server-2022-standard-core"
      config.vm.guest = :windows
      config.vm.hostname = name
      config.vm.provider "hyperv" do |h|
        h.cpus = cpu
        h.memory = memory
      end

      config.vm.provision "configure", type: "shell", path: "agent/windows/configure.ps1", reboot: true
      config.vm.provision "install RKE2 agent", type: "shell", path: "agent/windows/install-agent.ps1", args: [RKE2_VERSION, RKE2_TOKEN, RKE2_SERVER_URL]
    end
  end
end