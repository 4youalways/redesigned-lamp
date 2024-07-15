nextflow.enable.dsl=2


include { FASTQC_ASSEMBLY as before_trim } from './modules/fastqc.nf'
include { SHOVILL } from './modules/shovill.nf'
include { PROKKA } from './modules/prokka.nf'
include { PANAROO } from './modules/panaroo.nf'
include { QUAST } from './modules/quast.nf'
include { QUAST_MULTIQC } from './modules/quast.nf'

workflow ILLUMINA_ASSEMBLER {
    take:
    short_read_ch
    reference

    main:
    before_trim(short_read_ch)
    SHOVILL(short_read_ch)
    PROKKA(SHOVILL.out)
    PANAROO(PROKKA.out.gff.collect())
    QUAST(SHOVILL.out, reference)
    QUAST_MULTIQC(QUAST.out.collect())

    emit:
    assemblies = SHOVILL.out
    gff = PROKKA.out.gff
}

