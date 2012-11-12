#!/bin/sh
source env.sh

OBJ_DIR=${OBJECT_FILE_DIR_normal}/${NATIVE_ARCH}

# Clean out the old data
lcov -d ${OBJ_DIR} --zerocounters
