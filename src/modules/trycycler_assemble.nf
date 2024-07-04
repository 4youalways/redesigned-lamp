
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


/*
process ASSEMBLIES {

    tag "INITIAL CANU ASSEMBLY on $sample_id"
    cpus 8
    
    input: 
    tuple val(sample_id), path('reads')

    output:
    tuple val(sample_id),  path("assemblies/${sample_id}/*.fasta")
    path "assemblies/${sample_id}/*.gfa"

    script:
    """ 
    mkdir -p assemblies/${sample_id}
    for i in 01; do
        
        canu -correct -p canu -d ${sample_id}.\${i}/canu_temp genomeSize=4.5m useGrid=false maxMemory=10g maxThreads=32 -nanopore-raw ${reads}/sample_\${i}.fastq
        canu -trim -p canu -d ${sample_id}.\${i}/canu_temp genomeSize=4.5m -nanopore-corrected ${sample_id}.\${i}/canu_temp/canu.correctedReads.fasta.gz
        canu -p canu -d ${sample_id}.\${i}/canu_temp genomeSize=4.5m -nanopore-corrected ${sample_id}.\${i}/canu_temp/canu.correctedReads.fasta.gz
        cp ${sample_id}.\${i}/canu_temp/canu.contigs.fasta assemblies/${sample_id}/assembly_\${i}.fasta
    done

    """
}

process CANU {

    tag "INITIAL CANU ASSEMBLY on $sample_id"
    publishDir "${params.output}", mode: 'copy'

    input: 
    tuple val(sample_id), path('reads')

    output:
    //tuple val(sample_id),  path("assemblies/${sample_id}/*.fasta")
    path "assemblies/${sample_id}/*.fasta"
    script:
    """ 
    mkdir -p assemblies/${sample_id}
    for i in 01 05 09 13; do
        
        canu -p canu -d ${sample_id}.\${i}/canu_temp -fast genomeSize=4.5m useGrid=false minThreads=64 maxThreads=100 -nanopore-raw ${reads}/sample_\${i}.fastq
        /home/azuza/miniconda3/bin/python3 /home/azuza/styphi/workflows/nextflow/trycycler/canu_trim.py ${sample_id}.\${i}/canu_temp/canu.contigs.fasta > assemblies/${sample_id}/assembly_\${i}.fasta
    done

    """
}

*/
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
        flye --nano-hq ${reads}/sample_\${i}.fastq --threads 16 --out-dir flye_temp/\${i} -i 3 -g 4.5m
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
    publishDir "${params.output}", mode: 'copy'

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
    publishDir "${params.output}", mode: 'copy'

    input: 
    tuple val(sample_id), path('raven'), path('flye'), path('minipolish'), path('reads')
   
    output:
    tuple val(sample_id),  path("trycycler/${sample_id}")

    script:
    """
    trycycler cluster --assemblies ${raven} ${flye} ${minipolish} --reads ${reads} --out_dir trycycler/${sample_id} --threads 32

    """
}


workflow {
    // collect long reads
    reads_ch = channel.fromPath(params.reads, followLinks: true, checkIfExists: false)
    
    // make a tuple
    tuppled_fastq = reads_ch.map {it -> [it.simpleName.tokenize("_")[0], it]}.groupTuple()

    // make subsamples
    subsamples = TRYCYCLER_SUBSAMPLE(tuppled_fastq)
    

    //CANU(subsamples)

    flye = ASSEMBLY_FLYE(subsamples)


    raven = RAVEN(subsamples)


    minipolish = MINIPOLISH(subsamples)


    ANY2FASTA(MINIPOLISH.out)
    
    //cluster_input = ANY2FASTA.out.mix(RAVEN.out[0]).mix(ASSEMBLY_FLYE.out[0]).collect().view()
    //cluster_input = RAVEN.out[0].mix(ASSEMBLY_FLYE.out[0]).collect().groupTuple().view()
    //RAVEN.out[0].flatten().join(ASSEMBLY_FLYE.out[0]).view()
    cluster_input = RAVEN.out[0].join(ASSEMBLY_FLYE.out[0]).join(ANY2FASTA.out).join(tuppled_fastq)
 
    TRYCYCLER_CLUSTER( cluster_input )
}
