---
title: "Toolkit Overview [Technical]"
permalink: /docs/knowledge/overview/
excerpt: "Basic knowledge of the toolkit's technical domain."
last_modified_at: 2019-04-21T21:09:48+01:00
redirect_from:
   - /theme-setup/
sidebar:
   nav: "knowledgedocs"
---
{% include toc %}
{% include editme %}

## Definition of the term 'Failover'

English dictionary defines **Failover** as shown below.

*"A method of protecting computer systems from failure, in which a standby equipment automatically takes over when the main system fails."*

Wikipedia defines the same in a slightly elaborate manner as shown below.

*"In computing and related technologies such as networking, failover is switching to a redundant or standby computer server, system, hardware component or network upon the failure or abnormal termination of the previously active application, server, system, hardware component, or network. Failover and switchover are essentially the same operation, except that failover is automatic and usually operates without warning, while switchover requires human intervention."*

## Purpose of this toolkit
The IBM Streams crossdc-failover toolkit is designed to provide application-level failover across two data centers. Two identical copies of a given Streams application running in two data centers either in active/active or in active/passive mode can achieve the failover a.k.a switchover when one of the data centers goes down. There is also an optional feature to do a periodic replication of the application's in-memory state across the two centers in order for a surviving data center to take over the data replicated from the failed data center. In summary, this toolkit serves the purpose of enabling a given IBM Streams application for Disaster Recovery (DR) and Business Continuity (BC).

## Technical positioning of this toolkit
Large enterprise customers run their IBM Streams applications across multiple data centers that are geographically separated. They do this for various business-critical reasons such as load balancing, redundancy, resiliency, high availability, operational continuity etc. Such customers invariably need a way to protect their Streams applications from data center outages (both planned and unplanned). During such data center outages, they want the Streams applications failover safely and gracefully to the data center that is still active. 
This generic and robust toolkit allows the customer applications to piggyback on it and achieve the cross data center failover capability. This toolkit is implemented using the code artifacts written in SPL/Java/C++. It provides simple hooks via SPL composite operators and Stream connections for any application to seamlessly achieve the following:

1) Get notified about the UP or DOWN status of the application running in the remote DC.

2) Optionally and periodically replicate the in-memory state of any custom-written operator in an application graph to the remote DC.

3) When the application running in the remote DC becomes inactive, take over its operation by owning its in-memory state that was replicated regularly at the local DC.

It is important to think of the three activities mentioned above happening bidirectionally in the local DC as well as in the remote DC under normal working conditions. This toolkit provides three different examples that are easy to understand. They showcase a closer to real-life scenario with clear directions to demonstrate the local DC/remote DC setup with data replication, abrupt failure of any DC and the operational continuity at the surviving DC.

## Major dependency for this toolkit
To communicate between the data centers, this toolkit uses the HTTPBlobInjection operator present in the streamsx.inetserver toolkit. So, there is a dependency on the inetserver toolkit.

## Other requirements for this toolkit
1. Any IBM Streams application interested in using this toolkit should be prepared to invoke an SPL composite operator available in this toolkit and complete the input and output stream requirements of that composite operator. Application logic will have to call one or more native functions provided by this toolkit in order to perform the periodic data replication between data centers. In summary, application logic will be required to properly integrate with the composite operator provided by this toolkit.
   
2. In order for this toolkit to work properly, there should be network connectivity available between the two data centers. This toolkit will open HTTP connections between the two data centers with a user specified HTTP port number. So, there should be no firewall blocking this HTTP communication in both data centers.

3. If the cross DC data replication option is enabled, then the replicated data will be stored either in a relational database table or in a file system at both the data centers. This will require access to a relational database via JDBC from the Streams application machine(s) or read/write access to a shared/mapped drive either via NFS or NAS that can be accessed from all the IBM Streams application machines in a given data center. Depending on the size of the in-memory state held by the application logic, the total size of the database or the shared drive in each data center should be planned ahead of time and provisioned properly.
