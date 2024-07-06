#!/bin/bash

# File:
# Time-stamp <06-July-2024>
#
# Copyright (c) 2024 
#
# Author: Allan M Zuza
#
# Description: This script is used to reconsile the trycycler cluster ouput
# this script needs to be run multiple times as it requires manual intervention
# the script will also need to be run on one sample at a time.

set -euo pipefail

# write the stdout to a log file
date=$(date +"%Y-%m-%d-%T"  | sed 's/-//'g | sed s'/://'g)
if [ ! -d './logs' ] ; then mkdir -p './logs' ; fi

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1> logs/${date}_trycycler_reconsile.log 2>&1

usage() { echo "Usage: $0 [-R <PathToReads>] [-C <PathToClusters>] [-O <PathToOutdir>] $1

			-R Path to the filtered reads directory
			-C Path to cluster directories
            -O Path to output consensus sequence
			
			 " 
			 1>&2; exit 1; 
}

while getopts ":R:C:O:" o; do
	case "${o}" in
		R)
			R=${OPTARG}
			;;
		C)
			C=${OPTARG}
			;;
        O)
			C=${OPTARG}
			;;
		*)
			usage
			;;
	esac
done

shift "$((OPTIND-1))"


if [ -z "${R}" ] || [ -z "${C}" ] || [ -z "${O}" ] ; then
	usage
fi



#reads=$
#assembly=("/home/azuza/styphi/workflows/nextflow/results/trycycler")
samples=$(cat $1)


for id in $(cat samples); do
    echo $i
    for count in 001 002 003 004 005 006 007 007 009; do
        
        for i in "${C}/${id}/cluster_${count}"; do
            if [ -d ${i} ]; then
                trycycler msa --cluster_dir ${i} --threads 128
                echo ${i}
            fi

        done

    done


    for i in "${C}/${id}/cluster_*"; do

        trycycler partition --reads ${R}${id}.fastq.gz --cluster_dirs ${i}
        
    done


    for count in 001 002 003 004 005 006 007 007 009; do
        
        for i in "${C}/${id}/cluster_${count}"; do
            if [ -d ${i} ]; then
                trycycler consensus --cluster_dir ${i} --threads 128
                
            fi

        done

    done

    for i in "${C}/${id}"; do

        echo copying ${i}/cluster_*/7_final_consensus.fasta to ${O}/${id}_consensus.fasta
        cat ${i}/cluster_*/7_final_consensus.fasta > ${O}/${id}_consensus.fasta
    
    done
done
