nextflow.enable.dsl=2

include { FILTLONG  } from './modules/filtlong.nf'
include { MEDAKA_POLISH } from './modules/medaka.nf'
include { BWA_INDEX_MEM } from './modules/bwa.nf'
include { POLYPOLISH } from './modules/polypolish.nf'
include { POLCA } from './modules/polca.nf'
include { PROKKA } from './modules/prokka.nf'



/*
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
*/

workflow POLISH_TRYCYCLER {
    take:
    polishing_ch

    main:
    medaka_polish = MEDAKA_POLISH(polishing_ch)
    bwa_input = polishing_ch.join(medaka_polish)
    BWA_INDEX_MEM(bwa_input)
    POLYPOLISH(BWA_INDEX_MEM.out.join(medaka_polish))
    POLCA(polishing_ch.join(POLYPOLISH.out))
    PROKKA(POLCA.out)

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
