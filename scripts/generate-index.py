import os

indexTextTemplate = """<!DOCTYPE html>
<html>
<head><title>Apicurio Perf Results</title></head>
<body>
    <h2>Apicurio Perf Results</h2>
    <hr>
	<h3>End2EndSimulation Reports</h2>
    <hr>
    <ul>
	{e2eReportsList}
	</ul>
	<h3>ControlPlaneSimulation Reports</h2>
    <hr>
    <ul>
	{cpReportsList}
	</ul>
	<h3>Tests results</h2>
    <hr>
    <ul>
	{resultsList}
	</ul>
</body>
</html>
"""

def generate_reports_list(reportdirs):
	it = ""
	for reportdir in reportdirs:
		it += "\t\t<li>\n\t\t\t" + reportdir +"\t <a href='" + "reports"+ "/"+reportdir+ "/trend/index.html" + "'>" + "trend report"+ "</a>\n\t" + "<a href='" + "reports"+ "/"+reportdir+ "/diff/index.html" + "'>" + "diff report"+ "</a>\n\t\t</li>\n"
	return it

def index_e2e_reports():
	allreportdirs = os.listdir("reports")
	allreportdirs.sort(reverse=True)
	e2ereportsdirs = [d for d in allreportdirs if "End2EndSimulation" in d]
	generate_reports_list(e2ereportsdirs)

def index_cp_reports():
	allreportdirs = os.listdir("reports")
	allreportdirs.sort(reverse=True)
	cpreportsdirs = [d for d in allreportdirs if "ControlPlaneSimulation" in d]
	generate_reports_list(cpreportsdirs)

def index_results(folderPath):
	print("Indexing: " + folderPath +'/')
	#Getting the content of the folder
	allfiles = os.listdir(folderPath)
	allfiles.sort(reverse=True)

	files = []
	for af in allfiles:
		if af == "reports":
			continue
		if af == ".git":
			continue
		if af == ".github":
			continue
		if af == "scripts" and folderPath == ".":
			continue
		files.append(af)

	it = ""
	for file in files:
		if file == 'index.html' and not folderPath == ".":
			it += "\t\t<li>\n\t\t\t<a href='" + folderPath+ "/"+file + "'>" + folderPath+ "/"+file + "</a>\n\t\t</li>\n"
		#Recursive call to continue indexing
		if os.path.isdir(folderPath+'/'+file):
			it += index_results(folderPath + '/' + file)
	return it


#Indexing reports
e2eReportsList = index_e2e_reports()
cpReportsList = index_cp_reports()
resultsList = index_results(".")

it = indexTextTemplate.format(e2eReportsList=e2eReportsList, cpReportsList=cpReportsList, resultsList=resultsList)

index = open('./index.html', "w")
index.write(it)
