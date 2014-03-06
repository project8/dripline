## Table of Contents   
[Starting & Stop](#StartStop)  
[Monitor instrument](#monitor)  
[Hot update source file](#compile)  
[Coding Tips](#coding)

<a name="StartStop"/>
### Starting and stopping
* Start the dripline console from the top of the dripline source tree (assumes a successful [build](Setup and Configuration)).

    ```shell
    $ ./rel/dripline/bin/dripline console
    ```

* Stop dripline by connecting to the erlang shell and issuing the following command (note the '.' at the end).

    ```erlang
    >> q().
    ```

<a name="monitor"/>
### Monitor a particular instrument
1. For help determining the name of the instrument of interest

    ```shell
    >> supervisor:which_children(dl_instr_sup).
    ```

2. Start watching that instrument's communications

    ```erlang
    >> dbg:tracer().
    >> dbg:p(<instrument_name>, [m]).
    ```

3. When finished troubleshooting, stop the debugger to stop spamming the shell

    ```erlang
    >> dbg:stop().
    ```

<a name="compile"/>
### Compile and load source file
* Compile the file (Note, the file's .erl extension is not required).

    ```erlang
    >> c("../../apps/dl_core/src/<some>/<file>").
    ```

* Note1 that this will compile a new beam file and load it, but does *not* add that file to the build of the current release. You need to return to the root of the source tree and `$ make release` so to ensure the next time you restart dripline, the changes remain in place.
* Note2 don't forget to commit and push your changes, we have a tendency to not save and/or propagate them across nodes.

<a name="coding"/>
### Coding Tips
* -spec allows specification of types for functions. We find this especially useful in conjunction with dialyzer for catching problems.
