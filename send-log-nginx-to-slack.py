#!/usr/bin/env python3
import requests
from datetime import datetime, timedelta  # Import timedelta explicitly

# Specify the path to your NGINX access log file
LOG_FILE = "/home/design-api.swiftpodapp.com/logs/access.log"

# Define a dictionary to store counts of status code 500 and corresponding Request Paths
request_paths_500 = {}

# Calculate the start time as the beginning of the previous day
start_time = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0) - timedelta(days=1)

# Calculate the end time as the end of the previous day
end_time = datetime.now().replace(hour=23, minute=59, second=59, microsecond=0) - timedelta(days=1)

# Read the log file and count occurrences of status code 500 and store corresponding Request Paths
with open(LOG_FILE, 'r') as file:
    for line in file:
        # Split the log entry by space and get the date and time
        parts = line.split()
        
        # Extract date, time, and status code from the log entry
        date_str = parts[3][1:]
        status_code = parts[8]
        
        # Construct the datetime object from date and time strings
        log_datetime = datetime.strptime(date_str, '%d/%b/%Y:%H:%M:%S')
        
        # If the log datetime is within the previous day
        if start_time <= log_datetime <= end_time:
            # Get the HTTP status code
            status_code = line.split()[8]
            # If the status code is 500, extract the Request Path
            if status_code == '500':
                request_path = line.split('"')[1].split()[1]
                # Increment the count for the Request Path
                if request_path in request_paths_500:
                    request_paths_500[request_path] += 1
                else:
                    request_paths_500[request_path] = 1

# Calculate total requests with status code 500
total_requests_500 = sum(request_paths_500.values())

# Prepare the message to be sent to Slack
message = f"Access log daily report: {start_time.strftime('%Y-%m-%d')}\nTotal requests with status code 500: {total_requests_500}\n"
if total_requests_500 > 0:
    message += "Request paths with status code 500:\n"
    for path, count in request_paths_500.items():
        message += f"   - {path}: {count}\n"

# Slack webhook URL
slack_webhook_url = "https://hooks.slack.com/services/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"

# Send message to Slack
slack_data = {'text': message}
response = requests.post(slack_webhook_url, json=slack_data)

# Check if the message was sent successfully
if response.status_code == 200:
    print("Report sent to Slack successfully!")
else:
    print(f"Failed to send report to Slack! Status code: {response.status_code}")