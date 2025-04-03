#!/bin/bash

# Script to upload files from a local directory to a Nexus repository
# using curl, supporting various file extensions.

set -e

NEXUS_URL="https://nexus.domain.com"
NEXUS_REPOSITORY="my-nexus-repo"
NEXUS_USER="user"
NEXUS_PASSWORD="password"

# ARCHIVE_DIR might be in root directory of your localhost
ARCHIVE_DIR="/dir"
FILE_PATTERN="*.jar"
LOG_FILE="./packages-upload.log"

NEXUS_PATH="$NEXUS_URL/repository/$NEXUS_REPOSITORY"
> "$LOG_FILE"
for FILE_PATH in $(find "$ARCHIVE_DIR" -name "$FILE_PATTERN");
do
  HTTP_CODE=$(curl -k -s -w "%{http_code}" -o /dev/null -u "$NEXUS_USER:$NEXUS_PASSWORD" --upload-file "$FILE_PATH" "$NEXUS_PATH$FILE_PATH")
  CURL_EXIT_CODE=$?

  if [[ $CURL_EXIT_CODE -ne 0 || $HTTP_CODE -ge 400 ]];
  then
    ERROR_MSG="$(date '+%d-%m-%Y %H:%M:%S') | Failed to upload: $NEXUS_PATH$FILE_PATH\n | HTTP Code: $HTTP_CODE\n | Curl Exit Code: $CURL_EXIT_CODE\n"
    echo -e "$ERROR_MSG" | tee -a "$LOG_FILE"
  else
    SUCCESS_MSG="$(date '+%d-%m-%Y %H:%M:%S') | Upload succesful: $NEXUS_PATH$FILE_PATH\n | HTTP Code: $HTTP_CODE\n"
    echo -e "$SUCCESS_MSG" | tee -a "$LOG_FILE"
  fi
done
