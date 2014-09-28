puppet-archipel
===============

The puppet-archipel module installs, configures and manages an Archipel cluster.

It is under development and for now only works with developer mode of Archipel.

Classes
-------

* archipel::agent : hypervisor running archipel agent
* archipel::central_server : ejabberd server, archipel central agent

Vagrant
-------

See the vagrant/ directory for Archipel-in-a-box configuration allowing you to develop on ArchipelAgent on your laptop.

Here is how to create a development environment in minutes :

* Under Linux using libvirt

1. Download Vagrant 1.4 (1.5 is currently broken with libvirt)
2. Download the vagrant-libvirt plugin : `vagrant plugin install vagrant-libvirt`

* Under OSX using virtualbox

1. Download Vagrant for OSX
2. Download virtualbox

3. Check out submodules :
```
cd /path/to/puppet-archipel
git submodule init
git submodule update --recursive
```
4. `cd vagrant/archipel`
5. Bring up the environment with `vagrant --agent-count=3 up`, this will bring a 3 nodes environment
6. Your Archipel hacking environment will be ready in minutes.
7. Archipel source code is located in vagrant/archipel/Archipel. All modifications to the Archipel Agent code will be applied to all VMs. Have fun!
