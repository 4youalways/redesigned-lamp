nextflow.enable.dsl=2


include { FASTQC_ASSEMBLY as before_trim } from './modules/fastqc.nf' 
include { FILTLONG  } from './modules/filtlong.nf'
include { NANOPLOT  } from './modules/nanoplot.nf'
include { TRYCYCLER_SUBSAMPLE  } from './modules/trycycler_assemble.nf'
include { FLYE  } from './modules/trycycler_assemble.nf'
include { RAVEN  } from './modules/trycycler_assemble.nf'
include { MINIPOLISH  } from './modules/trycycler_assemble.nf'
include { ANY2FASTA  } from './modules/trycycler_assemble.nf'
include { TRYCYCLER_CLUSTER  } from './modules/trycycler_assemble.nf'


workflow  {

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

    before_trim(reads_ch)
    filtered_long_reads = FILTLONG(reads_ch)
    NANOPLOT(filtered_long_reads)
    TRYCYCLER_SUBSAMPLE(FILTLONG.out)
  

    // assemble the 16 read clusters
    FLYE(TRYCYCLER_SUBSAMPLE.out)
    RAVEN(TRYCYCLER_SUBSAMPLE.out)
    MINIPOLISH(TRYCYCLER_SUBSAMPLE.out)

    // convert the minipolish assembly to a fasta file
    ANY2FASTA(MINIPOLISH.out)


    RAVEN.out[0]
    .join(FLYE.out[0])
    .join(ANY2FASTA.out)
    .join(filtered_long_reads)


    //TRYCYCLER_CLUSTER(initial_assemblies)
 
}
