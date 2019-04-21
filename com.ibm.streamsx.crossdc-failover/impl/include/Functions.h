/*
===================================================
# Licensed Materials - Property of IBM
# Copyright IBM Corp. 2018, 2019
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
===================================================
*/
/*
===================================================
First created on: Oct/08/2018
Last modified on: Apr/19/2019

This file contains the C++ native functions used in the
streamsx.crossdc-failover toolkit.
This toolkit also has a custom Java operator in the
impl/java/src directory.
===================================================
*/
#ifndef FUNCTIONS_H_
#define FUNCTIONS_H_

// Include this SPL file so that we can use the SPL functions and types in this C++ code.
#include "SPL/Runtime/Function/SPLFunctions.h"
#include <vector>
#include <sstream>
#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <dirent.h>

// Define a C++ namespace that will contain our native function code.
namespace tuple_serializer_deserializer {
	// By including this line, we will have access to the SPL namespace and anything defined within that.
	using namespace SPL;

	// Prototype for our native functions are declared here.
	void serializeTuple(Tuple const & tuple, blob & rblob);
	void deserializeTuple(Tuple & tuple, blob const & rblob);
	template<class T1>
	void serializeDataItem(T1 const & value, blob & rblob);
	template<class T1>
	void deserializeDataItem(T1 & value, blob const & rblob);
	int32 delete_files_in_a_directory(rstring const & directory, rstring const & extension);

	// Serialize the given tuple into a blob (byte array).
	inline void serializeTuple(Tuple const & tuple, SPL::blob & rblob)
	{
		SPL:NativeByteBuffer buf;
		tuple.serialize(buf);
		rblob.adoptData(buf.getPtr(), buf.getSerializedDataSize());
		buf.setAutoDealloc(false);
	}

	// Deserialize the given blob into its original tuple form.
	inline void deserializeTuple(Tuple & tuple, SPL::blob const & rblob)
	{
		size_t size;
		const unsigned char * data = rblob.getData(size);
		SPL:NativeByteBuffer buf((unsigned char *)data, size);
		tuple.deserialize(buf);
	}

	// Serialize any given data item made of some SPL type into a blob (byte array)
	template<class T1>
	void serializeDataItem(T1 const & value, blob & rblob) {
		// Serialize a given value.
		SPL::NativeByteBuffer value_nbf;
		value_nbf << value;
		unsigned char * valueData = value_nbf.getPtr();
		uint32_t valueSize = value_nbf.getSerializedDataSize();
		SPL::Functions::Collections::clearM(rblob);
		rblob.setData(valueData, valueSize);
	}

	// Deserialize a given blob into its original data item made of some SPL type.
	template<class T1>
	void deserializeDataItem(T1 & value, blob const & rblob) {
		// Deserialize a given blob.
		size_t valueSize;
		unsigned char * valueData = (unsigned char *)rblob.getData(valueSize);
		SPL::NativeByteBuffer value_nbf(valueData, valueSize);
		value_nbf >> value;
	}

	// Delete all the files in a given directory matching a given extension.
	// It returns the number of files deleted if this task is successful.
	// If it is an invalid directory, then it will return -1.
	inline int32 delete_files_in_a_directory(rstring const & directory, rstring const & extension) {
		DIR *myDir;
		struct dirent *ent;
		int32 deletedFileCnt = 0;

		if ((myDir = opendir (directory.c_str())) != NULL) {
			/*
			std::cout << "Deleting files in this directory: " <<
				directory << ", File extension: " << extension << std::endl;
			*/

			// Delete all the files with a given file extension found in a given directory.
			while ((ent = readdir (myDir)) != NULL) {
				std::string fileName(ent->d_name);
				boolean deleteThisFile = false;

				if (extension == "") {
					// There is no extension given to us.
					// We can delete every file without matching the file extension.
					deleteThisFile = true;
				} else if (SPL::Functions::String::findFirst(fileName, extension, 0) != -1) {
					// Given file extension is present in the file name.
					// Mark this file for deletion.
					deleteThisFile = true;
				} else {
					deleteThisFile = false;
				}

				if (deleteThisFile == true) {
					// Delete this file now.
					int32 err = 0;
					SPL::Functions::File::remove(directory + "/" + fileName, err);
					deletedFileCnt++;
					/*
					std::cout << deletedFileCnt << ") Deleting the file " << fileName <<
						" in the " << directory << " directory." << std::endl;
					*/
				}
			}

			closedir (myDir);
			return(deletedFileCnt);
		} else {
			// Could not open directory.
			// std::cout << "Unable to open the " << directory << " directory." << std::endl;
			return (-1);
		}
	}

	// Get a list of names of all the files in a directory with a given file extension
    // It will fill the names of the files in the list passed by the caller as a method argument.
    // It will return the number of file names in that list.
	inline int32 get_file_names_in_a_directory(rstring const & directory,
			rstring const & extension, SPL::list<rstring> & fileNamesList) {
		DIR *myDir;
		struct dirent *ent;
		int32 matchedFileCnt = 0;

		if ((myDir = opendir (directory.c_str())) != NULL) {
			/*
			std::cout << "Listing files in this directory: " <<
				directory << ", File extension: " << extension << std::endl;
			*/

			// Collect all the file names with a given file extension found in a given directory.
			while ((ent = readdir (myDir)) != NULL) {
				std::string fileName(ent->d_name);
				boolean collectThisFile = false;

				if (extension == "") {
					// There is no extension given to us.
					// We can collect every file without matching the file extension.
					collectThisFile = true;
				} else if (SPL::Functions::String::findFirst(fileName, extension, 0) != -1) {
					// Given file extension is present in the file name.
					// Mark this file for collection.
					collectThisFile = true;
				} else {
					collectThisFile = false;
				}

				if (collectThisFile == true) {
					// Collect this file now.
					fileNamesList.push_back(fileName);
					matchedFileCnt++;
					/*
					std::cout << matchedFileCnt << ") Collecting the file " << fileName <<
						" in the " << directory << " directory." << std::endl;
					*/
				}
			}

			closedir (myDir);
			return(matchedFileCnt);
		} else {
			// Could not open directory.
			// std::cout << "Unable to open the " << directory << " directory." << std::endl;
			return (-1);
		}
	}

	// Inline native function to launch an external application within the SPL code.
	// This function takes one rstring argument through which the caller must pass the
	// name of the application to launch (as a fully qualified path: /tmp/test/my_script.sh).
	inline int32 launch_app(rstring const & appName) {
	   FILE *fpipe;
	   int32 rc = 0;
	   int bufSize = 16*1024;
	   char outStreamResult[bufSize+100];

	   // Open a pipe with the application name as provided by the caller.
	   fpipe = (FILE*)popen(appName.c_str(), "r");

	   if (!fpipe) {
		   SPLAPPTRC(L_INFO, "Failure while launching " + appName, "APP_LAUNCHER");
		   rc = 1;
		   return(rc);
	   } else {
		   SPLAPPTRC(L_DEBUG, "Successfully launched " + appName, "APP_LAUNCHER");
	   }

	   // If we opened the pipe in "r" mode, then we should wait here to
	   // fully read the stdout results coming from the launched application.
	   //
	   // NOTE: In case if we want to do the "w" mode, then it is necessary for us
	   // to feed the required input expected by the launched application via the
	   // stdin of the pipe.
	   while (fgets(outStreamResult, bufSize, fpipe) != NULL) {
		   SPLAPPTRC(L_TRACE, "Result from launched application: " +
			   std::string(outStreamResult), "APP_LAUNCHER");
	   }

	   // Close the pipe.
	   pclose (fpipe);
	   return(rc);
	}
}
#endif
