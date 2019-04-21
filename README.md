# crossdc-failover toolkit for IBM Streams

## Purpose
This toolkit is designed to provide application-level failover across two data centers. Two identical copies of a given Streams application running in two data centers either in active/active or in active/passive mode can achieve the failover a.k.a switchover when one of the data centers goes down. There is also an optional feature to do a periodic replication of the application's in-memory state across the two data centers in order for a surviving data center to take over the data replicated from the failed data center. In summary, this toolkit serves the purpose of enabling a given IBM Streams application for Disaster Recovery (DR) and Business Continuity (BC).

## Documentation
1. The official toolkit documentation with extensive details is available at this URL: https://ibmstreams.github.io/streamsx.crossdc-failover/

2. A file named crossdc-failover-tech-brief.txt available at this tooolkit's top-level directory also provides a good amount of information about what this toolkit does, how it can be built and how it can be used in the IBM Streams applications.

## Requirements
1. Any IBM Streams application interested in using this toolkit should be prepared to invoke an SPL composite operator available in this toolkit and complete the input and output stream requirements of that composite operator. Application logic will have to call one or more native functions provided by this toolkit in order to perform the periodic data replication between data centers. In summary, application logic will be required to properly integrate with the composite operator provided by this toolkit.
   
2. In order for this toolkit to work properly, there should be network connectivity available between the two data centers. This toolkit will open HTTP connections between the two data centers with a user specified HTTP port number. So, there should be no firewall blocking this HTTP communication in both data centers.

3. If the cross DC data replication option is enabled, then the replicated data will be stored in disk in both the data centers. This will require a shared/mapped drive either via NFS or NAS that can be accessed from all the IBM Streams application machines in a given data center. Depending on the size of the in-memory state held by the application logic, the total size of the shared drive in each data center should be planned ahead of time and provisioned properly.

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

A built-in example inside this toolkit can be compiled and launched in DC1 and DC2 as shown below. An important thing to note is that in the Makefile for that example application, you have to edit and point it to your correct directory for the streamsx.inetserver toolkit on which it has a dependency.

```
cd   streamsx.crossdc-failover/com.ibm.streamsx.crossdc-failover
make

cd   streamsx.crossdc-failover/samples/CrossDataCenterFailoverSample/
make

st  submitjob  -d  <YOUR_DC1_STREAMS_DOMAIN>  -i  <YOUR_DC1_STREAMS_INSTANCE>  output/com.ibm.streamsx.crossdc.failover.sample.CrossDataCenterFailoverSample.sab -P configFileName=<YOUR_DC1_CROSSDC_CONFIG_FILE> -C tracing=info

st  submitjob  -d  <YOUR_DC2_STREAMS_DOMAIN>  -i  <YOUR_DC2_STREAMS_INSTANCE>  output/com.ibm.streamsx.crossdc.failover.sample.CrossDataCenterFailoverSample.sab -P configFileName=<YOUR_DC2_CROSSDC_CONFIG_FILE> -C tracing=info
```

## WHATS NEW

v1.0.0:
- Apr/21/2019
- Very first release of the streamsx.crossdc-failover toolkit that was tested to provide failover of any given IBM Streams application across two data centers. It supports data centers operating in active/active as well as in active/passive mode. It also provides an optional feature to do a periodic replication of the application specific in-memory state across the two data centers in order for a surviving data center to take over that replicated data when a remote DC fails. Any application with the Disaster Recovery (DR) and Business Continuity (BC) design goals can achieve them using this version of the toolkit.
