On this page we collect features which have been discussed for upcoming versions of dripline. Once they are approved/implemented they will migrate from this page onto the proper pages in the spec itself. This could be considered similar to the discussion board for an issue tracker, but since this repo is already doing a bit too much, it seemed painful to mix in with technical issues.

In general, it is our goal that the dripline standard be stable, and that new user-space features be implemented within the constraints of the existing specs. Similarly, it is usually desirable to add new features not to the dripline library, but to derived applications (such as dragonfly or hornet) so that the dripline libraries themselves can be stable. Of course that does not always make sense, sometimes the conventions that exist fail to accommodate an arising need, or do so only in an ambiguous/messy way.

# Additions to the spec

- (described on use protocol but not part of v2.0.0) formally add required support for OP_CMD messages sent to `broadcast.<directive>` routing keys. Every *service* should respond to every broadcast without coordinating with other services  
- add `set_condition` directive to broadcast (not implemented anywhere currently). See description on use protocol
- Require that ping and broadcast OP_CMD commands are not subject to lockout state. Lock and unlock directives should continue to respect lockout keys for particular services/endpoints unless the "force" option is used

- Require that all endpoints respond to any request "quickly" (whatever that means). The expectation should be that one can send a request and get an immediate reply. If a task "takes some time" then it should be started (which can receive a positive reply indicating that the task is starting), polled (further requests with replies that indicate that the task is executing or not. It may be desirable for non-execution to include more details, such as if the most recent execution completed successfully and/or a timestamp of when the last execution completed), and then results retrieved from a cache maintained by the endpoint. It is probably also good if the process can be forcefully aborted in a way that restores a nominal state. _This should be added to the design principles section but currently dragonfly does not comply and fixing that seems non-trivial. It would also be nice to be more explicit about what "quickly" means, since network communication and instrument interactions can take measurable time but are often still "quick"_

# Additions/changes to glossary

- "routing key target": all characters in a routing key prior to the first period. Complement of the routing key specifier. Within implementations of dripline, this is the component commonly used with an exact match when binding a queue, with the RKS generally being wildcarded.

# Deprecations

- The T_INFO message type is never used and it is not clear where it would be needed/desired. Information could easily be sent either in a T_ALERT or a T_REPLY as appropriate