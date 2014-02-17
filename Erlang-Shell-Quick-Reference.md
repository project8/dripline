## Table of Contents   
[Starting/Stop](#StartStop)  
[Monitor instrument](#monitor)  

<a name="StartStop"/>
### Starting and stopping
* Start the dripline console from the top of the dripline source tree (assumes a successful [build](Setup and Configuration)).

    ```
    $ ./rel/dripline/bin/dripline console
    ```

* Stop dripline by connecting to the erlang shell and issuing the following command (note the '.' at the end).

    ```
    >> q().
    ```

<a name="monitor"/>
### Monitor a particular instrument
1. For help determining the name of the instrument of interest

    ```
    >> supervisor:which_children(dl_instr_sup).
    ```

2. Start watching that instrument's communications

    ```
    >> dbg:tracer().
    >> dbg:p(<instrument_name>, [m]).
    ```

3. When finished troubleshooting, stop the debugger to stop spamming the shell

    ```
    >> dbg:stop().
    ```