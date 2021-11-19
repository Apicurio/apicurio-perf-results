#!/bin/bash

REPORT_JAR=gatling-report.jar
if [[ ! -f $REPORT_JAR ]] ; then 
    wget --no-check-certificate https://maven-eu.nuxeo.org/nexus/service/local/repositories/vendor-releases/content/org/nuxeo/tools/gatling-report/6.0/gatling-report-6.0-capsule-fat.jar
    mv gatling-report-6.0-capsule-fat.jar $REPORT_JAR
fi

# Currently only processing all tests configured with 10u-600i
# that means 10 users with 600 iterations
E2E_TESTS_LOG_FILES=""
for logfile in $(find **/End2EndSimulation/*10u-600i/simulation.log) ; do
    E2E_TESTS_LOG_FILES="$E2E_TESTS_LOG_FILES $logfile"
done

mkdir -p reports
python ./scripts/generate-reports.py $E2E_TESTS_LOG_FILES

CP_TESTS_LOG_FILES=""
for logfile in $(find **/ControlPlaneSimulation/*50u-300i/simulation.log) ; do
    CP_TESTS_LOG_FILES="$CP_TESTS_LOG_FILES $logfile"
done

python ./scripts/generate-reports.py $CP_TESTS_LOG_FILES

echo "SUCCESS"