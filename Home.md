# Dripline

Is a mostly [RESTful](https://ics.uci.edu/~fielding/pubs/dissertation/rest_arch_style.htm) framework for control systems developed by [Project 8](http://www.project8.org).
It comprises two components:  

1. A [[Wire Protocol|Wire-Protocol]] which defines the structure of valid messages
2. A [[Set of Conventions|Conventions]] which includes reserved keywords, values for constants, and behaviors for responding to messages.

There is also a summary of [[guiding design principles|Design]] available for reference, and especially useful for those wishing to contribute.

## Libraries
It is possible to implement dripline in whatever language/environment is most convenient (which is part of the value). We currently have a library available for golang and for python included in this repo. Project 8 also has C++ implementation built into the mantis package, but the dripline interface is not currently an isolated library, so it is not available in this repo.
