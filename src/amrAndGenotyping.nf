#!/usr/bin/env nextflow
nextflow.enable.dsl=2

include { ARIBA_PREPARE } from './modules/ariba.nf'
include { ARIBA_RUN } from './modules/ariba.nf'
include { ABRICATE } from './modules/abricate.nf'
include { MLST } from './modules/mlst.nf'

workflow ARIBA {
    take:
    reads

    main:

    ARIBA_PREPARE()

    ARIBA_RUN(ARIBA_PREPARE.out.argannot, reads)

}


workflow ABRICATE_WF {
    take:
    assembly

    main:

    ABRICATE(assembly)

}

workflow MLST_CHECK {
    take:
    assembly

    main:

    MLST(assembly)

}

