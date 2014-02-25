## Table of Contents   
[Building from source](#build)  
[Configuration](#config)  
[Tips & Tricks](#tips)  

<a name="build"/>
## Getting the source and building
We assume that you already have some basics ([erlang](www.erlang.org), [git](www.git-scm.com), [make](www.gnu.org/software/make/), [rebar](www.github.com/basho/rebar))installed. If not you can visit their respective project homepages for more information.

1. Start by either cloning the dripline repo or downloading and unpacking the tarball. For the purposes of this guide, $TOP will refer to the top level directory of the repo/source tree.

    ```shell
    $ git clone git@github.com:project8/dripline
    ```

2. Copy or place a symbolic link to the rebar executable in $TOP. The "release" make target should use rebar to clone and build all of dripline's dependencies as well as building dripline itself.

    ```shell
    $ make release
    ```

<a name="config"/>
## Configuration and starting the node
1. The local dripline node is configured in a couple of files.
    1. In $TOP/rel/files/vm.args, change the second line to name the node (this should probably just be the hostname of the computer)
    2. In $TOP/rel/files/sys.config, change line 15 (the couch_host entry) to have the correct ip address/hostname and port number for the desired couch server.

2. Instruments and channels are configured via documents in the configuration database. [Examples](Couch Document Examples) of the various configuration document types are provided on another page.

3. Now just start dripline console and watch the magic.

    ```shell
    $ ./rel/dripline/bin/dripline console
    ```

<a name="tips"/>
## Other Tips
1. This should be obvious, but run dripline in either a [tmux](http://www.tmux.sourceforge.net) or [screen](http://www.gnu.org/software/screen) session.