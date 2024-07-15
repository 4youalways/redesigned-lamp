
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

workflow ASSEMBLY {
    INITIAL_ASSEMBLY(reads_ch)
}

workflow  POLISH {
    POLISH_TRYCYCLER(polishing_ch)
}

workflow  SHOVILL_WORKFLOW {
    ILLUMINA_ASSEMBLER(short_read_ch)
    ABRICATE_WF(ILLUMINA_ASSEMBLER.out.assemblies)
    MLST_CHECK(ILLUMINA_ASSEMBLER.out.assemblies)
}

workflow {
    ARIBA(short_read_ch)
}
