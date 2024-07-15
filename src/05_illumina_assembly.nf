nextflow.enable.dsl=2


include { FASTQC_ASSEMBLY as before_trim } from './modules/fastqc.nf'
include { SHOVILL } from './modules/shovill.nf'
include { PROKKA } from './modules/prokka.nf'
include { PANAROO } from './modules/panaroo.nf'

workflow ILLUMINA_ASSEMBLER {
    take:
    short_read_ch

    main:
    before_trim(short_read_ch)
    SHOVILL(short_read_ch)
    PROKKA(SHOVILL.out)
    //PROKKA.out.gff
    //.collect()
    //.view()
    PANAROO(PROKKA.out.gff.collect())

    emit:
    assemblies = SHOVILL.out
    gff = PROKKA.out.gff
}

