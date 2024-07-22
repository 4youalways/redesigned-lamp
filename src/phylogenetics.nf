nextflow.enable.dsl=2



include { SNIPPY } from './modules/variant_calling.nf'
include { SNIPPY_CORE  } from './modules/variant_calling.nf'
include { SNP_SITES } from './modules/variant_calling.nf'
include { IQTREE } from './modules/iqtree.nf'



workflow  SNIPPY_WORKFLOW {
    take:
    ref
    reads

    main:
    SNIPPY(reads, ref) // variant calling step
    core_snps = SNIPPY_CORE(SNIPPY.out.collect(), ref) // generating fasta alignment
    SNP_SITES(core_snps)   
    IQTREE(SNP_SITES.out.phylo, SNP_SITES.out.constant)

}
