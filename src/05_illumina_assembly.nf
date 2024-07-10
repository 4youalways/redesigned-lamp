nextflow.enable.dsl=2


include { FASTQC_ASSEMBLY as before_trim } from './modules/fastqc.nf'


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


workflow ILLUMINA_ASSEMBLER {
    before_trim(reads_ch)

}

/*
workflow {
    medaka_polish = MEDAKA_POLISH(polishing_ch)
    bwa_input = polishing_ch.join(medaka_polish)
    BWA_INDEX_MEM(bwa_input)
    POLYPOLISH(BWA_INDEX_MEM.out.join(medaka_polish))
    POLCA(polishing_ch.join(POLYPOLISH.out))

}
*/
