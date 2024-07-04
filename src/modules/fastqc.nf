
process FASTQC {

    tag "$sample_id"
    container 'staphb/fastqc:0.12.1'
    maxForks 1
    cpus 1

    input:
    tuple val(sample_id), path(reads)
    
    output:
    tuple val(sample_id), path("*.html"), emit: html
    tuple val(sample_id), path("*.zip"), emit: zip
    

    script:
    """
    #!/bin/bash
    fastqc --threads $task.cpus -o . ${reads}
    """
}

process FASTQC_ASSEMBLY {

    tag "$sample_id"
    container 'staphb/fastqc:0.12.1'
    maxForks 1
    cpus 1
    
    input:
    tuple val(sample_id), path(reads)
    
    output:
    tuple val(sample_id), path("*.html"), emit: html
    tuple val(sample_id), path("*.zip"), emit: zip
    

    script:
    """
    #!/bin/bash
    fastqc --threads $task.cpus -o . ${reads[1]} ${reads[2]}
    """
}
