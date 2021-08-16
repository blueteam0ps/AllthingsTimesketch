#!/bin/bash
# Automate timeline processing for an input triage zip file with file watcher
#
# Usage: chmod a+x ./l2t_ts_watch.sh && ./l2t_ts_watch.sh &
# Check the respective log file for status and errors 
# Change the PROCESSING_DIR to your directory
# Update your timesketch username and password in line 54
#
# Created by Mike Pilkington for use in SANS FOR608
# Inspired by https://github.com/ReconInfoSec/velociraptor-to-timesketch
# 
#  Updated by Janantha Marasinghe to include 
# -inotifywait logic
# -Used mime based checking to see if the file that was uploaded is a zip file
# -Error handling at key task levels
# -Updated log2timeline parameters to explicitely mention parsers for quick winevtx
# -Updated the logic to work with inotifywait
# Pending
# -Need to add the filter_windows.yaml to l2t parameters
# -Need to add queue management so that bulk zip exports are handled in batches
# IMPORTANT! You need inotifywait and unzip packages before you run this script

PROCESSING_DIR="/cases/processor"

process_files () {
	#unzip -o "${PROCESSING_DIR}/${FILE}" -d $PROCESSING_DIR
	SYSTEM=$(echo "$FILE" | cut -d "." -f 1)
	TIMESTAMPED_NAME=${SYSTEM,,}-$(date --utc +'%Y%m%dt%H%M%S')z
	echo [$(date --utc +'%Y-%m-%d %H:%M:%S') UTC] Received $FILE | tee -a $PROCESSING_DIR/$TIMESTAMPED_NAME.log
	echo [$(date --utc +'%Y-%m-%d %H:%M:%S') UTC] MD5 hash: $(md5sum $FILE) | tee -a $PROCESSING_DIR/$TIMESTAMPED_NAME.log
        echo [$(date --utc +'%Y-%m-%d %H:%M:%S') UTC] Starting to Unzipping of $FILE to $PROCESSING_DIR/$TIMESTAMPED_NAME | tee -a $PROCESSING_DIR/$TIMESTAMPED_NAME.log
	#Unzipping the triage package to a unique directory
	unzip -o -q "${PROCESSING_DIR}/${FILE}" -d $PROCESSING_DIR/$TIMESTAMPED_NAME
	
	if [ $? -ne 0 ]; then
		echo [$(date --utc +'%Y-%m-%d %H:%M:%S') UTC] Unzipping $FILE to $PROCESSING_DIR/$TIMESTAMPED_NAME Failed! | tee -a $PROCESSING_DIR/$TIMESTAMPED_NAME.log
	exit 1
	else
		echo [$(date --utc +'%Y-%m-%d %H:%M:%S') UTC] Unzipping $FILE to $PROCESSING_DIR/$TIMESTAMPED_NAME Successful! | tee -a $PROCESSING_DIR/$TIMESTAMPED_NAME.log
	fi

	echo [$(date --utc +'%Y-%m-%d %H:%M:%S') UTC] "Beginning Plaso creation of $PROCESSING_DIR/$TIMESTAMPED_NAME.plaso (this typically takes 20 minutes or more)..." | tee -a $PROCESSING_DIR/$TIMESTAMPED_NAME.log
	#Running Log2timeline process on the triage data set
	log2timeline.py --status_view none --worker_memory_limit 0 --parsers "esedb,lnk,olecf,pe,prefetch,recycle_bin,recycle_bin_info2,winevtx,winfirewall,winjob,winreg,custom_destinations,chrome_cache,chrome_preferences,firefox_cache,firefox_cache2,msiecf" --storage-file $PROCESSING_DIR/$TIMESTAMPED_NAME.plaso $PROCESSING_DIR/$TIMESTAMPED_NAME

	if [ $? -ne 0 ]; then
		echo [$(date --utc +'%Y-%m-%d %H:%M:%S') UTC] Failed running log2timeline process | tee -a $PROCESSING_DIR/$TIMESTAMPED_NAME.log
	exit 1
	else
		echo [$(date --utc +'%Y-%m-%d %H:%M:%S') UTC] Plaso file creation finished! | tee -a $PROCESSING_DIR/$TIMESTAMPED_NAME.log
	fi

	echo [$(date --utc +'%Y-%m-%d %H:%M:%S') UTC] "Beginning Timesketch import of $TIMESTAMPED_NAME-triage timeline (this typically takes an hour or more)..." | tee -a $PROCESSING_DIR/$TIMESTAMPED_NAME.log
	#Running Timesketch importer to import in the plaso file
	timesketch_importer -u username -p password --host http://127.0.0.1 --index_name plaso-$TIMESTAMPED_NAME --timeline_name $TIMESTAMPED_NAME-triage --sketch_name $TIMESTAMPED_NAME-sketch $PROCESSING_DIR/$TIMESTAMPED_NAME.plaso
	
	if [ $? -ne 0 ]; then
		echo [$(date --utc +'%Y-%m-%d %H:%M:%S') UTC] Failed to upload the plaso file via timesketch_importer | tee -a $PROCESSING_DIR/$TIMESTAMPED_NAME.log
	exit 1
	else
		echo [$(date --utc +'%Y-%m-%d %H:%M:%S') UTC] "Timesketch import finished" | tee -a $PROCESSING_DIR/$TIMESTAMPED_NAME.log
	fi
	#Deleting the triage uncompressed directory
	rm -r $PROCESSING_DIR/$TIMESTAMPED_NAME
	if [ $? -ne 0 ]; then
		echo [$(date --utc +'%Y-%m-%d %H:%M:%S') UTC] Failed to remove unzipped triage directory $PROCESSING_DIR/$TIMESTAMPED_NAME !! | tee -a $PROCESSING_DIR/$TIMESTAMPED_NAME.log
	exit 1
	else 
		echo [$(date --utc +'%Y-%m-%d %H:%M:%S') UTC] Removed unzipped triage directory $PROCESSING_DIR/$TIMESTAMPED_NAME Successfully | tee -a $PROCESSING_DIR/$TIMESTAMPED_NAME.log
	fi
	#Deleting the triage zip file
	rm $PROCESSING_DIR/$FILE
	if [ $? -ne 0 ]; then
		echo [$(date --utc +'%Y-%m-%d %H:%M:%S') UTC] Failed to remove triage zip file  $PROCESSING_DIR/$TIMESTAMPED_NAME !! | tee -a $PROCESSING_DIR/$TIMESTAMPED_NAME.log
	exit 1
	else
		echo [$(date --utc +'%Y-%m-%d %H:%M:%S') UTC] Removed triage zip file $PROCESSING_DIR/$TIMESTAMPED_NAME Successfully | tee -a $PROCESSING_DIR/$TIMESTAMPED_NAME.log
	fi
	echo [$(date --utc +'%Y-%m-%d %H:%M:%S') UTC] "Processing job finished for $FILE" | tee -a $PROCESSING_DIR/$TIMESTAMPED_NAME.log

	        }

# run on specific events and return the filename only
inotifywait -m -r -e create --format '%f' "$PROCESSING_DIR" | while read FILE

do
  # only if mime type is zip
  if [ "$(mimetype -b $FILE)" == "application/zip" ]
    then
       process_files $FILE &
       #unzip -o "${PROCESSING_DIR}/${FILE}" -d $PROCESSING_DIR
  fi
done
