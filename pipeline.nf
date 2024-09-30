nextflow.enable.dsl=2


include { FASTQC as before_trim } from '../modules/fastqc.nf' 
include { FASTQC as after_trim }  from '../modules/fastqc.nf'
include { TRIMMOMATIC } from '../modules/trimming_and_filtering.nf'


workflow  {
    reads_ch = channel.fromPath(params.sample_sheet, checkIfExists:true)
    .splitCsv(header: true)
    .map {
        row ->
        meta = row.sample_name
        [meta, [
            file(row.read_1),
            file(row.read_2)
        ]]
    }

/*
    ref_ch = channel.fromPath(params.ref, checkIfExists:true)
    before_trim(reads_ch)
    trimmed = TRIMMOMATIC(reads_ch) // trimming and filtering
    after_trim(trimmed)
*/
}
