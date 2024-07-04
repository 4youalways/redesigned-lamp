
process TRYCYCLER_SUBSAMPLE {
    tag "TRYCYCLER_SUBSAMPLE on $sample_id"
    container 'staphb/trycycler:0.5.4'

    input: 
    tuple val(sample_id), path('reads')

    output:
    tuple val(sample_id),  path("${sample_id}")

    script:
    "trycycler subsample --reads ${reads} --out_dir ${sample_id} --count 16"
}


process FLYE {

    tag "INITIAL FLYE ASSEMBLY on $sample_id"
    container 'nanozoo/flye:2.9.1--bba1957'

    input: 
    tuple val(sample_id), path('reads')

    output:
    tuple val(sample_id),  path("${sample_id}/*.fasta")
    path "${sample_id}/*.gfa"

    script:
    """
    mkdir -p ${sample_id}
    for i in 02 01 06 10 13 14; do
        mkdir -p flye_temp/\${i}
        flye --nano-hq ${reads}/sample_\${i}.fastq --threads 16 --out-dir flye_temp/\${i} -i 3
        cp flye_temp/\${i}/assembly.fasta ${sample_id}/assembly_\${i}.fasta
        cp flye_temp/\${i}/assembly_graph.gfa ${sample_id}/assembly_\${i}.gfa
    done   

    """
}

process RAVEN {

    tag "INITIAL RAVEN on $sample_id"
    container 'nanozoo/raven:1.5.0--9806f08'

    input: 
    tuple val(sample_id), path('reads')

    output:
    tuple val(sample_id),  path("${sample_id}/*.fasta")
    path "${sample_id}/*.gfa"

    script:
    """
    mkdir -p ${sample_id}
    for i in 03 05 07 11 15; do
        raven --threads 8 --disable-checkpoints --graphical-fragment-assembly ${sample_id}/assembly_\${i}.gfa ${reads}/sample_\${i}.fastq > ${sample_id}/assembly_\${i}.fasta
    done   

    """
}

process MINIPOLISH {

    tag "INITIAL MINIPOLISH on $sample_id"
    container 'staphb/minipolish:0.1.3'

    input: 
    tuple val(sample_id), path('reads')

    output:
    tuple val(sample_id),  path("${sample_id}/")
    
    script:
    """
    mkdir -p ${sample_id}
    for i in 04 08 09 12 16; do
        minimap2 -t 8 -x ava-ont ${reads}/sample_\${i}.fastq ${reads}/sample_\${i}.fastq > overlaps.paf
        miniasm -f ${reads}/sample_\${i}.fastq overlaps.paf > assembly.gfa
        minipolish -t 8 ${reads}/sample_\${i}.fastq assembly.gfa > ${sample_id}/assembly_\${i}.gfa
    done   

    """
}

process ANY2FASTA {

    tag "ANY2FASTA on $sample_id"
    container 'staphb/any2fasta:0.4.2'
   

    input: 
    tuple val(sample_id), path('gfa')

    output:
    tuple val(sample_id),  path("assemblies/${sample_id}/*.fasta")
    
    script:
    """
    mkdir -p assemblies/${sample_id}
    for i in 04 08 09 12 16; do
        any2fasta ${gfa}/assembly_\${i}.gfa > assemblies/${sample_id}/assembly_\${i}.fasta  
    done 

    """
}

process TRYCYCLER_CLUSTER {

    tag "TRYCYCLER_CLUSTER on $sample_id"
    container 'staphb/trycycler:0.5.4'
    
    input: 
    tuple val(sample_id), path('raven'), path('flye'), path('minipolish'), path('reads')
   
    output:
    tuple val(sample_id),  path("${sample_id}")

    script:
    """
    trycycler cluster --assemblies ${raven} ${flye} ${minipolish} --reads ${reads} --out_dir ${sample_id} --threads 32

    """
}
