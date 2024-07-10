nextflow.enable.dsl=2


include { FASTQC_ASSEMBLY as before_trim } from './modules/fastqc.nf'
include { SHOVILL } from './modules/shovill.nf'

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


workflow ILLUMINA_ASSEMBLER {
    before_trim(short_read_ch)
    SHOVILL(short_read_ch)
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
