#!/bin/sh
#==============================================================
# First created on: Oct/11/2018
# Last modified on: Apr/19/2019
#
# This is a reference shell script that shows what actions 
# can be performed when a local data center's passive mode
# standalone monitoring application detects a failure a.k.a 
# down status of a Streams application running in a 
# remote DC. When the remote DC's failure is detected,
# this shell script will be launched from within the passive mode
# standalone monitoring application. Within this shell script,
# a new copy of that same distributed mode Streams application 
# is started in the local data center to do the cross DC fail-over.
# After starting the distributed mode Streams application,
# this shell script also stops the passive mode standalone
# application which is no longer required in the local DC.
#
# You can take a copy of this shell script file and
# modify it to suit your needs.
#==============================================================
# Start the IBM Streams application in the distributed mode to do the CrossDC fail-over.
# Please ensure beforehand that the streamtool submitjob command can be successfully 
# executed on the machine where this shell script will get launched.
streamtool submitjob /homes/hny5/sen/CrossDataCenterFailoverSample.sab -P configFileName=/homes/hny5/sen/dc2-crossdc-config.txt -d d1 -i i2 > /homes/hny5/sen/dc2-failover-result.txt
# Let us now stop the passive mode standalone application so that
# we will not have any HTTP port conflict with the  
# IBM Streams application we started above in the distributed mode.
pkill standalone
#
# At this time, you may want to start the passive mode standalone application in
# the other (remote) data center so that it can start monitoring the
# application you started above in the local DC to do the fail-over if a
# need arises. That way, you will have operational continuity in the 
# remote DC in case the local DC's application fails.
