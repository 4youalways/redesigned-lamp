
process IQTREE {

    tag "$sample_id"
    container 'staphb/iqtree2:2.2.2.7'
    
    input:
    path phylo
    path constant
    
    output:
    path '*'
    
    script:
    """
    #!/bin/bash
    iqtree2 -nt AUTO -fconst \$(cat ${constant}) -s ${phylo} -m GTR+G -bb 1000 --verbose -T AUTO 

    """
}

process CORE_GENE_TREE {

    tag "Generating a core gene phylogenetic tree"
    container 'staphb/iqtree2:2.2.2.7'
    
    input:
    path phylo

    
    output:
    path 'core_tree*'
    
    script:
    """
    #!/bin/bash
    iqtree2 -s ${phylo} -pre core_tree -nt AUTO -fast -m GTR -T AUTO

    """
}
