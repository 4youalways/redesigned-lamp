# redesigned-lamp
A repository to use in analysis of ST39 Klebsiella pneumoniae isolates

download reads from ENA using a nextflow script which relies on the script from ena

```
nextflow run ../src/pipeline.nf --download_script ../src/scripts/ena-file-download-read_run-PRJEB42462-fastq_ftp-20240428-0705.sh  --outdir ../data/illumina -with-report -resume && cp report* ../reports/.
```
