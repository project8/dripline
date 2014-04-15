Dripline can supports processing the raw result of an instrument query (a get command). This is useful for parsing potential errors into something human readable, applying calibrations, etc.

An incomplete list follows
* force_positive
* cernox43022
* cernox87771
* cernox01929
* cernox87820
* tm220
* nmr_hall_cal_77k
* celsius_to_kelvin
* linear_r_to_z
* kjlc354_cal

There is also some configuration done by "sensor_type" field. Sensor types for the muxer can be:
* rtd85
* rtd85_fourwire
* dmm_dc_mv
* dmm_dc
* cernox
