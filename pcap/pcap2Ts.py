#!/bin/python3
__AUTHOR__ = 'Janantha Marasinghe'
__VERSION__ = "0.1"
__DATE__ = "2022/04/30"
__LICENSE__ = "Apache License 2.0"
__STATUS__ = "Production"

"""
Description: This script takes the output from Tshark PCAP -> CSV conversion
e.g.
tshark -r traffic.pcap -T fields -E header=y -E separator=, -E quote=d -E occurrence=a -e frame.number -e frame.time -e ip.proto -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport 
and makes it compatible for Timesketch ingestion.


Install dependencies with:
pip install -r requirements.txt
pip3 install -r requirements.txt
"""
import csv
import os
import pandas as pd
import argparse
import sys
import datetime

def main():

	parser = argparse.ArgumentParser()
	parser.add_argument("--path", help="Full path to the directory containing the CSV files")
	args = parser.parse_args()

	if len(sys.argv) <= 1:
		print('pcap2Ts.py --Full path to the directory containing the CSV files')
		exit(1)

	for csvfname in os.listdir(args.path):
		path_to_file = os.path.join(args.path, csvfname)
		basefile=os.path.basename(path_to_file)

		#Get the filename without extension
		orgfname=os.path.splitext(basefile)[0]

		#Define the file name for the output CSV
		outfile = orgfname + datetime.datetime.now().strftime('%Y%m%d%H%M%S')
		df = pd.read_csv(path_to_file)

		ts_df = df.copy()
		ts_df.rename(columns={'frame.number': 'frame_no', 'frame.time': 'datetime','ip.proto': 'protocol','ip.src': 'src_ip','ip.dst': 'dst_ip', 'tcp.srcport': 'src_port', 'tcp.dstport': 'dst_port'}, inplace=True)
		ts_df['datetime']= pd.to_datetime(ts_df['datetime'])

		ts_df['data_type'] = 'pcap:wireshark:entry'
		ts_df['timestamp_desc'] = 'Time Logged'
		ts_df['source_short'] = 'LOG'
		ts_df['source'] = 'Network'
		ts_df['message'] = ts_df['src_ip'].astype(str) + " : " + ts_df['src_port'].astype(str).apply(lambda x: x.replace('.0','')) + " -> " + ts_df['dst_ip'].astype(str) + " : " + ts_df['dst_port'].astype(str).apply(lambda x: x.replace('.0',''))
		ts_df.to_csv(outfile+".csv", index=False, header=True, quotechar='"')



if __name__=='__main__':
	main()
