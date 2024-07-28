
process QUAST {
    
    container 'quay.io/biocontainers/quast:5.0.2--py37pl526hb5aa323_2'

    input:
    path(fasta)
    each path(reference)


    output:
    path("quast")

    script:
    """
    quast.py ${fasta} -r  ${reference} -o quast
    """
}

process QUAST_MULTIQC {
    container 'quay.io/biocontainers/multiqc:1.21--pyhdfd78af_0'
    
    input:
    path(qc_files)

    output:
    path("*multiqc*")

    script:
    """
    multiqc ${qc_files}
    """
}
