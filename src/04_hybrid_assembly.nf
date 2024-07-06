nextflow.enable.dsl=2

include { FILTLONG  } from './modules/filtlong.nf'
include { MEDAKA_POLISH } from './modules/medaka.nf'

// polish the trycycler assembly using long reads


// make seperate indexes of short reads
process BWA_INDEX_MEM {
    tag "BWA_MEM on $sample_id"
    publishDir "${params.alignments}", mode: 'copy'

    input:
    tuple val(sample_id), path('read'), path('assembly')
    
    output:
    tuple val(sample_id), path("*alignments_*.sam")

    script:
      """
    bwa index ${assembly}/consensus.fasta
    bwa mem -t 16 -a ${assembly}/consensus.fasta ${read[0]} > ${sample_id}_alignments_1.sam
    bwa mem -t 16 -a ${assembly}/consensus.fasta ${read[1]} > ${sample_id}_alignments_2.sam
      """
}



process POLYPOLISH {
    publishDir "${params.outdir}", mode: 'copy'

    input:
    tuple val(sample_id), path('alignments'), path('assembly')

    output:
    tuple val(sample_id), path("final_assembly/${sample_id}_polished.fasta")
 
    script :
    """
    mkdir final_assembly
    polypolish_insert_filter.py --in1 ${alignments[0]} --in2 ${alignments[1]} --out1 filtered_1.sam --out2 filtered_2.sam
    polypolish ${assembly}/consensus.fasta filtered_1.sam filtered_2.sam > final_assembly/${sample_id}_polished.fasta
    """

}

process POLCA {
    publishDir "${params.outdir}", mode: 'copy'

    input:
    tuple val(sample_id), path('read'), path('assembly')

    output:
    tuple val(sample_id), path("polca/${sample_id}.fasta")
 
    script :
    """
    mkdir polca
    polca.sh -a ${assembly} -r "${read[0]} ${read[1]}" -t 16 -m 1G
    mv *.PolcaCorrected.fa polca/${sample_id}.fasta
    """

}


process PROKKA {
    tag "PROKKA on $sample_id"
    publishDir "${params.outdir}", mode: 'copy'

    input:
    tuple val(sample_id), path('assembly') 

    output:
    path "prokka/$sample_id"
 
    script :
    """
    mkdir -p prokka/$sample_id
    prokka --outdir prokka/$sample_id --locustag STY --prefix $sample_id --usegenus --genus Salmonella --force --compliant $assembly
    """

}



workflow POLISH_TRYCYCLER {
    take:
    polishing_ch
//    polishing_data

    main:

    MEDAKA_POLISH(polishing_ch)

   

    /*
    // collect long reads
    reads_ch = channel.fromPath(params.reads, followLinks: true, checkIfExists: false)

    // make a tuple
    tuppled_fastq = reads_ch.map {it -> [it.simpleName.tokenize("_")[0], it]}

    // collect short reads
    short_reads_ch = channel.fromPath(params.short_reads, followLinks: true, checkIfExists: false)

    //make a tupple of the short reads
    tuppled_short_reads = short_reads_ch.map {it -> [it.simpleName.tokenize("_")[0], it]}.groupTuple()
    
    // collect the trycycler assemblies
    assembly_ch = channel.fromPath(params.assembly)
    tuppled_assemblies = assembly_ch.map {it -> [it.simpleName.tokenize("_")[0], it]}

    // collect long reads and draft for medaka
    medaka_input = tuppled_fastq.join(tuppled_assemblies).groupTuple()

    //polish the FLYE assembly using medaka. Medaka takes in the long reads as a polishing read set
    polished_draft = MEDAKA_POLISH(medaka_input)



    // collect input for bwa mem
    bwa_input = tuppled_short_reads.join(polished_draft)
    //bwa_input = tuppled_short_reads.join(tuppled_assemblies)

    // create alignment of the short reads
    alignment = BWA_INDEX_MEM(bwa_input)

    // collect input for polypolish
    polypolish_input = alignment.join(polished_draft)
    //polypolish_input = alignment.join(tuppled_assemblies)

    //polish long reads with short reads using polypolish
    polished_assembly = POLYPOLISH(polypolish_input)
    //polished_assembly = POLYPOLISH(polypolish_input)

    polca_input = tuppled_short_reads.join(polished_assembly)

    POLCA(polca_input)

    // use prokka to annotate the ASSEMBLIES
    //PROKKA(tuppled_assemblies)

    */
}
