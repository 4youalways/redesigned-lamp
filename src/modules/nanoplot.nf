process NANOPLOT {
    tag "NANOPLOT on $sample_id"
    container 'nanozoo/nanoplot:1.38.1--e303519'
    input:
    tuple val(sample_id), path(reads) 

    output:
    path "nanoplot/$sample_id"
 
    script :
    
    """
    mkdir -p ${sample_id}
    NanoPlot -t 1 --fastq ${reads} --maxlength 40000 --plots dot kde -o ${sample_id} -p $sample_id
    """   
}
