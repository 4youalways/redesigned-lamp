
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
    
    script:
    """
    run_gubbins.py --date ${date} --threads $task.cpus --no-cleanup \
    --tree-builder raxml --first-tree-builder iqtree --bootstrap 1000 \
    --model GTRGAMMA --first-model GTRGAMMA \
    --prefix ST39 ${phylo}

    """
}

