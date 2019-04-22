---
title: "Operator Usage Patterns"
permalink: /docs/user/CrossDCFailoverUsagePatterns/
excerpt: "Describes the CrossDCFailover operator usage patterns."
last_modified_at: 2019-04-22T14:22:48+01:00
redirect_from:
   - /theme-setup/
sidebar:
   nav: "userdocs"
---
{% include toc %}
{%include editme %}

## Usage pattern for the CrossDataCenterFailover operator
As described in the other documentation pages, the CrossDCFailover operator can work in data center environments configured in active/active and active/passive modes of operation. In addition, this operator can also work with applications configured for consistent regions as well as non-consistent regions. The crossdc-failover toolkit ships with three example applications that will cover all the scenarios mentioned above. Please refer to those example applications to learn about the usage pattern and apply that learning in your own applications.

## Running the examples in active/active mode
As mentioned earlier, there is plenty of commentary available in the example projects. Instead of repeating it here, please open any of the SPL source file in the first two examples mentioned earlier and follow the detailed directions found in that file to run it.

We show here the streamtool commands to run two identical copies of an application in active/active mode.

```
st  submitjob  -d  <YOUR_DC1_STREAMS_DOMAIN>  -i  <YOUR_DC1_STREAMS_INSTANCE>  output/com.ibm.streamsx.crossdc.failover.sample.CrossDataCenterFailoverSample.sab -P configFileName=<YOUR_DC1_CROSSDC_CONFIG_FILE> -C tracing=info

st  submitjob  -d  <YOUR_DC2_STREAMS_DOMAIN>  -i  <YOUR_DC2_STREAMS_INSTANCE>  output/com.ibm.streamsx.crossdc.failover.sample.CrossDataCenterFailoverSample.sab -P configFileName=<YOUR_DC2_CROSSDC_CONFIG_FILE> -C tracing=info
```

## Running the examples in active/passive mode
Please follow the detailed directions available in the CrossDataCenterFailoverPassiveSample.spl file to run it.

We show here the streamtool command to run one of the first two examples in active mode and the the third example as a standalone in passive mode.

```
st  submitjob  -d  <YOUR_DC1_STREAMS_DOMAIN>  -i  <YOUR_DC1_STREAMS_INSTANCE>  output/com.ibm.streamsx.crossdc.failover.sample.CrossDataCenterFailoverSample.sab -P configFileName=<YOUR_DC1_CROSSDC_CONFIG_FILE> -C tracing=info

cd   streamsx.crossdc-failover/samples/CrossDataCenterFailoverPassiveSample/output/bin
./standalone configFileName=<YOUR_DC2_CROSSDC_PASSIVE_CONFIG_FILE> shellScriptName=<YOUR_DC2_CROSSDC_FAILOVER_SHELL_SCRIPT>
```

## Failover in a passive mode data center
When one DC goes down in an active/active configuration, failover will happen automatically in the other DC's already active copy of that same application. However, in an active/passive configuration, the passive mode data center is only monitoring the health of the remote active DC. When that remote active DC fails, then passive side should detect the failure and start the real application. This task can be automated via a shell script.

The CrossDataCenterFailoverPassiveSample application we discussed earlier does exactly that. It does it by calling a launch_app native function provided by the streamsx.crossdc_failover toolkit to launch a shell script which in turn will start the required application in the DC that is failing over. Please refer to that example application to learn more.

It is encouraged that the users take a copy of this reference shell script and modify it to suit their needs.

<span style="color:blue">
streamsx.crossdc-failover/com.ibm.streamsx.crossdc-failover/etc/crossdc-failover.sh
</span>

## streamsx.crossdc-failover Special Messages
As explained in an earlier section, application logic can send certain special messages into the CrossDCFailover composite operator. You can refer to the example applications to learn more.

**OrderlyShutdown**: When a given DC's application requires a planned orderly shutdown, then this activity can be informed to the remote DC to anticipate a normal outage thereby avoiding any accidental failover operation. In this case, the application logic can send this special message to the CrossDCFailover composite operator.

**SendMeDataFromSnapshotFiles**: During the application start-up time, if the application wants to inherit the remote DC's replicated data that was received during the previous application run, then it can send this special message to the CrossDCFailover composite which will start sending the previously replicated data. During the application start-up, by default remote DC's replicated data from a previous run is deleted. So, this special message has to work in conjunction with a CrossDC configuration named *retainOlderDataSnapshotsAtStartup*. You can ask an IBM Streams specialist about how it works if you will ever have a need to use this feature.

## Useful CrossDC native functions
In order to send the in-memory state for cross DC replication, application logic can call these native functions to serialize the in-memory state into a blob or deserialize a blob into the original data item.

**serializeDataItem**
**deserializeDataItem**
**serializeTuple**
**deserializeTuple**

In a passive mode standalone monitoring application, following function is available for use to launch a shell script to start the real Streams application in order to do the failover.

**launch_app**

Please refer to the example applications provided in this toolkit to learn about how to use these functions.

## A rare case when both the DCs go down at the same time
In an extremely rare case, if both the data centers went down exactly at the same time, we will end up in a situation where DC1 will have the last known replicated data snapshots for DC2 and vice versa. In this case, we can optionally (based on user request) send such replicated data snapshots to their respective data centers where they originally came from. Users can indicate this preference via this configuration setting: **sendDataSnapshotsToOriginDCAtStartup=true**

After both data centers have been brought up correctly, users can either delete this configuration setting belonging to each DC or simply set it to false.

## Scaling the crossdc-failover toolkit to work with a larger application topology
A larger application topology running with many operators on a Linux cluster with many machines will require an equivalent level of scaling done at the CrossDCFailover composite layer. Since the crossdc-failover communicates via HTTP with the remote DC, it needs more HTTP sender/receiver pairs to handle the load from a larger application topology. By default, there is only one pair of sender/receiver. So, users can assign a required number of HTTP sender/receiver pairs by using the submission time parameter called **numberOfHttpSenderReceiverPairs** at the time starting up their application. 

## Conclusion
As explained in the chapters thus far, this toolkit is a powerful one for the IBM Streams customers to enable their Streams applications to work in tandem in their two data centers. It brings the Disaster Recovery (DR) and Business Continuity (BC) features to the IBM Streams applications.

**Cheers and good luck in handling your data center outages gracefully.**
