process PROKKA {
    tag "PROKKA on $sample_id"
    publishDir "${params.outdir}", mode: 'copy'

    input:
    tuple val(sample_id), path('assembly') 

    output:
    path "$sample_id"
 
    script :
    """
    mkdir -p $sample_id
    prokka --outdir $sample_id --locustag KLP --prefix $sample_id --usegenus --genus Klebsiella --force --compliant $assembly
    """

}
