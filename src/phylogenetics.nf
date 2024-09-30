nextflow.enable.dsl=2



include { SNIPPY } from './modules/variant_calling.nf'
include { SNIPPY_CORE  } from './modules/variant_calling.nf'
include { SNP_SITES } from './modules/variant_calling.nf'
include { IQTREE } from './modules/iqtree.nf'
include { GUBBINS } from './modules/gubbins.nf'


workflow  SNIPPY_WORKFLOW {
    take:
    ref
    reads
    dates

    main:
    SNIPPY(reads, ref) // variant calling step
    core_snps = SNIPPY_CORE(SNIPPY.out.collect(), ref) // generating fasta alignment
    GUBBINS(SNIPPY_CORE.out.full_alignment, dates)
    SNP_SITES(core_snps)   
    IQTREE(GUBBINS.out.filtered_polymorphic_sites, SNP_SITES.out.constant)
    

}
