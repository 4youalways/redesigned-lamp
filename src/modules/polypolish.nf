process POLYPOLISH {
    tag "polishing sample ${sample_id} using polypolish"
    container 'staphb/polypolish:0.5.0'
    
    input:
    tuple val(sample_id), path(alignments), path(assembly)

    output:
    tuple val(sample_id), path("${sample_id}_polished.fasta")
 
    script :
    """
    polypolish_insert_filter.py --in1 ${alignments[0]} --in2 ${alignments[1]} --out1 filtered_1.sam --out2 filtered_2.sam
    polypolish ${assembly} filtered_1.sam filtered_2.sam > ${sample_id}_polished.fasta
    """

}
