#!/bin/bash
#==============================================================
# First created on: Oct/11/2018
# Last modified on: Apr/21/2019
#
# 1) This reference file has the configuration details for one data center (dc1).
#    You can take a copy of this file and change the configuration below to suit your 
#    data center specific values. After that, you can run this script. 
#    Specific configuration parameters that will change are listed here:
#    Your proper namespace::MainCompositeName prefix instead of com.acme.test::MyTest1,
#    DC1 name, DC1 operation mode, Remote DC2 application machine name(s) and 
#    Data snapshot storage directory.
#
# 2) You can take a copy of this file and modify the configuration 
#    for the other data center (dc2) and then run that script.
#    Ensure that you change the domain and instance names as needed.
#    Specific configuration parameters that will change are listed here:
#    Your proper namespace::MainCompositeName prefix instead of com.acme.test::MyTest1,
#    DC2 name, DC2 operation mode, Remote DC1 application machine name(s) and 
#    Data snapshot storage directory.
#
# NOTE
# ---- 
# Please note that you can store the crossdc-failover configuration
# details in the IBM Streams app config only if you are going to run an
# IBM Streams distributed application and not a standalone application.
# If you can't store the crossdc-failover configuration
# details in the IBM Streams appconfig facility, you can specify 
# the configuration details via a text file. Please see a reference
# configuration file (crossdc-config.txt) available in the same
# directory as the shell script you are currently reading.  
#==============================================================
# Comment out the following line if you want to modify 
# or add new entries to your existing cross dc app config.
# Based on that, you may also have to change the next 
# mkappconfig command to chappconfig as needed.
streamtool rmappconfig -d d1 -i i1 --noprompt CrossDCFailover
#
# All the Cross DC related appconfig properties must be prefixed with
# a specific Streams application name as shown below. This will help
# different applications running in the same Streams instance to
# have their own Cross DC properties in the app config. Please ensure
# to globally replace com.acme.test::MyTest1 in this file with your
# application specific value.
# namespace::MainCompositeName_localDataCenterName
# e-g: com.acme.test::MyTest1_localDataCenterName
#
# Change this mkappconfig to chappconfig if you are using this 
# script to make changes to your existing cross dc app config.
#
# Specify a name for this local data center.
streamtool mkappconfig -d d1 -i i1 --property com.acme.test::MyTest1_localDataCenterName=dc1 CrossDCFailover
# Specify the operation mode for this local data center: 0 for passive, 1 for active
streamtool chappconfig -d d1 -i i1 --property com.acme.test::MyTest1_crossDCOperationMode=1 CrossDCFailover
# Specify the HTTP port number you want to use for the Cross DC Http Receiver.
streamtool chappconfig -d d1 -i i1 --property com.acme.test::MyTest1_crossDCHttpPort=25091 CrossDCFailover
#
# In the property below, you can either give a single or multiple Streams application machine name(s) or
# the IP addresses of those machines that are used in the remote Data Center dc2. 
# If you have multiple machines, separate them by a comma: Machine1,Machine2,Machine3
streamtool chappconfig -d d1 -i i1 --property com.acme.test::MyTest1_remoteDataCenterApplicationMachineNames=d0702.pok.hpc-ng.ibm.com,b0517.pok.hpc-ng.ibm.com CrossDCFailover
# Specify the data snapshot storage directory.
streamtool chappconfig -d d1 -i i1 --property com.acme.test::MyTest1_dataSnapshotStorageDirectory=/storage/sen/cross-dc-snapshot/CrossDataCenterFailoverSample/dc2 CrossDCFailover
#
# For all the app config values that appear below, you can leave them as it is unless you
# really have a need to change them. In most cases, the default value below is sufficient.
#
# One time initial delay at the start of the application before the CrossDC toolkit goes to its real work.
streamtool chappconfig -d d1 -i i1 --property com.acme.test::MyTest1_crossDCInitDelay=40.0 CrossDCFailover
#
# Heartbeat gets exchanged across the data centers for every 30 seconds.
######################################################################
# To deactivate the RemoteDC failover completely, set this 
# time interval to a very large value so that the heartbeat exchange will not 
# trigger anytime soon.  Set it to 444444444.00 (This means once in 14 years).
######################################################################
streamtool chappconfig -d d1 -i i1 --property com.acme.test::MyTest1_heartbeatExchangeInterval=30.0 CrossDCFailover
# Data center failover will happen after four consecutive heartbeat misses i.e. after 120 seconds.
streamtool chappconfig -d d1 -i i1 --property com.acme.test::MyTest1_consecutiveHeartbeatMissesAllowed=4 CrossDCFailover
# Periodic in-memory state data snapshot gets exchanged across 
# the data centers to do the data replication for every 180 seconds.
######################################################################
# To deactivate the RemoteDC snapshot/replication completely, set this 
# time interval to a very large value so that the data snapshot exchange will not 
# trigger anytime soon.  Set it to 888888888.00 (This means once in 28 years).
######################################################################
streamtool chappconfig -d d1 -i i1 --property com.acme.test::MyTest1_dataSnapshotExchangeInterval=180.0 CrossDCFailover
# Specify whether you want to send the cross DC heartbeat and data snapshot messages to
# all the machines you configured above.
streamtool chappconfig -d d1 -i i1 --property com.acme.test::MyTest1_sendToAllRemoteMachines=false CrossDCFailover
# Specify whether you want to log the HTTP errors all the time.
streamtool chappconfig -d d1 -i i1 --property com.acme.test::MyTest1_alwaysLogHttpErrors=false CrossDCFailover
# Specify the HTTP connection timeout in seconds.
streamtool chappconfig -d d1 -i i1 --property com.acme.test::MyTest1_httpConnectionTimeout=25 CrossDCFailover
# Specify the HTTP read timeout in seconds.
streamtool chappconfig -d d1 -i i1 --property com.acme.test::MyTest1_httpReadTimeout=100 CrossDCFailover
# Specify the need to retain the pre-existing data snapshot files during the data center startup. 
streamtool chappconfig -d d1 -i i1 --property com.acme.test::MyTest1_retainOlderDataSnapshotsAtStartup=false CrossDCFailover
# Specify the need to send the replicated data snapshots to their
# origin DC in a rare case when both DCs go down simultaneously and
# get started at the same time after that event.
streamtool chappconfig -d d1 -i i1 --property com.ibm.streamsx.crossdc.failover::CrossDataCenterFailoverTest_sendDataSnapshotsToOriginDCAtStartup=false CrossDCFailover

# If you want to list the configuration values stored in
# your IBM Streams appconfig, you can use the following command.
#      streamtool getappconfig -d d1 -i i1 CrossDCFailover
#
# If you want to remove your appconfig entirely,
# you can use the following command.
#      streamtool rmappconfig -d d1 -i i1 CrossDCFailover

