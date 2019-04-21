Changes
=======
## v1.0.0:
* Apr/21/2019
* Very first release of the streamsx.crossdc-failover toolkit that was tested to provide failover of any given IBM Streams application across two data centers. It supports data centers operating in active/active as well as in active/passive mode. It also provides an optional feature to do a periodic replication of the application specific in-memory state across the two data centers in order for a surviving data center to take over that replicated data when a remote DC fails. Any application with the Disaster Recovery (DR) and Business Continuity (BC) design goals can achieve them using this version of the toolkit.
