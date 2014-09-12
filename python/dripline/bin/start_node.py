""" start_node.py
Starts a dripline node and connects to a dripline mesh based on a configuration
file passed in with the 'c' flag, or '--config'.
"""
import argparse
#from config import Config
#from node import Node
from dripline.core import Config, Node
from dripline import instruments

# Argument parser setup
PARSER = argparse.ArgumentParser(description='Start a dripline node.')
PARSER.add_argument('-c',
                    '--config',
                    metavar='configuration file',
                    help='full path to a dripline YAML configuration file.')

def main():
    args = PARSER.parse_args()

    if args.config is not None:
        conf = Config(args.config)
        node = Node(conf)
        if conf.provider_count() > 0:
            for name, items in conf.providers.iteritems():
                provider_cls = getattr(instruments, items['module'])
                provider = provider_cls(name, items)
                endpoints = []
                for endpoint in items['endpoints']:
                    end_cls = getattr(instruments, endpoint.pop('module'))
                    end_name = endpoint.pop('name')
                    endpoints.append(end_cls(end_name, **endpoint))
            node.extend_object_graph(provider, endpoints)
        node.start_event_loop()
    else:
        print("oh")

if __name__ == '__main__':
    main()
