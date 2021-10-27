if [ -z "$(git status --porcelain)" ]; then 
    echo "No changes, skipping commit report"
else 
    git config --global user.name "apicurio-ci"
    git config --global user.email "apicurio.ci@gmail.com"
    git add reports
    git add index.html
    git commit -m "Automated test results report update"
    git push
fi