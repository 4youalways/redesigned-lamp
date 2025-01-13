#!/bin/bash

# This script runs bakta on a directory of fasta files

# Date: 2025-01-13
#
# Copyright (c) 2025 Malawi Liverpool Wellcome Trust
#
# Author: Allan Zuza
#
#Description: This script runs bakta on a directory of fasta files
#

usage() {
    echo "Usage: $0 -i <input_dir> -o <output_dir> -d <bakta_db_dir> -g <genus> -s <species> -t <threads>"
    exit 1
}


while getopts "i:o:d:g:s:t:" opt; do
    case $opt in
        i) input_dir=$OPTARG ;;
        o) output_dir=$OPTARG ;;
        d) bakta_db_dir=$OPTARG ;;
        g) genus=$OPTARG ;;
        s) species=$OPTARG ;;
        t) threads=$OPTARG ;;
        *) usage ;;
    esac
done

if [ -z "$input_dir" ] || [ -z "$output_dir" ] || [ -z "$bakta_db_dir" ] || [ -z "$genus" ] || [ -z "$species" ] || [ -z "$threads" ]; then
    usage
fi

# Create output directory
if [ ! -d "$output_dir" ]; then
    mkdir -p "$output_dir"
fi

# Run bakta
for i in "$input_dir"/*.fasta; do
    # check if output exists and skip the file
    if [ -f "$output_dir/$(basename "$i" .fasta)/$(basename "$i" .fasta).tsv" ];
    then
        echo "Output exists. Skipping $i"
    else
        bakta --db "$bakta_db_dir" \
        --output "$output_dir/$(basename "$i" .fasta)" --prefix "$(basename "$i" .fasta)" \
        --threads "$threads" --force \
        --genus "$genus" --species "$species" \
        --strain "$(basename "$i" .fasta)" "$i"
    fi
done
