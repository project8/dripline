## Table of Contents   
[Bus](#bus)  
[Instrument](#instrument)  
[Channel](#channel)  
[Logger](#logger)  

I'll enclose in angle braces '<' and '>' fields the user should change for the particular element (most of these should be obvious.

<a name="bus"/>
## Bus
A bus is a connection to the dripline node. It may provide a means of communication with multiple instruments.

```json
{  
    "_id": "0d2111ca9cbf46d6a6d2496a7800493b",  
   "_rev": "1-13d9863c962353d1247011346cdca178",  
   "type": "bus",  
   "name": "<name>",  
   "info": {  
       "ip_address": "<#.#.#.#>",  
       "port": "<#>"  
   },  
   "module": "<name>",  
   "node": "<node.domain.ext>"  
}  
```

<a name="instrument"/>
## Instrument
An instrument is a physical box/component. It communicates over a bus and may respond to requests on several channels.
```json
{
   "_id": "55023fce96bdb7219bafbd8c95003100",
   "_rev": "5-0607f7c6dedd59e4989c6b4735c5d807",
   "instrument_model": "agilent34970a",
   "bus": "prologix/left_box:9",
   "type": "instrument",
   "name": "adc_mux"
}
```

<a name="channel"/>
## Channel
I'll just post an actual example here
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

<a name='logger'"/>
## Logger
Logger are special configurations in that they control a dripline behavior, not the configuration of a piece of hardware. Interval is given in seconds and tells dripline how often to "get" the indicated channel. The result is stored in the logged_data database.
```json
{
   "_id": "65298fdbaffa4711bf7fc9ba24a4586b",
   "_rev": "1-50ec0fcfd9e1f88867d1caa6a97af943",
   "type": "logger",
   "channel": "al60_head_temp",
   "interval": "8"
}
```