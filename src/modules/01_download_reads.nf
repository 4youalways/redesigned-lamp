nextflow.enable.dsl=2

process GetReads {
    maxForks 1 // specifies the total number of parallel runs
    publishDir "${params.outdir}", mode: 'copy'
    
    input:
    each urls

    output:
    path '*.fastq.gz'

    script:
    """

    ${urls}

    """
}
