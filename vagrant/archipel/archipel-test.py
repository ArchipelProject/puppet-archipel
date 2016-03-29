#!/usr/bin/python -W ignore::DeprecationWarning
# -*- coding: utf-8 -*-
#
# archipel-test
#
# Copyright (C) 2016 Cyril Peponnet <cyril@peponnet.fr>
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import os
import sys
import argparse
import ConfigParser
import socket

from archipelcore import xmpp
from archipelcore.scriptutils import *


adef = '''<domain type='qemu'><memory>1</memory><currentMemory>1</currentMemory><vcpu>1</vcpu><os><type machine='pc-i440fx-rhel7.0.0' arch='x86_64'>hvm</type><boot dev='hd'/></os><clock offset='utc'/><on_poweroff>destroy</on_poweroff><on_reboot>restart</on_reboot><on_crash>restart</on_crash><features><acpi/><apic/></features><memoryBacking/><blkiotune/><devices><graphics type='vnc' keymap='en-us' autoport='yes'/><input type='tablet' bus='usb'/></devices><memtune/></domain>'''


def create_vm(xmppclient, hypervisor, name, callback=None, args=None):
    """
    Create a new vm
    """
    def on_created(con, iq):
        if iq.getType() == "result":
            if callback:
                if args:
                    callback(**args)
                else:
                    callback()

    create_iq = xmpp.Iq(typ="set", to=hypervisor)
    query     = create_iq.addChild("query", namespace="archipel:hypervisor:control")
    action    = query.addChild("archipel", attrs={"action":'alloc', 'name':name, 'orgname':'', 'orgunit':'', 'locality':'', 'userid':'', 'categories':''})
    action.addChild('domain', node=xmpp.simplexml.NodeBuilder(adef).getDom())
    xmppclient.SendAndCallForResponse(create_iq, on_created)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-n", "--name",
                        dest="name",
                        help="The the prefix name of the agent to start.",
                        metavar="agent",
                        default="agent")
    parser.add_argument("-c", "--count",
                        dest="count",
                        help="The number of agent to start.",
                        metavar="1",
                        default=1)
    parser.add_argument("-f", "--config-file",
                        dest="config",
                        help="The configuration file to use as template.",
                        default="/etc/archipel/archipel.conf")
    parser.add_argument("--spawn",
                        dest="spawn",
                        help="Spawn hypervisor processes",
                        action="store_true",
                        default=False)
    parser.add_argument("--vms",
                        dest="vms",
                        help="Create some vms on each hyp",
                        action="store_true",
                        default=False)
    parser.add_argument("--vm-name",
                        help="Base name of vm",
                        default="vm")
    parser.add_argument("--vm-number",
                        help="Number of vm to create",
                        default=5)
    parser.add_argument("-j", "--jid",
                        dest="jid",
                        help="set the JID to use",
                        default="admin@central-server.archipel.priv")
    parser.add_argument("-p", "--password",
                        dest="password",
                        help="set the password associated to the JID",
                        default='admin')

    options = parser.parse_args()

    if not os.path.isfile(options.config):
        print "Cannot find the configuration file %s" % options.config
        sys.exit(1)

    config = ConfigParser.RawConfigParser()
    config.read(options.config)

    if options.spawn:
        print "Spawning %s hypervisor processes" % options.count
        var = config.get('DEFAULT', "archipel_folder_lib")

        for num in range(0, int(options.count)):
            print "Spawning %s-%s..." % (options.name, num)
            var_p = "%s/%s-%s" % (var, options.name, num)
            conf = '/tmp/%s-%s.conf' % (options.name, num)
            if not os.path.exists(var_p):
                os.makedirs(var_p)
            config.set('DEFAULT', "archipel_folder_lib", var_p)
            config.set('HYPERVISOR', "hypervisor_xmpp_jid", "%s-%s@%%(xmpp_server)s" % (options.name, num))
            config.set('LOGGING', 'logging_file_path', "/var/log/archipel/%s-%s.log" % (options.name, num))
            config.set('HYPERVISOR', 'name_generation_file', '/var/lib/archipel/names.txt')
            config.set('GLOBAL', 'machine_avatar_directory', '/var/lib/archipel/avatars')
            config.set('HYPERVISOR', 'hypervisor_name', "%s-%s" % (options.name, num))

            with open(conf, 'wb') as configfile:
                config.write(configfile)
            os.system('runarchipel -c %s' % conf)

    if options.vms:
        xmppclient = initialize(options, fill_pubsubserver=False)
        print "Create %s vms per hyp" % options.vm_number
        for num in range(0, int(options.count)):
            for vm in range(0, options.vm_number):
                name = "%s-%s-%s-%s" % (options.name, num, options.vm_name, vm)
                hypervisor = "%s-%s@%s/%s" % (options.name, num, config.get('DEFAULT', 'xmpp_server'), socket.gethostname())
                create_vm(xmppclient, hypervisor, name)
