import os

indexTextTemplate = """<!DOCTYPE html>
<html>
<head><title>Apicurio Perf Results</title></head>
<body>
    <h2>Apicurio Perf Results</h2>
    <hr>
	<h3>Reports</h2>
    <hr>
    <ul>
	{reportsList}
	</ul>
	<h3>Tests results</h2>
    <hr>
    <ul>
	{resultsList}
	</ul>
</body>
</html>
"""

def index_reports():
	allreportdirs = os.listdir("reports")
	allreportdirs.sort(reverse=True)

	it = ""
	for reportdir in allreportdirs:
		it += "\t\t<li>\n\t\t\t" + reportdir +"\t <a href='" + "reports"+ "/"+reportdir+ "/trend/index.html" + "'>" + "trend report"+ "</a>\n\t" + "<a href='" + "reports"+ "/"+reportdir+ "/diff/index.html" + "'>" + "diff report"+ "</a>\n\t\t</li>\n"
	return it

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
reportsList = index_reports()
resultsList = index_results(".")

it = indexTextTemplate.format(reportsList=reportsList, resultsList=resultsList)

index = open('./index.html', "w")
index.write(it)
