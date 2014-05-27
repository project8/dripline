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
In dripline, a channel is a reference to a function in an instrument module. The notable fields are:
* instrument: name of the instrument the channel is associated with
* locator: atom in being matched in the module to decide what function to call (in the case of the muxer, an atom of the form "{card,channel}" is used and parsed.
* name: human readable name for the channel (used in get/set documents etc.)
* post_hooks: a list of hooks used to process the data returned by the instrument prior to posting a reply
* sensor_type: for muxer channels, give a sensor_type; an element of {rtd85, rtd85_fourwire, rtd91, dmm_dc, dmm_dc_mv, dmm_ac, cernox, fourwire}. Note that "dmm_dc" configures with a 10V range and 0.001V resolution,dmm_dc_mv configures with 100mV range and 3E-7 mV resolution, dmm_ac configures with 10V range and 0.001V resolution, "cernox" and "fourwire" both use auto range & resolution. The various "*rtd*" are built into the muxer. 
```json
{
   "_id": "a7469beaaabea5eb23ff364dfb53d98b",
   "_rev": "4-6794e96b2c968a924fb65bc8ab499ad5",
   "instrument": "hf_sweeper",
   "type": "channel",
   "locator": "cw_freq",
   "name": "hf_cw_freq",
   "post_hooks": [
       "strip_newline_chars"
   ]
}
```
Or for a muxer sensor
```json
{
   "_id": "dc364434d07d8fe589e6e9b492",
   "_rev": "6-773ca9c9ec95a23ca1287d443610a181",
   "type": "channel",
   "instrument": "adc_mux",
   "locator": "{3,4}",
   "name": "al60_head_temp",
   "post_hooks": [
       "force_positive",
       "cernox43022"
   ],
   "sensor_type": "cernox"
}
```
### Logger
In dripline, a logger is a process which performs a "get" on a particular channel, at a particular interval, and stores the result in the dripline_logged_data database. The relevant fields are:
* channel: name of the channel to poll
* interval: number of seconds between log entries
* name: identifier must be unique among loggers, used by the pypeline logger, ignored by dripline
```json
{
   "_id": "65298fdbaffa4711bf7fc9ba24a4586b",
   "_rev": "1-50ec0fcfd9e1f88867d1caa6a97af943",
   "type": "logger",
   "channel": "al60_head_temp",
   "interval": "8",
   "name": "cold_head_temp_logger"
}
```