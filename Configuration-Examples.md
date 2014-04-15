Dripline's interactions with hardware is defined in a configuration database named dripline_conf. Documents are use to configure [buses](#bus), [instruments](#instrument), [channels](channel), and [loggers](#logger). Each is described, with examples, below.

### Bus
In dripline, a bus is describes a means of communicating with one or more device. The important fields to note are:
* name: this must be unique within a dripline configuration (all nodes using the same configuration database) and is the user, readable name for the bus.
* node: the name of the dripline node which will interface with this bus
* module: this is the erlang module to be used by the bus and determine its behavior
* info: module specific arguments, configuration how the dripline node interacts with the bus
```json
{
   "_id": "0d2111ca9cbf46d6a6d2496a7800493b",
   "_rev": "1-13d9863c962353d1247011346cdca178",
   "type": "bus",
   "name": "receiver_rack_prologix",
   "info": {
       "ip_address": "10.0.0.106",
       "port": "1234"
   },
   "module": "prologix",
   "node": "claude.phys.washington.edu"
}
```

### Instrument
In dripline an instrument refers to a physical device. Communication with it is done over a bus, and by communicating specifically with a particular channel. The important fields are:
* name: human readable name for the device
* bus: the bus to which the instrument is connected, via which dripline communicates with it. Note that the format is "<bus_module>/<bus_name>:<address>"
* instrument_model: the erlang module which defines the behavior of the instrument
```json
{
   "_id": "a7469beaaabea5eb23ff364dfb33f8fd",
   "_rev": "3-703594882d95903ea09f1a3dd0c89fed",
   "type": "instrument",
   "name": "hf_sweeper",
   "bus": "prologix/receiver_rack_prologix:19",
   "instrument_model": "hp8340b"
}
```

### Channel

### Logger