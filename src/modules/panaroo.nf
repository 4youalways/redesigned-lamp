
process PANAROO {

    cpus 60
    errorStrategy 'finish'
    
    container 'staphb/panaroo:1.5.0'
    
    input:
    path gff


    output:
    path "panaroo"
    path "panaroo/core_gene_alignment.aln", emit: core_gene_alignment
 
    script :
    """
    mkdir panaroo
    panaroo -i ${gff} -o panaroo --clean-mode strict -t $task.cpus -a core
    """
}
