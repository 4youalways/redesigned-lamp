nextflow.enable.dsl=2

/*
==========================================================
Trycycler assembly workflow
==========================================================
*/



include { INITIAL_ASSEMBLY } from "./src/01_hybrid_assembly.nf"





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

assemblies = channel.fromPath(params.assembly_sample_sheet, checkIfExists:true)
    .splitCsv(header: true)
    .map {
        row ->
        meta = row.sample_name
        [meta, [
//            file(row.ont_read),
            file(row.illumina_read1),
            file(row.illumina_read2),
            file(row.trycycler_assembly)
        ]]
    }



workflow ASSEMBLY {
    INITIAL_ASSEMBLY{reads_ch}
}

workflow {
/*
    take:
    assemblies
    reads_ch
*/
    main:
    INITIAL_ASSEMBLY{reads_ch}
    assemblies
    .join(INITIAL_ASSEMBLY.out.filtlong)
    .view()
}
