
nextflow.enable.dsl=2

/*
==========================================================
Trycycler assembly workflow
==========================================================
*/



include { INITIAL_ASSEMBLY } from "./src/01_hybrid_assembly.nf"
include { POLISH_TRYCYCLER } from "./src/04_hybrid_assembly.nf"
include { ILLUMINA_ASSEMBLER } from "./src/05_illumina_assembly.nf"
include { ARIBA } from "./src/amrAndGenotyping.nf"
include { ABRICATE_WF } from './src/amrAndGenotyping.nf'
include { MLST_CHECK } from './src/amrAndGenotyping.nf'
include { SNIPPY_WORKFLOW } from './src/phylogenetics.nf'



//define input channels
reads_ch = channel.fromPath(params.assembly_sample_sheet, checkIfExists:true)
    .splitCsv(header: true)
    .map {
        row ->
        meta = row.sample_name
        [meta, [
            file(row.ont_read),
            file(row.illumina_read1),
            file(row.illumina_read2)
        ]]
    }

 
polishing_ch = channel.fromPath(params.assembly_sample_sheet, checkIfExists:true)
    .splitCsv(header: true)
    .map {
        row ->
        meta = row.sample_name
        [meta, [
            file(row.polished_ont),
            file(row.illumina_read1),
            file(row.illumina_read2),
            file(row.trycycler_assembly)
        ]]
    }

short_read_ch = channel.fromPath(params.sample_sheet, checkIfExists:true)
    .splitCsv(header: true)
    .map {
        row ->
        meta = row.sample_name
        [meta, [
            file(row.read_1),
            file(row.read_2)
        ]]
    }

//using AP006725.1 Klebsiella pneumoniae subsp. pneumoniae NTUH-K2044 DNA, complete genome refrence genome
reference = channel.fromPath(params.ref)

// using BKREGE as a ref seq for phylogenetic analysis
st39_ref = channel.fromPath(params.st39_ref)

// channel for bakta database. the download was done seperatesly
// but this can later be encorporated into the workflwow
bakta_db_ch = channel.fromPath(params.bakta_database)
genus_ch = channel.fromPath(params.genus)
species_ch = channel.fromPath(params.species)
//gram_stain_ch = channel.fromPath(params.gram_stain) // requires an extra dependancey


workflow ASSEMBLY {
    INITIAL_ASSEMBLY(reads_ch)
}

workflow  POLISH {
    POLISH_TRYCYCLER(polishing_ch,  bakta_db_ch, genus_ch, species_ch)
}

workflow  SHOVILL_WORKFLOW {
    ILLUMINA_ASSEMBLER(short_read_ch, reference, bakta_db_ch, genus_ch, species_ch)
    ABRICATE_WF(ILLUMINA_ASSEMBLER.out.assemblies)
    MLST_CHECK(ILLUMINA_ASSEMBLER.out.assemblies)
}

workflow TREES {
    SNIPPY_WORKFLOW(st39_ref, short_read_ch)
}

workflow {
    ARIBA(short_read_ch)
}
