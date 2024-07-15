process MLST {

    container 'staphb/mlst:2.23.0-2024-07-01'
    
    input:
    tuple val(sample_id), path(assembly)

    output:
    path("${sample_id}.txt")

    script:
    """
    mlst --scheme klebsiella --novel Novel_alleles --nopath  ${assembly} > ${sample_id}.txt
    """

}
