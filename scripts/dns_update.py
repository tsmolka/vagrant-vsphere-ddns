#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import argparse
import logging
import subprocess

if __name__=='__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--debug', action='store_true', default=False)
    parser.add_argument('-a','--action',  choices=('commit', 'release', 'expiry'), required=True)
    parser.add_argument('-i','--ip',  required=True)
    parser.add_argument('-m','--mac',  required=True)
    parser.add_argument('--key_file',  required=True)
    parser.add_argument('--server',  default='127.0.0.1')
    parser.add_argument('--ttl', type=int, default=600)
    parser.add_argument('--zone',  required=True)
    
    args = parser.parse_args()
    logging.basicConfig(level=(logging.DEBUG if args.debug else logging.INFO), format='%(asctime)s %(levelname)-5.5s [%(name)s] %(message)s')    
    logging.debug('arguments: %s' % sys.argv)
        
    mac = ''.join([format(int(x, 16), '02x') for x in args.mac.replace('-',':').split(':')])
    
    params = "server %s\nzone %s\n" % (args.server, args.zone)
    if args.action == 'commit':        
        params += "update add %s.%s %d IN A %s\n" % (mac, args.zone, args.ttl, args.ip)
    else:
        params += "update delete %s.%s. A\n" % (mac, args.zone)
    if args.debug:
        params += "show\n"
    params += "send\n"
    
    logging.debug('nsupdate params: %s' % params)
    ret = subprocess.call('/usr/bin/nsupdate -k %s -v << EOF\n%s\nEOF' % (args.key_file, params), shell=True)
    logging.debug('nsupdate returned %d' % (ret))
    sys.exit(ret)
