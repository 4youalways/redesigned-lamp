process RENAME_SHOVIL_ASSEMBLY {
    tag "Predicting genes for ${sample_id}"
  
    input:
    tuple val(sample_id), path(fasta)

    output:
    tuple val(sample_id), path("${sample_id}.fasta")
 
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
    tuple val(sample_id), path(fasta)


    output:
    path "${sample_id}_kleborate.txt"
 
    script :
    """
    kleborate -p kpsc --trim_headers -o kleborate -a ${fasta}
    cp kleborate/klebsiella_pneumo_complex_output.txt ${sample_id}_kleborate.txt
    """
}
