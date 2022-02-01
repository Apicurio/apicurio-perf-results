#!/bin/bash

REPORT_JAR=gatling-report.jar
if [[ ! -f $REPORT_JAR ]] ; then 
    wget --no-check-certificate https://maven-eu.nuxeo.org/nexus/service/local/repositories/vendor-releases/content/org/nuxeo/tools/gatling-report/6.0/gatling-report-6.0-capsule-fat.jar
    mv gatling-report-6.0-capsule-fat.jar $REPORT_JAR
fi

# Currently only processing all tests configured with 10u-600i and 30u-600i
# i.e. 10u means 10 users and 600i means 600 iterations
E2E_SIMULATIONS_TO_ANALYZE="10u-600i 30u-600i"

E2E_TESTS_LOG_FILES=""
for simulation in $E2E_SIMULATIONS_TO_ANALYZE ; do
    echo "simulation $simulation will be analyzed"
    for logfile in $(find **/End2EndSimulation/*$simulation/simulation.log) ; do
        E2E_TESTS_LOG_FILES="$E2E_TESTS_LOG_FILES $logfile"
    done
done

mkdir -p reports
python ./scripts/generate-reports.py $E2E_TESTS_LOG_FILES

CP_TESTS_LOG_FILES=""
for logfile in $(find **/ControlPlaneSimulation/*50u-300i/simulation.log) ; do
    CP_TESTS_LOG_FILES="$CP_TESTS_LOG_FILES $logfile"
done

python ./scripts/generate-reports.py $CP_TESTS_LOG_FILES

echo "SUCCESS"