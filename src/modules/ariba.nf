
process ARIBA_PREPARE {
    tag "Preparing ARIBA ref db"

    container 'sangerpathogens/ariba:release-v2.14.6 '

    output:
    path "out.argannot.prepareref", emit: argannot
 
    script :
    """
    ariba getref argannot out.argannot
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
