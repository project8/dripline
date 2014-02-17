## Table of Contents   
[Bus](#bus)  
[Channel](#channel)  

I'll enclose in angle braces '<' and '>' fields the user should change for the particular element (most of these should be obvious.

<a name="bus"/>
## Bus
Each bus must have a unique configuration with name.

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

<a name="channel"/>
## Channel
I'll just post an actual example here
```
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