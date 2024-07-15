
process QUAST {
    
    conda 'quast'

    input:
    path(fasta)
    path(reference)
    val(sample_id)

    output:
    path("${sample_id}")

    script:
    """
    quast.py ${fasta} -r  ${reference} -o ${sample_id}
    """
}

process QUAST_MULTIQC {

    conda 'multiqc'
    publishDir "${params.result}/Qusts_multiqc", mode: 'copy'
    input:
    path(qc_files)

    output:
    path("*multiqc*")

    script:
    """
    multiqc ${qc_files}
    """
}
