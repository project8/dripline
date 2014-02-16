## Getting the source and building
We assume that you already have some basics ([erlang](www.erlang.org), [git](www.git-scm.com), [make](www.gnu.org/software/make/), [rebar](www.github.com/basho/rebar))installed. If not you can visit their respective project homepages for more information.

1. Start by either cloning the dripline repo or downloading and unpacking the tarball. For the purposes of this guide, $TOP will refer to the top level directory of the repo/source tree.

    ```
    $ git clone git@github.com:project8/dripline
    ```

2. Copy or place a symbolic link to the rebar executable in $TOP. The "release" make target should use rebar to clone and build all of dripline's dependencies as well as building dripline itself.

    ```
    $ make release
    ```

## Configuration and starting the node
1. _There are some steps to configure the local dripline node so that it knows its name and where to look for couch_
2. _For completeness, there should be descriptions of the couch config database docs as well_

3. Now just start dripline console and watch the magic.

    ```
    $ ./rel/dripline/bin/dripline console
    ```

## Other Tips
1. This should be obvious, but run dripline in either a [tmux](www.tmux.sourceforge.net) or [screen](www.gnu.org/software/screen) session. This allows you to reconnect to the erlang shell for trouble shooting without keeping a blocked terminal in your way.