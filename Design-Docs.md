There are several standard useful views for the various dripline databases. I'll duplicate them here without much comment for now, grouped for the [configuration](#configuration-database), [command](command-database), and [logger](#logged-data-database) databases.

### Configuration database
```json
{
   "_id": "_design/objects",
   "_rev": "10-32b0589670fd54953ca30cb834f69716",
   "language": "javascript",
   "views": {
       "instruments": {
           "map": "function(doc) {\n  if(doc[\"type\"] == \"instrument\") {\n    emit(doc[\"name\"], doc);\n  }\n}"
       },
       "channels": {
           "map": "function(doc) {\n  if(doc[\"type\"] == \"channel\") {\n    emit(doc[\"name\"], doc);\n  }\n}"
       },
       "loggers": {
           "map": "function(doc) {\n  if(doc[\"type\"] == \"logger\") {\n    emit(doc[\"channel\"], doc);\n  }\n}"
       },
       "buses": {
           "map": "function(doc) {\n\tif(doc[\"type\"] == \"bus\") {\n\t  emit(null, doc);\n}\t\n}"
       }
   }
}
```

### Command Database

```json
{
   "_id": "_design/latest_set",
   "_rev": "3-481f15128d68a1b8b4fdb50be605e7ee",
   "language": "javascript",
   "views": {
       "pure_setters": {
           "map": "function(doc) {\n   if(doc.final=='ok' &&\n      doc.timestamp &&\n      doc.command.do == \"set\"){\n        nogetchannels = [\"lo_cw_freq\",\n                         \"lo_power_level\"]\n        if(nogetchannels.indexOf(doc.command.channel)>= 0) {\n          emit(doc.command.channel, {\"timestamp\":doc.timestamp,\n                                     \"value\": doc.command.value,\n                                     \"_id\": doc._id})\n        };\n     };\n}",
           "reduce": "function(keys, values, rereduce) {\n    latest_time = \"0\"\n    latest_value = 0\n    latest_id = 0\n    for(var i=0; i<values.length; i++) {\n        if(values[i].timestamp > latest_time) {\n            latest_time = values[i].timestamp\n            latest_value = values[i].value\n            latest_id = values[i]._id\n        }\n    }\n    return {\"timestamp\":latest_time,\n            \"value\":latest_value,\n            \"_id\":latest_id}\n}"
       }
   }
}
```

```json
{
   "_id": "_design/files",
   "_rev": "1-6d4ad120716615393bfdecccc2561711",
   "language": "javascript",
   "views": {
       "full_fileset": {
           "map": "function(doc) {\n  if(doc[\"type\"] == \"command\" && doc[\"command\"][\"subprocess\"] == \"mantis\") {\n\temit(doc,none)\n  }\n}"
       }
   }
}
```

### Logged Data Database
```json
{
   "_id": "_design/log_access",
   "_rev": "1-58be1da5f0a67a7622c5c810903942e7",
   "language": "javascript",
   "views": {
       "all_logged_data": {
           "map": "function(doc) {\n  if(doc.timestamp_localstring!=\"undefined\")\n   emit(doc.timestamp_localstring\n, doc);\n}"
       },
       "logger_list": {
           "map": "function(doc) {\n  emit(doc.sensor_name, 1);\n}",
           "reduce": "function(keys, values, rereduce) {\n  return sum(values);\n}"
       }
   }
}
```

```json
{
   "_id": "_design/pypeline_view",
   "_rev": "1-9772a7774634adc0bd615156455b0252",
   "language": "javascript",
   "views": {
       "latest_values": {
           "map": "function(doc) {\n  if(doc.sensor_name && \n     doc.timestamp_localstring &&\n     doc.uncalibrated_value &&\n     doc.timestamp_localstring!=\"undefined\") {\n       emit(doc.sensor_name, {\"timestamp\":doc.timestamp_localstring,\n                              \"uncal_val\":doc.uncalibrated_value,\n                              \"cal_val\":doc.calibrated_value})\n     };\n}",
           "reduce": "function(keys, values, rereduce) {\n    var latest_time = \"0\"\n    var uncal = values[0].uncal_val\n    var cal = values[0].cal_val\n    for(var i=0; i<values.length; i++) {\n        if(values[i].timestamp > latest_time) {\n            latest_time = values[i].timestamp\n            uncal = values[i].uncal_val\n            cal = values[i].cal_val\n        }\n    }\n    return {\"timestamp\":latest_time,\n            \"uncal_val\":uncal,\n            \"cal_val\":cal}\n}"
       }
   }
}
```