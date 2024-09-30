
process GUBBINS{

    tag "Performing Gubbins alanlysis"
    container 'staphb/gubbins:3.3.5'
    
    cpus 64

    input:
    path phylo
    path date
    
    output:
    path 'ST39*'
    path 'phylo*'
    path 'manual.filtered_polymorphic_sites.fasta'; emit: filtered_polymorphic_sites
    
    script:
    """
    run_gubbins.py --threads 64 --prefix manual ${phylo}/core.full.aln  

    """
}

