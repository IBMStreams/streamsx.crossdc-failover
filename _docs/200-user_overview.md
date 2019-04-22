---
title: "Toolkit Usage Overview"
permalink: /docs/user/overview/
excerpt: "How to use this toolkit."
last_modified_at: 2019-04-21T21:30:48+01:00
redirect_from:
   - /theme-setup/
sidebar:
   nav: "userdocs"
---
{% include toc %}
{%include editme %}

## Salient features of this toolkit
It provides the following salient features to address the needs of DR (Disaster Recovery) and BC (Business Continuity).

1) It allows two copies of a given Streams application to run in two data centers as <span style="color:green">active(DC1)</span>/<span style="color:green">active(DC2)</span> or <span style="color:green">active(DC1)</span>/<span style="color:blue">passive(DC2)</span> or <span style="color:blue">passive(DC1)</span>/<span style="color:green">active(DC2)</span>. 

2) When an active DC fails, it makes the other DC failover a.k.a switchover to continue the application functions using the surviving second copy.

3) Optionally, it also does the periodic replication of the Streams application's in-memory operator state across two data centers. It will do bidirectional replication in active/active mode and unidirectional replication when one DC is active and the other DC is passive. When an active DC goes down, it will make the other DC's application restore the data replicated from the failed remote DC into its own in-memory state. This optional crossdc data replication and restoration feature expects two identical copies of a given application i.e. exactly the same application topology to run in both data centers.

## Building the streamsx.crossdc-failover toolkit
After downloading this toolkit from the IBMStreams GitHub, unzip it in your development machine. Then, follow these simple steps to build it.

```
cd   streamsx.crossdc-failover/com.ibm.streamsx.crossdc-failover
make
```

NOTE: On your development machine, you have to ensure that you have installed the Apache Ant tool which is required to build this toolkit.

## Learning to use this toolkit through examples
There are three examples shipped with this toolkit that can show the users of this toolkit about ways to achieve crossdc failover in their own applications either in active/active or in active/passive manner.

**streamsx.crossdc-failover/samples/CrossDataCenterFailoverSample** is an example that shows how to integrate with the crossdc-faiover toolkit when the application doesn't use the IBM Streams consistent region feature.

**streamsx.crossdc-failover/samples/CrossDataCenterFailoverCRSample** is an example that shows how to integrate with the crossdc-faiover toolkit when the application uses the IBM Streams consistent region feature.

**streamsx.crossdc-failover/samples/CrossDataCenterFailoverPassiveSample** is an example that shows how to integrate with the crossdc-faiover toolkit when we want to run one of the two examples shown above in a DC in active mode and then monitor that remote DC passively from the second DC in order to failover when the remote DC encounters a failure or an outage.

* [CrossDataCenterFailoverSample](https://github.com/IBMStreams/streamsx.crossdc-failover/tree/master/samples/CrossDataCenterFailoverSample)
* [CrossDataCenterFailoverCRSample](https://github.com/IBMStreams/streamsx.crossdc-failover/tree/master/samples/CrossDataCenterFailoverCRSample)
* [CrossDataCenterFailoverPassiveSample](https://github.com/IBMStreams/streamsx.crossdc-failover/tree/master/samples/CrossDataCenterFailoverPassiveSample)

All the three examples contain plenty of code commentary to help in understanding the steps needed to integrate with the streamsx.crossdc-failover toolkit. Since the concepts are somewhat advanced in nature, you are encouraged to do your own detailed study of how these examples work. Alternatively, you can ask an IBM Streams specialist to explain how these examples are put together to work across two data centers in a fail-safe manner. 

These three examples can be built by simply typing make from within their respective directory location. Please refer to the discussion above where we talked about the dependency on the streamsx.inetserver toolkit. The Makefile provided with each of these examples has a reference to the inetserver toolkit location which must be set to your correct directory before building these examples. When you want to use the streamsx.crossdc-failover toolkit in your own application, you also have to take care of adjusting your Makefile to point to the correct inetserver location.

## Example usage of this toolkit inside a Streams application
Here is a code snippet that shows how to invoke the CrossDCFailover composite operator available in this toolkit from within an IBM Streams application:

```
use com.ibm.streamsx.crossdc.failover.types::*;
use com.ibm.streamsx.crossdc.failover::*;

// ===== Start of integrating with the CrossDCFailover Composite =====
// Any application that wants to make use of the
// CrossDataCenterFailover technique explained above must
// invoke the following reusable composite.
(stream<HeartbeatMessageType> DataSnapshotSignal;
 stream<RemoteDataCenterStatusType> RemoteDataCenterStatus;
 stream<HeartbeatMessageType> ProcessDataFromRemoteDC) as CrossDCFailover = 
 CrossDataCenterFailover(SerializedDataSnapshotMessage; SpecialMessage) {
    param
       configFileName: $configFileName;	 
}

// As you can see above, the CrossDCFailover composite has its own
// input streams and output streams all of which will be used by one or 
// more operators in this application.	
//
// At this point, application code can consume the tuples coming via the
// output streams of the CrossDCFailover layer and application code feed
// into the input streams of the CrossDCFailover layer as needed.
//
// ===== End of integrating with the CrossDCFailover Composite =====		
```

Following are the output streams available from the CrossDCFailover composite operator to the application logic.

**DataSnapshotSignal**: If the optional periodic data replication is enabled, then the application logic will be notified via this stream whenever it is time for the application logic to create a snapshot of its in-memory state data to be replicated to the remote DC.

**RemoteDataCenterStatus**: This stream notifies the application logic about any status change happening in the remote DC i.e. when a remote DC comes up active or when a remote DC goes down.

**ProcessDataFromRemoteDC**: When a remote DC failure or outage is detected and if the optional cross DC data replication is ON, then this stream will provide the application logic with a serialized blob representing the replicated in-memory state from the failed remote DC. This blob will carry an application specific origin of this data so that the corresponding operator in the local DC's application can deserialize the blob and take over that data.

Following are the input streams into the CrossDCFailover composite operator for which the application logic is responsible for.

**SerializedDataSnapshotMessage**: In response to the periodic cross DC data replication notification from the CrossDCFailover composite operator, application logic can serialize its in-memory state into a blob and feed it into this input stream.

**SpecialMessage**: Application logic can send special messages into the CrossDCFailover composite operator via this input stream when needed. This stream has a single rstring attribute. Following are the valid values for this attribute:

*OrderlyShutdown*
*SendMeDataFromSnapshotFiles*

Meaning for these special messages is discussed in another section.

The CrossDCFailover composite takes one parameter through which users can specify the fully qualified name for a text based configuration file. If configuration for the CrossDCFailover composite is done via the IBM Streams app config facility, then users can pass an empty string i.e. "" as a value for this parameter. A separate section covers more details about configuring the CrossDCFailover composite.
