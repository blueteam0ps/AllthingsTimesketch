#!/bin/bash
#
## Converts PCAP files using Tshark to CSVs with selected fields. This is a helper script to facilitate pcap ingestion into Google Timesketch platform
## Following fields are currently shown within the CSV for a pcap:
## frame.number, frame.time, ip.proto, ip.src, ip.dst, tcp.srcport, tcp.dstport
## AUTHOR - Janantha Marasinghe
##
# LICENSE - Apache License 2.0
# A permissive license whose main conditions require preservation of copyright and license notices.
# Contributors provide an express grant of patent rights.
# Licensed works, modifications, and larger works may be distributed under different terms and without source code.
#
# Usage:
# chmod a+x pcap2csv.sh
# ./pcap2csv.sh

#Checks if Tshark package is installed. If not it exits
function package_exists() {
	dpkg -s "$1" &> /dev/null
	return $?
}

if ! package_exists tshark ; then
	echo "Please install tshark before running this script! The script will exit now.."
	exit 0
fi

#Define the output directory for CSVs
outputdir="/opt/pcap2csv"

if [ ! -d $outputdir ]
then
	echo "Creating /opt/pcap2csv directory to store CSVs"
	mkdir -p /opt/pcap2csv
fi

read -p 'Enter the directory path to pcaps (e.g. /opt/input/):' pcapdir

for file in "$pcapdir"/*.pcap; do
	current_time=$(date "+%Y%m%d%H%M%S")
	filename=$(basename -s .pcap ${file})

tshark -r $file -T fields -E header=y -E separator=, -E quote=d -E occurrence=a -e frame.number -e frame.time -e ip.proto -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport > $outputdir/$filename.csv

done


