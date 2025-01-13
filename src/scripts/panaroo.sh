#!/bin/bash

# This script runs panaroo on a directory of gff files. Ensure that the gff files are named as <sample_name>.gff and that the panaroo executable is in your PATH

# Date: 2025-01-13
#
# Copyright (c) 2025 Malawi Liverpool Wellcome Trust
#
# Author: Allan Zuza
#
#

usage() {
    echo "Usage: $0 -i <input_dir> -o <output_dir> -t <threads>"
    exit 1
}

while getopts "i:o:t:" opt; do
    case $opt in
        i) input_dir=$OPTARG ;;
        o) output_dir=$OPTARG ;;
        t) threads=$OPTARG ;;
        *) usage ;;
    esac
done

if [ -z "$input_dir" ] || [ -z "$output_dir" ] || [ -z "$threads" ]; then
    usage
fi

# Create output directory
if [ ! -d "$output_dir" ]; then
    mkdir -p "$output_dir"
fi

# Run bakta
panaroo -i ${input_dir}/*gff -o ${output_dir} --clean-mode strict -t $threads -a core
