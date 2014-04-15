In most circumstances, a user should **not** need to create command documents directly. Pypeline provides both an interactive terminal and gui based means of interacting with dripline. Example command documents follow for completeness of examples, or for debugging reference only. As couchdb documents, all command documents must be valid json. Values which the user must select will be enclosed in angle brackets (\< \>).

### Get document
Saving a new document:
```json
{
   "_id": "d0904dbf837b40e815ae483212002be3",
   "type": "command",
   "command": {
       "do": "get",
       "channel": <channel_name>
   }
}
```
Would return:
```json
{
   "_id": "d0904dbf837b40e815ae483212002be3",
   "_rev": "6-e4aaf1cccdeac42316ed883bb59c6eac",
   "type": "command",
   "command": {
       "do": "get",
       "channel": <channel_name>
   },
   "result": {
       "dripline.node.name": {
           "result": <value>,
           "timestamp": <time>
       }
   }
}
```