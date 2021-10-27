#!/bin/bash

set -a

declare -i THROUGHPUT_CHANGE_DROP_LIMIT=0
declare -i RESPONSE_TIME_AVG_CHANGE_DROP_LIMIT=0

LAST_COMMIT=$(git log -1 --pretty=format:%H)

echo "Checking last commit $LAST_COMMIT"

MODIFIED_FILES=$(git diff-tree --no-commit-id --name-only -r $LAST_COMMIT)
echo "Modified files are $MODIFIED_FILES"

REPORT_EXISTS="false"
for file in $MODIFIED_FILES ; do
    if [[ $file == "reports/"*"/diff/diff.yaml" ]]; then
        echo "Reading diff report $file"
        # print first lines of diff report
        echo "---"
        head -n 7 $file
        echo "---"

        # NOTE we cannot parse the diff yaml file with a yaml parser because gatling-report generates a badly formatter yaml file
        # read throughput percetage change, located in line 2
        THROUGHPUT_CHANGE=$(awk '{if(NR==2) print $0}' $file | yq read - gain)
        # read response time average percetage change, located in line 6
        RESPONSE_TIME_AVG_CHANGE=$(awk '{if(NR==6) print $0}' $file | yq read - gain)
        
        SEND_ALARM="false"

        # throughput is better when it increases, so we check if the current value is less than the limit we set to detect changes for the worse
        if (( $(echo "$THROUGHPUT_CHANGE $THROUGHPUT_CHANGE_DROP_LIMIT" | awk '{print ($1 < $2)}') )); then
            SEND_ALARM="true"
        fi

        # response time average is better when it decreases, so we check if the current average is greater than the limit we set to detect changes for the worse
        if (( $(echo "$RESPONSE_TIME_AVG_CHANGE $RESPONSE_TIME_AVG_CHANGE_DROP_LIMIT" | awk '{print ($1 > $2)}') )); then
            SEND_ALARM="true"
        fi

        if [[ $SEND_ALARM == "true" ]]; then

            echo "Performance drop detected!!"

            rm -f diff-report-notification.md
            echo "---"
            echo "*Apicurio Registry Perf Results*" | tee -a diff-report-notification.md
            echo "" | tee -a diff-report-notification.md
            echo "Performance drop detected in:" | tee -a diff-report-notification.md
            echo "" | tee -a diff-report-notification.md
            echo "  $file" | tee -a diff-report-notification.md
            echo "" | tee -a diff-report-notification.md
            echo "Diff results (Throughput and Response time average):" | tee -a diff-report-notification.md
            echo "\`\`\`" | tee -a diff-report-notification.md
            head -n 7 $file | while read line || [[ -n $line ]];
            do
                echo "  "$line | tee -a diff-report-notification.md
            done
            echo "\`\`\`" | tee -a diff-report-notification.md
            echo "Link: http://www.apicur.io/apicurio-perf-results/" | tee -a diff-report-notification.md
            echo "---"
            cat diff-report-notification.md

            rm -f msg-text.json
            echo "{\"text\": \"" | tee -a msg-text.json
            cat diff-report-notification.md | tee -a msg-text.json

            rm -f msg.json
            awk '{printf "%s\\n", $0}' msg-text.json > msg.json

            echo "\"}" | tee -a msg.json

            cat msg.json

            if [[ ! -z $GOOGLE_CHAT_WEBHOOK ]]; then
                curl -i $GOOGLE_CHAT_WEBHOOK -X POST -H "Content-Type: application/json" --data-binary @msg.json
            else
                echo "GOOGLE_CHAT_WEBHOOK not set, skipping notification send"
            fi

        fi

    fi
done

echo "SUCCESS"