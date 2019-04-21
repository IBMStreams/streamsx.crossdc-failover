# Copyright (C)2019, International Business Machines Corporation and  
# others. All Rights Reserved.                        
.PHONY: build all distributed clean

#IMPORTANT
#---------
STREAMS_CROSSDC_FAILOVER_TOOLKIT ?= $(PWD)/../../com.ibm.streamsx.crossdc-failover
ifeq ($(STREAMS_STUDIO_BUILDING), 1)
    $(info Building from Streams Studio, use env vars set by studio)
    SPLC = $(STREAMS_STUDIO_SC_PATH)
    DATA_DIR = $(STREAMS_STUDIO_DATA_DIRECTORY)
    OUTPUT_DIR = $(STREAMS_STUDIO_OUTPUT_DIRECTORY)
    TOOLKIT_PATH = $(STREAMS_STUDIO_SPL_PATH)
else
    $(info build use env settings)
    ifndef STREAMS_INSTALL
        $(error require streams environment STREAMS_INSTALL)
    endif
    SPLC = $(STREAMS_INSTALL)/bin/sc
    DATA_DIR = data
    OUTPUT_DIR = output
    TOOLKIT_PATH = $(STREAMS_CROSSDC_FAILOVER_TOOLKIT)
endif

SPL_MAIN_COMPOSITE = com.ibm.streamsx.crossdc.failover.sample::CrossDataCenterFailoverSample

# You must change this line to point to your INET SERVER TOOLKIT directory.
INET_SERVER_TOOLKIT_HOME ?= $(HOME)/streamsx.inetserver

# If the user sets the STREAMS_SPLPATH environment variable,
# then the value set in the previous line will be ignored.
#
ifndef STREAMS_SPLPATH
   SPLC_FLAGS ?= -a -z -t $(INET_SERVER_TOOLKIT_HOME)
else
   SPLC_FLAGS ?= -a -z 
endif

SPL_CMD_ARGS ?=

build: distributed

all: clean build

distributed:
	$(SPLC) $(SPLC_FLAGS) -M $(SPL_MAIN_COMPOSITE) -t ${TOOLKIT_PATH} --data-dir $(DATA_DIR) --output-dir $(OUTPUT_DIR) $(SPL_CMD_ARGS)

clean:
	$(SPLC) $(SPLC_FLAGS) -M $(SPL_MAIN_COMPOSITE) -t ${TOOLKIT_PATH} --data-dir $(DATA_DIR) --output-dir $(OUTPUT_DIR) -C $(SPL_CMD_ARGS)
	rm -rf output
