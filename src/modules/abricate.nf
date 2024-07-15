process ABRICATE {
    tag "Predicting genes for ${sample_id}"

    cpus 10
    maxForks 2
    errorStrategy 'finish'
    
    container 'nanozoo/abricate:1.0.1--8960147'
    
    input:
    tuple val(sample_id), path(fasta)


    output:
    path "*.txt"
 
    script :
    """
    abricate --db vfdb --quiet ${fasta} > ${sample_id}_VirulenceFactorDB.txt

    abricate --db resfinder --quiet ${fasta} > ${sample_id}_resfinder.txt

    abricate --db plasmidfinder --quiet ${fasta} > ${sample_id}_plasmidfinder.txt

    abricate --db card --quiet ${fasta} > ${sample_id}_card.txt

    abricate --db argannot --quiet ${fasta} > ${sample_id}_argannot.txt
    """
}
