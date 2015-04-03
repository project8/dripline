'''
this is funamentally a clone of node.py
I don't like the way it works and am going to try and make something that is cleaner
'''

from __future__ import absolute_import

import uuid

from .connection import Connection
from .message import Message
from .provider import Provider
from .endpoint import Endpoint
import logging

__all__ = ['Portal']
logger = logging.getLogger(__name__)


class Portal(object):
    """
    Like a node, but pythonic
    """
    def __init__(self, name, broker):
        self.name = name
        logger.info('connecting to broker {}'.format(broker))
        try:
            self.conn = Connection(broker, queue_name='reply-{}'.format(self.name))
        except Exception as err:
            logger.error('connection to broker failed!!')
            raise err

        self.providers = {}

    def add_provider(self, provider):
        '''
        '''
        if provider.name in self.providers:
            raise ValueError('provider ({}) already present'.format(provider.name))
        self.providers[provider.name] = provider

    def create_bindings(self):
        '''
        '''
        for provider in self.providers.keys():
            self._bind_endpoints(self.providers[provider])

    def _bind_endpoints(self, instance):
        '''
        '''
        logger.info('now bindings for: {}'.format(instance.name))
        if isinstance(instance, Provider):
            for child in instance.endpoints.keys():
                self._bind_endpoints(instance.endpoints[child])
        if isinstance(instance, Endpoint):
            logger.debug('creating binding for: {}'.format(instance.name))
            self.bind_endpoint(instance)

    def bind_endpoint(self, endpoint):
        """
        Bind an endpoint to the dripline node.  Once an endpoint is bound by
        name, it has an address and may be found on the dripline node by
        that name.
        """
        self.bind(endpoint)
        setattr(endpoint, 'store_value', self.conn.send_alert)
        endpoint.report_log = self.conn.send_alert

    def bind(self, endpoint):
        """
        Bind an arbitrary set of set/get/config functions to the
        dripline node.  Note that currently this cannot be called
        directly in a configuration file!  It is only used internally
        by dripline.
        """
        queue_name = 'portal-{}:{}'.format(self.name, endpoint.name)
        try:
            ep_queue = self.conn.chan.queue_declare(queue_name,
                                                    exclusive=True,
                                                    auto_delete=True,
                                                   )
        except pika.exceptions.ChannelClosed:
            logger.error('endpoint queue "{}" already exists, queue names must be unique'.format(queue_name))
            return


        self.conn.chan.queue_bind(exchange='requests',
                                  queue=ep_queue.method.queue,
                                  routing_key=endpoint.name)
        self.conn.chan.basic_consume(endpoint.handle_request,
                                     queue=ep_queue.method.queue,
                                     no_ack=True,
                                    )

    # TODO: god these names are awkward, who came up with this???
    # do these even ever get used?
    def provider_list(self):
        return self.providers.keys()

    def provider_endpoints(self, provider):
        return self.providers[provider].list_endpoints()

    def locate_provider(self, endpoint):
        for p, data in self.providers.iteritems():
            if endpoint in data.list_endpoints():
                return data
        return None

    def start_event_loop(self):
        """
        Start the event loop for processing messages.
        """
        logger.info('starting event loop for node {}'.format(self.name))
        self.conn.start()

    def config(self):
        """
        Return the YAML string representation of this dripline Node's
        configuration.
        """
        return self.conf.yaml_conf
