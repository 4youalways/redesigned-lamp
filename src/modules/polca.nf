process POLCA {
    tag "final polish on ${sample_id}"

    container 'staphb/masurca:4.1.0'

    input:
    tuple val(sample_id), path(read), path(assembly)

    output:
    tuple val(sample_id), path("${sample_id}_PolcaCorrected.fasta")
 
    script :
    """
    polca.sh -a ${assembly} -r "${read[1]} ${read[2]}" -t 16 -m 1G
    mv *.PolcaCorrected.fa ${sample_id}_PolcaCorrected.fasta
    """

}
