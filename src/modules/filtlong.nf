process FILTLONG {

    tag "$sample_id"
    container 'nanozoo/filtlong:0.2.0--0c4cbe3'
    
    input:
    tuple val(sample_id), path(reads)
    
    output:
    tuple val(sample_id), path("${sample_id}.fastq.gz")
    

    script:
    """
    filtlong --min_length 1000 --keep_percent 90 ${reads[0]} | gzip > ${sample_id}.fastq.gz
    """
}
