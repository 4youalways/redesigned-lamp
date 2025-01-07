
process GUBBINS {

    tag "Performing Gubbins alanlysis"
    //container 'staphb/gubbins:3.3.5' // the gubbins docker container brings a bus error. we will use conda instead to make life easy
    conda 'bioconda::gubbins'
    
    cpus 64

    input:
    path phylo
    path date
    
    output:
    path 'ST39*'
    //path 'phylo*'
    path 'ST39.filtered_polymorphic_sites.fasta', emit: filtered_polymorphic_sites
    
    script:
    """
    run_gubbins.py --threads 64 --prefix ST39 ${phylo}  

    """
}

