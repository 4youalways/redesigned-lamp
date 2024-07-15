
process PANAROO {

    cpus 20
    maxForks 2
    errorStrategy 'finish'
    
    container 'staphb/panaroo:1.5.0'
    
    input:
    path gff


    output:
    path "panaroo"
 
    script :
    """
    mkdir panaroo
    panaroo -i ${gff} -o panaroo --clean-mode strict -t $task.cpus
    """
}
