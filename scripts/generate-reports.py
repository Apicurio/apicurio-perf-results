import os
import sys
import hashlib
import base64

simulations = sys.argv[1:]
print("Trend report processing", simulations)

# trend report
latestSimulation = simulations[-1]
latestSimulationName = latestSimulation.replace("/", "-").replace("simulation.log", "")[:-1]

reports = os.listdir("reports")
generateTrendReport = True
for report in reports:
    if report == latestSimulationName:
        if "trend" in os.listdir("reports/"+latestSimulationName):
            print("Trend report already exists, skipping", latestSimulationName)
            generateTrendReport = False
if generateTrendReport:
    trendReportId = hashlib.md5(base64.encodebytes(latestSimulationName.encode("UTF-8"))).hexdigest()
    os.system("java -jar gatling-report.jar " + " ".join(simulations) + " -o reports/"+latestSimulationName+"/trend")
    os.system("java -jar gatling-report.jar " + " ".join(simulations) + " > reports/"+latestSimulationName+"/trend/stats.csv")
    os.system("REPORT_ID=" + trendReportId + " LOG_FILES=\"" + " ".join(simulations) + "\" ./scripts/generate-summary.sh reports/"+latestSimulationName+"/trend")

print("Diff report processing")

# diff report
for previous, current in zip(simulations, simulations[1:]):
    print("Processing", previous, current)
    diffFolder = current.replace("/", "-").replace("simulation.log", "")[:-1]
    
    diffs = os.listdir("reports")
    generateDiff = True
    for diff in diffs:
        if diff == diffFolder:
            if "diff" in os.listdir("reports/"+diffFolder):
                print("Diff report already exists, skipping")
                generateDiff = False
    if generateDiff :
        diffid = hashlib.md5(base64.encodebytes((previous+current).encode("UTF-8"))).hexdigest()
        os.system("java -jar gatling-report.jar " + previous + " " + current + " -o reports/"+diffFolder+"/diff" + " --yaml --output-name diff.yaml")
        os.system("java -jar gatling-report.jar " + previous + " " + current + " -o reports/"+diffFolder+"/diff" + " -f")
        os.system("REPORT_ID=" + diffid + " LOG_FILES=\"" + previous + " " + current + "\" ./scripts/generate-summary.sh reports/" + diffFolder+"/diff")

