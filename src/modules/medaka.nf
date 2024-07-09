
process MEDAKA_POLISH {
    tag "MEDAKA_POLISH on $sample_id"

    container 'nanozoo/medaka:1.11.3--ce388c3'

    input:
    tuple val(sample_id), path(files)


    output:
    tuple val(sample_id), path("$sample_id/consensus.fasta")
 
    script :
    """
    mkdir -p $sample_id
    medaka_consensus -i ${files[0]} -d ${files[3]} -o $sample_id -m r941_min_sup_g507
    """
}
