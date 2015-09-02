puppet-archipel
===============

The puppet-archipel module installs, configures and manages an Archipel cluster.

It is under development and for now only works with developer mode of Archipel.

Classes
-------

* archipel::agent : hypervisor running archipel agent
* archipel::central_server : archipel central agent
* ejabberd: deal with ejabberd installation

Vagrant
-------

See the vagrant/ directory for Archipel-in-a-box configuration allowing you to develop on ArchipelAgent on your laptop.

Here is how to create a development environment in a jiffy:

#### Using libvirt as provider

1. Download Vagrant 1.7
2. Download the vagrant-libvirt plugin : `vagrant plugin install vagrant-libvirt`

#### Using virtualbox (default provider)

1. Download and install Vagrant for your OS
2. Download and install virtualbox

#### Common

3. Check out submodules:

```
cd /path/to/puppet-archipel
git submodule init
git submodule update --remote --recursive

cd /path/to/puppet-archipel/vagrant/archipel/Archipel
./pull.sh
```

4. Switch off the firewalld if under Redhat/Centos 7 or Fedora Linux environment for vagrant shared folder to be mounted:

```
sudo systemctl stop firewalld
```

5. `cd /path/to/puppet-archipel/vagrant/archipel`
6. Bring up the environment with `vagrant --agent-count=3 up`, this will bring a 3 nodes environment
7. Your Archipel hacking environment will be ready in minutes and will prompt a ready to use URL as the first line of the vagrant command above like:
```
http://192.168.122.2/Archipel/?user=admin%40central-server.archipel.priv&password=admin&service=ws://192.168.122.2:5280/xmpp
```

Developers
----------

Archipel source code is located in vagrant/archipel/Archipel. All modifications to the Archipel Agent code will be applied to all VMs.
Except for the UI as it use a precompiled release from nightlies.

Have fun!
