#!/bin/sh

gen_podspec() {
	ARCH=$1
	EW_PLUGIN_DIR="`pwd`/../../ew_monero/macos"
	BASE_FILENAME="ew_monero_base.podspec"
	BASE_FILE_PATH="${EW_PLUGIN_DIR}/${BASE_FILENAME}"
	DEFAULT_FILENAME="ew_monero.podspec"
	DEFAULT_FILE_PATH="${EW_PLUGIN_DIR}/${DEFAULT_FILENAME}"
	rm -f $DEFAULT_FILE_PATH
	cp $BASE_FILE_PATH $DEFAULT_FILE_PATH
	sed -i '' "s/#___VALID_ARCHS___#/${ARCH}/g" $DEFAULT_FILE_PATH
}

gen_project() {
	ARCH=$1
	EW_DIR="`pwd`/../../macos/Runner.xcodeproj"
	DEFAULT_FILENAME="project.pbxproj"
	DEFAULT_FILE_PATH="${EW_DIR}/${DEFAULT_FILENAME}"
	sed -i '' "s/ARCHS =.*/ARCHS = \"${ARCH}\";/g" $DEFAULT_FILE_PATH
}

gen() {
	ARCH=$1
	gen_podspec "${ARCH}"
	gen_project "${ARCH}"
}