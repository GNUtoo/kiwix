#!/bin/bash

# Binary
BINARY=$0
while [ `readlink $BINARY` ]
do
    BINARY=`readlink $BINARY`
done

if [ ! ${BINARY:0:1} = "/" ]
then
    BINARY=`dirname $BINARY`/`basename $BINARY`
fi

# Binary dir
BINARY_DIR=`dirname $BINARY`

# Take a look to the current directory
if [ -d "$BINARY_DIR/xulrunner" ]
then
    XULRUNNER=`find $BINARY_DIR/xulrunner -type f -name xulrunner`
fi

# Try to update $LD_LIBRARY_PATH
for DIR in `find $BINARY_DIR -type d -name xulrunner`; do
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DIR;
done

# Add /usr/local/lib to $LD_LIBRARY_PATH as it seems no always be the case per default
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

# If no xulrunner, get the path of the xulrunner install of the system
if [ ! "$XULRUNNER" ]
then
    XULRUNNER=`whereis xulrunner | cut -d" " -f2`
fi

# If no result print a message
if [ ! "$XULRUNNER" ] || [ ! -f "$XULRUNNER" ]
then
    echo "'xulrunner' is not installed, you have to install it to use Kiwix."
    exit;
fi

# Otherwise, launch Kiwix
exec $XULRUNNER $BINARY_DIR/application.ini $1
