nextflow.enable.dsl=2

include { FILTLONG  } from './modules/filtlong.nf'
include { MEDAKA_POLISH } from './modules/medaka.nf'
include { BWA_INDEX_MEM } from './modules/bwa.nf'
include { POLYPOLISH } from './modules/polypolish.nf'
include { POLCA } from './modules/polca.nf'
include { PROKKA } from './modules/prokka.nf'
include { BAKTA } from './modules/bakta.nf'




workflow POLISH_TRYCYCLER {
    take:
    polishing_ch
    bakta_db
    genus
    species
    

    main:
    medaka_polish = MEDAKA_POLISH(polishing_ch)
    bwa_input = polishing_ch.join(medaka_polish)
    BWA_INDEX_MEM(bwa_input)
    POLYPOLISH(BWA_INDEX_MEM.out.join(medaka_polish))
    POLCA(polishing_ch.join(POLYPOLISH.out))
    PROKKA(POLCA.out)
    //BAKTA(SHOVILL.out.normal, bakta_db, genus, species) //process failing due to error with positional argument added by nextflow
    

}

