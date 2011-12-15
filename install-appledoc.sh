#!/bin/sh

BINARY_DIR=/usr/local/bin/
TEMPLATES_DIR=~/.appledoc

usage() {
cat <<EOF
Usage: $0 [-b binary_path] [-t templates_path]

Builds and installs appledoc

OPTIONS:
    -b  Path where binary will be installed. Default is $BINARY_DIR
    -t  Path where templates will be installed. Default is $TEMPLATES_DIR
    
EOF
}

while getopts "hb:t:" OPTION
do
	case $OPTION in
		h) usage
		   exit 0;;
		b) 
		   BINARY_DIR=$OPTARG;;
		t) 
		   TEMPLATES_DIR=$OPTARG;;
		[?])
			usage
			exit 1;;
	esac
done

echo "Building..."
xcodebuild -target appledoc -configuration Release install

echo "Installing binary to $BINARY_DIR"
cp /tmp/appledoc.dst/usr/local/bin/appledoc "$BINARY_DIR"

echo "Copying templates to $TEMPLATES_DIR"
cp -R Templates/ "$TEMPLATES_DIR"