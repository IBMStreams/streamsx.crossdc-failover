# begin_generated_IBM_copyright_prolog                             
#                                                                  
# This is an automatically generated copyright prolog.             
# After initializing,  DO NOT MODIFY OR MOVE                       
# **************************************************************** 
# THIS SAMPLE CODE IS PROVIDED ON AN "AS IS" BASIS. IBM MAKES NO   
# REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED, CONCERNING    
# USE OF THE SAMPLE CODE, OR THE COMPLETENESS OR ACCURACY OF THE   
# SAMPLE CODE. IBM DOES NOT WARRANT UNINTERRUPTED OR ERROR-FREE    
# OPERATION OF THIS SAMPLE CODE. IBM IS NOT RESPONSIBLE FOR THE    
# RESULTS OBTAINED FROM THE USE OF THE SAMPLE CODE OR ANY PORTION  
# OF THIS SAMPLE CODE.                                             
#                                                                  
# LIMITATION OF LIABILITY. IN NO EVENT WILL IBM BE LIABLE TO ANY   
# PARTY FOR ANY DIRECT, INDIRECT, SPECIAL OR OTHER CONSEQUENTIAL   
# DAMAGES FOR ANY USE OF THIS SAMPLE CODE, THE USE OF CODE FROM    
# THIS [ SAMPLE PACKAGE,] INCLUDING, WITHOUT LIMITATION, ANY LOST  
# PROFITS, BUSINESS INTERRUPTION, LOSS OF PROGRAMS OR OTHER DATA   
# ON YOUR INFORMATION HANDLING SYSTEM OR OTHERWISE.                
#                                                                  
# (C) Copyright IBM Corp. 2019  All Rights reserved.         
#                                                                  
# end_generated_IBM_copyright_prolog                               

JAVA_CLASS_FILES = impl/java/src/com/ibm/streamsx/crossdc/failover/HttpBlobSender.java \
                   impl/java/src/com/ibm/streamsx/crossdc/failover/CrossDCSnapshotJdbcWriter.java \
                   impl/java/src/com/ibm/streamsx/crossdc/failover/CrossDCSnapshotJdbcReader.java \
                   impl/java/src/com/ibm/streamsx/crossdc/failover/CrossDCSnapshotJdbcRemover.java

all: java

java: $(JAVA_CLASS_FILES)  
	JAVA_HOME=$(STREAMS_INSTALL)/java ant

clean: 
	ant clean
	rm -rf output
