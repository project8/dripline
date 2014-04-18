# Dripline

... is an erlang based hardware interface layer and slow control system developed for Project 8.

## Resources
* wiki: this document
* the included README file and comments in the code are also useful
* the [erlang debugger](http://erldocs.com/R13B02/runtime_tools/dbg.html)
* Some useful erlang shell references are collected in the [[Erlang Shell Quick Reference]]

## Getting Started
* [Rebar](http://www.github.com/basho/rebar) is the required build system. It will download and build all other required dependencies.
* [[Setup and Configuration]] provides further instruction for getting a local dripline node running.

## Usage
The dripline executable takes a config file which overwrites default settings. Call it with ```$ /path/to/dripline console -extra_config <fully qualified path>```. For example, if you are in the top of the software tree, you could do something like:

```shell
$ git clone git@github.com:project8/dripline
$ cd dripline
$ make release
$ echo "{couch_host, \"myrna.phys.washington.edu\"}." > local.config
$ echo "{couch_port, 5984}." >> local.config
$ ./rel/dripline/bin/dripline console -extra_config $(pwd)/local.config
```