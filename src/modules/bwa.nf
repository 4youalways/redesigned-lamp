// make seperate indexes of short reads
process BWA_INDEX_MEM {
    tag "BWA_MEM on $sample_id"

    input:
    tuple val(sample_id), path(read), path(assembly)//, path(read)//, path('assembly')
    
    output:
    tuple val(sample_id), path("*alignments_*.sam")

    script:
      """
    bwa index ${assembly}
    bwa mem -t 16 -a ${assembly} ${read[1]} > ${sample_id}_alignments_1.sam
    bwa mem -t 16 -a ${assembly} ${read[2]} > ${sample_id}_alignments_2.sam
      """
}
