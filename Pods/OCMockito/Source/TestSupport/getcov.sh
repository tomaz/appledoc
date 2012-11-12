#!/bin/bash
source env.sh

LCOV_INFO=OCMockito.info
OBJ_DIR=${OBJECT_FILE_DIR_normal}/${NATIVE_ARCH}

# Remove old report
pushd ${BUILT_PRODUCTS_DIR}
	if [ -e lcov ]; then
		rm -r lcov
	fi
popd

# Create and enter the coverage directory
cd ${BUILT_PRODUCTS_DIR}
mkdir lcov
cd lcov

# Gather coverage data
lcov -d ${OBJ_DIR} --capture -o ${LCOV_INFO}

# Exclude things we don't want to track
lcov -d ${OBJ_DIR} --remove ${LCOV_INFO} "/Developer/*" -o ${LCOV_INFO}
lcov -d ${OBJ_DIR} --remove ${LCOV_INFO} "/xcode_4.1_and_ios_sdk_4.3/*" -o ${LCOV_INFO}

# Generate and display html
genhtml --output-directory . ${LCOV_INFO}
open index.html
