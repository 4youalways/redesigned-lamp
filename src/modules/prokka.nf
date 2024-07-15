process PROKKA {
    tag "PROKKA on $sample_id"
    container 'quay.io/biocontainers/prokka:1.14.6--pl5321hdfd78af_4'

    maxForks 2
    input:
    tuple val(sample_id), path(assembly) 

    output:
    path "$sample_id"
    path("${sample_id}.gff"), emit: gff
 
    script :
    """
    mkdir -p $sample_id
    prokka --outdir ${sample_id} --locustag KLP --prefix ${sample_id} --usegenus --genus Klebsiella --addgenes --force --compliant $assembly
    cp ${sample_id}/${sample_id}.gff ${sample_id}.gff
    """

}
