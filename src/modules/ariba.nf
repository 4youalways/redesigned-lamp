
process ARIBA_PREPARE {
    tag "Preparing ARIBA ref db"

    container 'sangerpathogens/ariba:release-v2.14.6 '

    output:
    path "out.argannot.prepareref", emit: argannot
    path "get_mlst/ref_db", emit: mlst_db
    script :
    """
    ariba getref argannot out.argannot
    ariba pubmlstget "Klebsiella pneumoniae" get_mlst
    ariba prepareref -f out.argannot.fa -m out.argannot.tsv out.argannot.prepareref
    """
}

process ARIBA_RUN {
    tag "Predicting genotype for ${sample_id}"

    cpus 10
    maxForks 2
    errorStrategy 'finish'
    
    container 'sangerpathogens/ariba:release-v2.14.6 '
    
    input:
    path argannot
    tuple val(sample_id), path('reads')


    output:
    path "${sample_id}/report.tsv"
 
    script :
    """
    ariba run --threads $task.cpus ${argannot} ${reads[0]}  ${reads[1]}  ${sample_id}    
    """
}

process ARIBA_MLST {
    tag "Predicting genotype for ${sample_id}"

    cpus 10
    maxForks 2
    errorStrategy 'finish'
    
    container 'sangerpathogens/ariba:release-v2.14.6 '
    
    input:
    path mlst_db
    tuple val(sample_id), path('reads')


    output:
    path "${sample_id}/AMR_report.tsv"
 
    script :
    """
    ariba run --threads $task.cpus ${mlst_db} ${reads[0]}  ${reads[1]}  ${sample_id}    
    """
}
