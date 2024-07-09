process FASTP {
    publishDir "${params.outdir}", mode: 'copy'

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("fastp/${sample_id}_FP_1.fastq.gz"), path("fastp/${sample_id}_FP_2.fastq.gz")
    
 
    script :
    """
    mkdir fastp
    fastp --in1 ${reads[0]} --in2 ${reads[1]}  --out1 fastp/${sample_id}_FP_1.fastq.gz --out2 fastp/${sample_id}_FP_2.fastq.gz --cut_front --cut_tail --trim_poly_x --cut_mean_quality 30 --qualified_quality_phred 30 --unqualified_percent_limit 10 --length_required 50
    """
}
