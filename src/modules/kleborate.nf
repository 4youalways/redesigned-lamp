process RENAME_SHOVIL_ASSEMBLY {
    tag "Predicting genes for ${sample_id}"

    
    input:
    tuple val(sample_id), path(fasta)


    output:
    path "${sample_id}.fasta"
 
    script :
    """
    cp ${fasta} ${sample_id}.fasta
    """
}


process KLEBORATE {
    tag "Predicting genes for ${sample_id}"

    cpus 10
    maxForks 2
    errorStrategy 'finish'
    
    container 'staphb/kleborate:2.4.1'
    
    input:
    path(fasta)


    output:
    path "kleborate_results.txt"
 
    script :
    """
    kleborate --all -o kleborate_results.txt -a ${fasta}
    """
}
