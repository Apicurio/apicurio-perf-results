#!/bin/bash

TARGET=$1

if [[ -z $TARGET ]] ; then
    echo "target directory is mandatory"
    exit 1
fi

if [[ -z $REPORT_ID ]] ; then
    echo "REPORT_ID env var is mandatory"
    exit 1
fi

if [[ -z $LOG_FILES ]] ; then
    echo "LOG_FILES env var is mandatory"
    exit 1
fi

echo "Generating reportid file"
echo $REPORT_ID > $TARGET/reportid

echo "Generating summary file"

echo "Summary:" | tee -a $TARGET/summary.yaml
echo "  reportId: $REPORT_ID" | tee -a $TARGET/summary.yaml
echo "  logFiles:" | tee -a $TARGET/summary.yaml
for logfile in $LOG_FILES ; do
    echo "    - $logfile" | tee -a $TARGET/summary.yaml
done