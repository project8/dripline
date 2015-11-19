=======
Purpose
=======
Our software packages generally communicate with one another, and interact with hardware components with messages sent using the AMQP protocol. This wire protocol was developed to standardize the format of those messages.

Version: 1.4.0
==============

History
=======

| Version | Date | Release Notes |
|:--------|:-----|:--------------|
| *Planned: 1.5.0* | | OP_CONFIG deprecated |
| 1.4.0   | Sept 16, 2015 | Added lockout_key field and return codes 1 307, and 308 |
| 1.3.0   | Sept 1, 2015 | Added return_msg field to replies |
| 1.2.0   | June 1, 2015 | Added hostname and username to sender_info |
| 1.1.0   | May, 2015 | Added `sender_info` |
| 1.0.0   | c 2000 b.c.e. | Thought to originate during the Middle Kingdom of ancient Egypt |



Message Standards
=================

Encoding
--------

The AMQP message body should be formatted in either [JSON](http://json.org) or [msgpack](http://msgpack.org).  The encoding (`application/json` or `application/msgpack`) should be specified in the `content_encoding` field of the AMQP message.

Structure
---------

| Field | Type | Required | Values |
|:------|:-----|:---------|:-------|
| `msgtype` | integer | All | Reply (2), Request (3), Alert (4), Info (5) |
| `msgop`   | integer | Requests | Set (0), Get (1), Config (6), Send (7), Run (8), Command (9) |
| `timestamp` | string | All | Following the [RFC3339](https://www.ietf.org/rfc/rfc3339.txt) format |
| `lockout_key` | string | Requests | 16 hexidecimal digits (see [lockout](#lockout)) |
| `sender_info.package` | string | All | Software package used to send the message |
| `sender_info.exe` | string | All | Full path of the executable used to send the message |
| `sender_info.version` | string | All | Sender package version |
| `sender_info.commit` | string | All | Git commit of the sender package |
| `sender_info.hostname` | string | All | Name of the host computer that sends the message |
| `sender_info.username` | string | All | User responsible for sending the message |
| `payload` | any | | The content of the message |  
| `retcode` | integer | Reply | See [table below](#return-codes) |  
| `return_msg` | string | Reply | Human-readable explanation of the return code



Return Codes
------------

The following table is direct from the current error codes as defined in dripline. I think I'd like to make some changes, but I haven't thought them through very much. Just brainstorming, I'm thinking 0-99 for success and warnings; 100-199 for errors related to AMQP (ex, errors caught from library); 200-299 for hardware related errors (interaction problems, driver exceptions, etc.); 300-399 shouldn't be 'dripline' but 'consumer', the several encoding/decoding related exceptions could probably be combined. I should discuss this with Noah w.r.t. hornet and mantis.

| Code | Description |  
|:----:|:------------|  
| 0     | Success     |  
| 1     | No action taken warning |
| 2-99  | Unassigned, non-error warnings|  
| 100   | Generic AMQP Related Error |  
| 101   | AMQP Connection Error |  
| 102   | AMQP Routing Key Error |  
|103-199| Unallocated AMQP Errors |  
| 200   | Generic Hardware Related Error |  
| 201   | Hardware Connection Error |  
| 202   | Hardware no Response Error |  
|203-299| Unallocated Hardware Errors|  
| 300   | Generic Dripline Error |  
| 301   | No message encoding error |  
| 302   | Decoding Failed Error |  
| 303   | Payload related error |  
| 304   | Value Error |  
| 305   | Timeout |  
| 306   | Method not supported |  
| 307   | Access denied |
| 308   | Invalid key |
|308-399| Unallocated Dripline errors|  
| 400   | Generic Database Error |  
|401-998| Unallocated |  
|999    | Unhandled core-language or dependency exceptions | 


Alert Routing Keys
------------------
The alerts exchange is used to "broadcast" messages. These messages are not directed to any particular consumer, and may well be of equal interest to no consumers or many consumers. Messages sent out on this exchange do not receive a reply. As with everything, we define some standards so that we can catch and parse messages in a meaningful way. Currently reserved routing keys are:

* sensor_value: For values to be stored into the slow controls database tables for numeric_data and/or string_data. Currently the payload needs to include "from" "value_raw" or "memo" and optionally "value_cal" to be inserted. Based on the newer routing keys, it should probably become sensor_value.<sensor_name> since that way a process that is only listening to a certain sensor can bind to a key for that one only and not have to filter messages from other endpoints.
* status_message.\<slack_channel\>.\<origin_name\>: (where \<\> indicate values which will usually be bound with a '#' and which encode particular information), a system status message from a process which does not communicate directly with slack (or other messaging service) itself. Dripline will provide a slack_relay which posts a message which is "from" <origin_name> to a channel in the project 8 slack named "#<slack_channel" (note that '#' is reserved in routing keys in AMQP and always the start of a channel name so it is assumed) and with text == the python's str() of the message.payload.
* ... damn, I was sure there was one more but I can't place it now

Lockout
-------
A service may implement a lockout system to restrict access for certain types of request messages.  The lockout is intended to avoid stupid things happening (i.e. multiple people sending commands to the same service), and not as a security feature.  When a service is "locked," lockable messages will only be accepted if they have the right key in the ``lockout_key`` field of the message header.  Services not implementing a lockout system will ignore the ``lockout_key`` field entirely.

The following request types are lockable:
- OP_SET
- OP_CMD
- OP_SEND
- OP_RUN
- OP_CONFIG (if changing the state of the service; reads are not lockable)

The lockout key is 16-bytes long. When represented as a string, it will be formatted as 16 hexidecimal characters, in one of these ways:
- ``0123456789abcdef0123456789abcdef``
- ``01234567-89ab-cdef-0123456789abcdef``

A lockout system follows the following rules:
- Enabling the lock
  - The lock is enabled with an `OP_CMD` request and a `lock` instruction.
  - The key can be provided by the request, in which case it should be given as a properly formatted key in the `lockout_key` field.  Improperly formatted keys (that are non-empty strings) will result in an error (code 308).
  - If the key is not provided (i.e. the `lockout_key` field is an empty string), the key will be generated by the service.
  - If a service was unlocked, and the lock was successfully enabled, a success code 0 will be returned, and the key (whether provided or generated) will be returned in the `"lockout-key"` field of the payload of the reply.
  - If the service was already locked, an error code 307 will be returned.
- Using the lock
  - If a service is locked, any lockable request must have the valid key in the `lockout_key` field to be processed.
  - If a service is not locked (or does not implement any lockout functionality), the `lockout_key` field will be ignored.
  - When using the key provided in a request, if the key is improperly formatted, an error code 308 will be returned; if the key does not match the service's lockout key, an error code 307 will be returned.
- Disabling the lock
  - The lock is disabled with an `OP_CMD` request and an `unlock` instruction.
  - The rules for "Using the lock" above apply.
  - If a service is not locked, a warning code 1 will be returned.
  - if the service was locked, and was successfully unlocked, success code 0 will be returned.
  - The lock may be forced to disable by providing the field `"force": true` in the payload of the request. The value of the field should be a boolean.  This exception is intended to allow access to services to be regained in the event that the lockout key is lost; as mentioned above, the lockout is intended to avoid stupid mistakes, rather than as a true security feature.


Software Implementations
========================

Compatibility
-------------

| Package  | Version | Commit  | Comments |
|:---------|:--------|:--------|:---------|
| dripline | 1.4.4   | 4c0fceb | Complies with v1.1.0 |
|          | 1.7.5   | e1eb649 | complies with v1.3.0 |
| hornet   | 2.4.4   | 0e311f5 | Complies with v1.3.0 |
| mantis   | 3.2.0   | b830fed | Complies with v1.4.0 |

Notes
=====

dripline
--------

* Constants are defined in [constants.py](https://github.com/project8/dripline/blob/master/python/dripline/core/constants.py).  
* Retcodes are defined in [exceptions.py](https://github.com/project8/dripline/blob/master/python/dripline/core/exceptions.py).  
* Message objects implementing the protocol are in [message.py](https://github.com/project8/dripline/blob/master/python/dripline/core/message.py).  

hornet
------

* Constants are defined in [constants.go](https://github.com/project8/hornet/blob/develop/hornet/constants.go)

mantis
------

* Constants are defined in [mt_constants.hh](https://github.com/project8/mantis/blob/master/Common/mt_constants.hh).