nextflow.enable.dsl=2

// location of the reads
params.short_reads = '/Users/zuza/repos/redesigned-lamp/data/illumina/**_{1,2}.fastq.gz'

params.long_reads = '/Users/zuza/repos/redesigned-lamp/data/ont/**_0.fastq.gz'

// use an ncbi script file for getting project data
params.download_script = ''

// set output folders
params.outdir = '../results/'

include { GetReads } from './modules/01_download_reads.nf'


//include { TRIM_LONG; FASTQC; FASTP } from './modules/bacteria_pipeline.nf'
download_ch = channel.fromPath(params.download_script)


// read in a file and take each line as input for a process
download_ch = file(params.download_script)
    .readLines()


workflow {

GetReads(download_ch)

short_reads_ch = channel
            .fromFilePairs(params.short_reads)
//            .view()
long_reads_ch = channel
            .fromPath(params.long_reads)
            .view()
//
}
