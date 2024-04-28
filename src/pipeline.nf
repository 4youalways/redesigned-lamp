nextflow.enable.dsl=2

// location of the reads
params.short_reads = '/Users/zuza/repos/redesigned-lamp/data/illumina/**_{1,2}.fastq.gz'

params.long_reads = '/Users/zuza/repos/redesigned-lamp/data/ont/**_0.fastq.gz'


// set output folders
params.outdir = '../results/'


//include { TRIM_LONG; FASTQC; FASTP } from './modules/bacteria_pipeline.nf'



workflow {


short_reads_ch = channel
            .fromFilePairs(params.short_reads)
            .view()
long_reads_ch = channel
            .fromPath(params.long_reads)
            .view()

}
