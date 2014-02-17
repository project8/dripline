## Table of Contents   
[Bus](#bus)  
[Monitor instrument](#monitor)  

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