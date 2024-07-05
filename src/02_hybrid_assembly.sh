#!/bin/bash

# File:
# Time-stamp <05-July-2024>
#
# Copyright (c) 2024 
#
# Author: Allan M Zuza
#
# Description: This script is used to reconsile the trycycler cluster ouput
# this script needs to be run multiple times as it requires manual intervention
# the script will also need to be run on one sample at a time.


usage() { echo "Usage: $0 [-R <PathToReads>] [-C <PathToClusters>] 

			-R Path to the raw reads
			-C Path to cluster directories
			
			 " 
			 1>&2; exit 1; 
}

while getopts ":R:C:" o; do
	case "${o}" in
		R)
			R=${OPTARG}
			;;
		C)
			C=${OPTARG}
			;;
		*)
			usage
			;;
	esac
done

shift "$((OPTIND-1))"


if [ -z "${R}" ] || [ -z "${C}" ] ; then
	usage
fi



# write the stdout to a log file
date=$(date +"%Y-%m-%d-%T")
logDIR=(logs)
exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>"logs/trycycler_reconsile.log" 2>&1

#To allow trycycler to run the reconsile per directory, we need to loop through the cluster directories and run reconsile if the
# directory exists
for i in 001 002 003 004 005 006 007 007 009; do
    
    for i in "${C}/cluster_${i}"; do
        if [ -d ${i} ]; then
            trycycler reconcile --reads ${R} --cluster_dir ${i} --threads 64 --max_add_seq 3000
        fi

    done

done
