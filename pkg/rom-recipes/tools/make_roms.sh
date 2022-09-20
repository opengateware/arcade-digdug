#!/usr/bin/env bash

CORE=digdug
PARENT=$(dirname $PWD)
XML=$PARENT/xml
ROMS=$PARENT/roms
ASSETS=$PARENT/Assets/$CORE/common

find ${XML} -name '*.mra' | while read line; do
    echo "Processing file '$line'"
    orca -z ${ROMS} -O ${ASSETS} "$line"
done

exit 0