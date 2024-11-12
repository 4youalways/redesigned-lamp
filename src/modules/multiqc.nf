process MULTIQC {

    tag "$sample_id"
    container 'quay.io/biocontainers/multiqc.10.1--py_0'

    input:
    path(reports)
    
    output:
    path "multiqc_report.html", emit: multiqc_report
    

    script:
    """
    multiqc .
    """
}
