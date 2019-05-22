---
title: "Operator Design"
permalink: /docs/user/OperatorDesign/
excerpt: "Describes the design of the Message Hub toolkit operators."
last_modified_at: 2019-04-22T06:55:48+01:00
redirect_from:
   - /theme-setup/
sidebar:
   nav: "userdocs"
---
{% include toc %}
{%include editme %}

This crossdc-failover toolkit contains the following operator to provide the failure recovery of any IBM Streams application between two data centers.

 * **CrossDataCenterFailover** - this operator is an SPL composite operator that will perform cross DC failover.

Main goal of this operator is to enable any given IBM Streams application to achieve operational continuity when one of the two data centers goes down in a planned or unplanned manner. As shown in a previous section, any application can invoke this operator in its flow graph and work with input and output streams provided by this operator to get notification about the remote DC status and optionally take part in the in-memory state replication between two data centers. 

## Heartbeat of this operator
This operator's main function revolves around periodically exchanging heart beat signals between two data centers using the reliable HTTP protocol. As long as both data centers can hear the heartbeat of each other, everything is normal. When the heartbeat is not heard for a preconfigured time duration, then this operator will declare that the other data center is not up and running and inform that status to the application in that local DC. On receiving that notification, application logic can proceed with taking over the operation as well as absorbing the failed remote DC's (optionally) replicated in-memory state.

The heartbeat exchange is done via sending heartbeat tuples to the remote data center. The schema for the heartbeat tuple is as shown below.

```
type HeartbeatMessageType = uint32 heartbeatMsgType, uint64 heartbeatCnt, rstring dataCenterOrigin, blob dataSnapshot, rstring dataSnapshotOrigin;

// Description of the attributes present in the stream schema shown above:
//
// heartbeatMsgType -->   It tells the type of the heartbeat message.
//                        1  for a regular heartbeat message (with no snapshot data)

//                        2  for a heartbeat message with snapshot data

//                        3  Orderly shutdown of the remote data center will happen shortly.
//                           So, it is not an abrupt remote DC failure.
//                           In this case, there is no remote Data Center operational take-over needed.
//                           So, delete the remote DC's replicated snapshot data.
//                           Then, mark the remote DC status as DOWN.
//                           If there is ever a need to do this, the external application logic can
//                           prepare a message with this message type and send it to the other DC just before
//                           the local DC is going to be shutdown in an orderly manner.

//                        4  In a rare case, both local and remote data centers can go down for
//                           some unexpected reasons one after the other in a short time span. 
//                           If this happens, we will be left with each data center holding the
//                           replicated state of the other. When both data centers come up after this
//                           rare simultaneous failure of both data centers, users can create an appconfig
//                           named sendDataSnapshotsToOriginDCAtStartup=true. This option will ensure that
//                           the replicated data snapshots will be sent back to their origin DC to
//                           restore their original state inside of the appropriate operators.
//                           For such message transfers, heartbeatMsgType attribute will carry this value of 4.
//                           After both data centers have been brought up correctly, users can either 
//                           delete this appconfig setting or set it to false.
//
// heartbeatCnt -->       It tells the running total of the 
//                        heartbeat messages that have been sent out from 
//                        a local data center to a remote data center.
//
// dataCenterOrigin -->   It tells the name of the data center from where
//                        this heartbeat message is originating.
//
// dataSnapshot -->       If it is a non-zero size blob, then it contains a
//                        serialized tuple that is purely external application specific.
//                        It may represent the in-memory state data or some other
//                        business logic data that this local data center wants to
//                        replicate to the remote data center via this heartbeat message.
//
// dataSnapshotOrigin --> It is an external application-specific arbitrary string that
//                        can uniquely identify which part of the external application serialized 
//                        its internal tuple into a binary data snapshot to be sent to the
//                        remote data center for replication. For example, this string
//                        could be an operator name or a parallel channel number in a 
//                        UDP region or a combination of both or totally something else.
//
```

## Supporting cast for this operator
This SPL composite operator relies on three other operators to accomplish the task of the cross DC failover capability.

 * **Beacon** - An IBM Streams built-in standard toolkit operator keeps the periodic heartbeat and data snapshot exchange going between the two data centers by creating timer signals.

 * **HttpBlobSender** - A Java primitive operator that is available as part of the crossdc-failover toolkit. It is used to send the serialized binary content to the remote data center.

 * **HTTPBLOBInjection** - A Java primitive operator that is available as part of the streamsx.inetserver toolkit. It is used to receive the binary content sent from the remote data center.

In addition to these operators, there are other SPL and C++ utility functions present in the crossdc-failover toolkit that are useful for the logic inside this operator.

## Configuring this operator
Every application integrating with the streamsx.crossdc-failover toolkit can do a very fine-grained configuration of how it wants to achieve failover. Cross DC configuration is done via a set of configuration names and their values in the key=value format. Such a configuration can be done either in the IBM Streams app config facility or in a text based config file or both. When the Cross DC configuration is done via both methods, then the text file based configuration will take precedence over the app config based one.

When done via the app config facility, there should be an app config named **CrossDCFailover** at the Streams instance level. Within that app config, every application should have its set of configuration key=value pairs in this format:

**namespace::MainCompositeName_key=value**

e-g: *com.acme.test::MyTest1_localDataCenterName=dc1*

Alternatively, every application can also decide to have its CrossDC configuration specified via its own text based file (e-g: *my-dc1-crossdc-config.txt*).

Following configuration key=value pairs must exist for every application. A typical text file based CrossDC configuration for a given application will look as shown below.

```
# Specify a name for this local data center.
localDataCenterName=dc1
# Specify the operation mode for this local data center: 0 for passive, 1 for active
crossDCOperationMode=1
# Specify the HTTP port number you want to use for the Cross DC Http Receiver.
crossDCHttpPort=25091
#
# In the property below, you can either give a single or multiple Streams application machine name(s) or
# the IP addresses of those machines that are used in the remote Data Center dc2. 
# If you have multiple machines, separate them by a comma: Machine1,Machine2,Machine3
remoteDataCenterApplicationMachineNames=d0702.pok.hpc-ng.ibm.com,b0517.pok.hpc-ng.ibm.com
# Specify the data snapshot storage directory.
# (Leave it commented out when not using a file system based storage.)
dataSnapshotStorageDirectory=/storage/sen/cross-dc-snapshot/CrossDataCenterFailoverSample/dc2
# Specify the Relational Database access details for the data snapshot storage.
# (Leave them all commented out when not using an RDBMS based storage.)
#dataSnapshotJdbcUrl=jdbc:db2://h0319b14.pok.hpc-ng.ibm.com:50000/boadb
#dataSnapshotJdbcUser=dragon
#dataSnapshotJdbcPassword=fire
##### You must create an opt sub-directory at the top-level of your 
##### application directory and then copy the required JDBC driver file there.
#dataSnapshotJdbcDriverLib=opt/db2jcc4.jar
#dataSnapshotJdbcClassName=com.ibm.db2.jcc.DB2Driver
##### You can name your table and its columns as you like.
##### But, keep the order and type of the columns as shown below:
##### id varchar(256) NOT NULL, replicationTime varchar(256), snapshot BLOB(32M), PRIMARY KEY (id)
#dataSnapshotTableName=dc2_cdc_rep
#dataSnapshotPrimaryKeyColumnName=id
#
# For all the config values that appear below, you can leave them as it is unless you
# really have a need to change them. In most cases, the default value below is sufficient.
#
# One time initial delay at the start of the application before the CrossDC toolkit goes to its real work.
crossDCInitDelay=40.0
#
# Heartbeat gets exchanged across the data centers for every 30 seconds.
######################################################################
# To deactivate the RemoteDC failover completely, set this 
# time interval to a very large value so that the heartbeat exchange will not 
# trigger anytime soon.  Set it to 444444444.00 (This means once in 14 years).
######################################################################
heartbeatExchangeInterval=30.0
# Data center failover will happen after four consecutive heartbeat misses i.e. after 120 seconds.
consecutiveHeartbeatMissesAllowed=4
# Periodic in-memory state data snapshot gets exchanged across 
# the data centers to do the data replication for every 180 seconds.
######################################################################
# To deactivate the RemoteDC snapshot/replication completely, set this 
# time interval to a very large value so that the data snapshot exchange will not 
# trigger anytime soon.  Set it to 888888888.00 (This means once in 28 years).
######################################################################
dataSnapshotExchangeInterval=180.0
# Specify whether you want to send the cross DC heartbeat and data snapshot messages to
# all the machines you configured above.
sendToAllRemoteMachines=false
# Specify whether you want to log the HTTP errors all the time.
alwaysLogHttpErrors=false
# Specify the HTTP connection timeout in seconds.
httpConnectionTimeout=25
# Specify the HTTP read timeout in seconds.
httpReadTimeout=100
# Specify the need to retain the pre-existing data snapshot files during the data center startup. 
retainOlderDataSnapshotsAtStartup=false
# Specify the need to send the replicated data snapshots to their
# origin DC in a rare case when both DCs go down simultaneously and
# get started at the same time after that event.
sendDataSnapshotsToOriginDCAtStartup=false
```

Please note that in a text file based configuration, there is no need to prefix the individual key=value pair with the namespace::MainCompositeName_. However, that prefix is a must when configuration is done in the IBM Streams app config named CrossDCFailover.

For the remoteDataCenterApplicationMachineNames configuration setting, it is required to give all the application machine names in the remote DC that can potentially run the operators/PEs belonging to a given Streams application. 

It is encouraged that the users take a copy of these reference files and modify it to suit their needs.

<span style="color:blue">
streamsx.crossdc-failover/com.ibm.streamsx.crossdc-failover/etc/make-crossdc-appconfig.sh
</span>
<span style="color:blue">
streamsx.crossdc-failover/com.ibm.streamsx.crossdc-failover/etc/crossdc-config.txt
</span>
