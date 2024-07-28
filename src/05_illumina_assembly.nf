nextflow.enable.dsl=2


include { FASTQC_ASSEMBLY as before_trim } from './modules/fastqc.nf'
include { SHOVILL } from './modules/shovill.nf'
include { PROKKA } from './modules/prokka.nf'
include { BAKTA } from './modules/bakta.nf'
include { PANAROO } from './modules/panaroo.nf'
include { QUAST } from './modules/quast.nf'
include { QUAST_MULTIQC } from './modules/quast.nf'
include { CORE_GENE_TREE } from './modules/iqtree.nf'

workflow ILLUMINA_ASSEMBLER {
    take:
    short_read_ch
    reference
    bakta_db
    genus
    species

    main:
    before_trim(short_read_ch)
    SHOVILL(short_read_ch)
    PROKKA(SHOVILL.out.normal)
    //BAKTA(SHOVILL.out.normal, bakta_db, genus, species) //process failing due to erro with nxf_trace positional urgument
    PANAROO(PROKKA.out.gff.collect())
    //QUAST(SHOVILL.out.assembly.collect(), reference) the prosess functions but it will need to modify the assembly process to implement in the current workflow. just rename the oontigs!
    CORE_GENE_TREE(PANAROO.out.core_gene_alignment)

    emit:
    assemblies = SHOVILL.out.normal
    gff = PROKKA.out.gff
}

