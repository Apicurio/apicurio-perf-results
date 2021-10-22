#!/bin/bash

REPORT_JAR=gatling-report.jar
if [[ ! -f $REPORT_JAR ]] ; then 
    wget --no-check-certificate https://maven-eu.nuxeo.org/nexus/service/local/repositories/vendor-releases/content/org/nuxeo/tools/gatling-report/6.0/gatling-report-6.0-capsule-fat.jar
    mv gatling-report-6.0-capsule-fat.jar $REPORT_JAR
fi

# Currently only processing all tests configured with 10u-600i
# that means 10 users with 600 iterations
ALL_LOG_FILES=""
for logfile in $(find **/End2EndSimulation/*10u-600i/simulation.log) ; do
    ALL_LOG_FILES="$ALL_LOG_FILES $logfile"
done

REPORT_ID=$(echo $ALL_LOG_FILES | md5sum | awk '{ print $1 }')
GENERATE_REPORT=true
for ridfile in $(find reports/*/reportid) ; do
    rid=$(cat $ridfile)
    if [[ $rid == $REPORT_ID ]] ; then
        #report for the current log files as already been generated
        GENERATE_REPORT=false
    fi
done

if [[ $GENERATE_REPORT == "true" ]] ; then
    CURRENT_REPORT=reports/$(date --iso-8601=seconds)

    java -jar $REPORT_JAR $ALL_LOG_FILES -o $CURRENT_REPORT

    echo $REPORT_ID > $CURRENT_REPORT/reportid

    echo "Summary:" | tee -a $CURRENT_REPORT/summary.yaml
    echo "  reportId: $REPORT_ID" | tee -a $CURRENT_REPORT/summary.yaml
    echo "  logFiles:" | tee -a $CURRENT_REPORT/summary.yaml
    for logfile in $ALL_LOG_FILES ; do
        echo "    - $logfile" | tee -a $CURRENT_REPORT/summary.yaml
    done

    java -jar $REPORT_JAR $ALL_LOG_FILES > $CURRENT_REPORT/stats.csv
else
    echo "Skipping report generation because report already exists for current log files"
fi
