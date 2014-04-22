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

1. Download Vagrant 1.4 (1.5 is currently broken with libvirt)
2. Download the vagrant-libvirt plugin : `vagrant plugin install vagrant-libvirt`
3. Check out submodules :
```
cd /path/to/puppet-archipel
git submodule init
git submodule update --recursive
```
4. `cd vagrant/archipel`
5. Bring up the environment with `vagrant up`
6. Your Archipel hacking environment will be ready in minutes.
