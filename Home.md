# Dripline

## Summary

Dripline is a mostly [REST](https://ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm)-inspired framework for control systems developed by [Project 8](http://www.project8.org).
It comprises two components:  

1. A [[Wire Protocol|Wire-Protocol]] which defines the structure of valid messages
2. A [[Set of Conventions|Conventions]] which includes reserved keywords, values for constants, and behaviors for responding to messages.

The current version of the framework, along with the version history and planned future developments are listed on [[this page|Version]].  The summary of the [[guiding design principles|Design]] is available for reference, and should be especially useful for those wishing to contribute.

## Libraries
It is possible to implement dripline in whatever language/environment is most convenient (which is part of the value). We currently have a library available for [golang](https://github.com/project8/dripline/tree/develop/go) and for [python](https://github.com/project8/dripline/tree/develop/python) included in this repo. [Project 8](http://www.project8.org) also has rudimentary C++ implementation built into the [mantis](https://github.com/project8/mantis) package, but the dripline interface is not currently an isolated library, so it is not available in this repo.
