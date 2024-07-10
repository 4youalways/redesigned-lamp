
process SHOVILL {
    tag "SHOVILL on $sample_id"
    
    container 'staphb/shovill:1.1.0-2022Dec'
    maxForks 3

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("$sample_id")
 
    script :
    """
    shovill --outdir ${sample_id} --R1 ${reads[0]} --R2 ${reads[1]} \
    --trim --force --cpus $task.cpus
    """
}
