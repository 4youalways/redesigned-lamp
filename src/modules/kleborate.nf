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
    
    container 'staphb/kleborate:3.1.2'
    //conda './env/kleborate.yaml' //conda environment for kleborate has an error accessing the libgsl.so.25
    
    input:
    path(fasta)


    output:
    path "kleborate_results.txt"
 
    script :
    """
    kleborate -p kpsc --trim_headers -o kleboratels -a ${fasta}
    """
}
