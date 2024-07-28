process BAKTA {
    tag "BAKTA on $sample_id"
    container 'oschwengers/bakta:v1.9.4'

    maxForks 2
    cpus 8

    input:
    tuple val(sample_id), path(assembly) 
    each path(db)
    each path(genus)
    each path(species)

    output:
    path "$sample_id"
    path("${sample_id}.gff"), emit: gff
 
    script :
    """
    mkdir -p ${sample_id}
    bakta --db ${db} --output ${sample_id} --prefix ${sample_id} \
    --threads $task.cpus \
    --force --genus ${genus} --species ${species} \
    --strain ${sample_id} ${assembly}
    cp ${sample_id}/${sample_id}.gff3 ${sample_id}.gff
    """

}
