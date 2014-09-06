""" kv_store.py
A simple key-value store which is a dripline provider.
The endpoints of this provider are associated with
keys, and are determined by the configuration file.
For example, if the configuration file has a provider
section that looks like this:
providers:
    - name: kv_example
      module: kv_store
      endpoints:
        -name: 'foo'
         module: 'kv_store_key'
        -name: 'bar'
         module: 'kv_store_key'
        -name: 'baz'
         module: 'kv_store_key'
Then the KV store will have three keys, foo, bar, and
baz, which are associated with it.  They can be addressed
as such on the network, or can also be addressed using their
fully qualified hierarchical address e.g. somenode.kv.foo.
"""
from provider import Provider
from endpoint import Endpoint

class KVStore(Provider):
    """
    The KV store.  This is just a wrapper around a dict.
    """
    def __init__(self, name):
        self.name = name
        self.dict = {}
        self.endpoints = {}

    def add_endpoint(self, endpoint):
        """
        Add an endpoint to the KV store.  The keys are
        the endpoint names, and the values are a tuple
        of the value, and the endpoint itself.
        """
        endpoint.provider = self
        self.endpoints[endpoint.name] = endpoint
        self.dict[endpoint.name] = endpoint.initial_value

    def endpoint(self, endpoint):
        """
        Return the endpoint associated with some key.
        """
        return self.endpoints[endpoint]

    def list_endpoints(self):
        """
        List all endpoints associated with this KV store.
        This is the same as enumerating the keys in the
        dict.
        """
        return self.dict.keys()

    def __getitem__(self, name):
        return self.dict[name]

    def __setitem__(self, name, value):
        self.dict[name] = value

class KVStoreKey(Endpoint):
    """
    A key in the KV store.
    """
    # TODO: initial_value keyword arg would be nifty
    def __init__(self, name, initial_value=None):
        self.name = name
        self.provider = None
        self.initial_value = initial_value

    def on_get(self):
        """
        Return the value associated with this
        key.
        """
        value = self.provider[self.name]
        return value

    def on_set(self, value):
        """
        Set the value associated with this key
        to some new value.
        """
        self.provider[self.name] = value

    def on_config(self):
        """
        Configuring a key is not defined.
        """
        return NotImplementedError

