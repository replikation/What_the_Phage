include { input_suffix_check } from './process/input_validation/input_suffix_check'
include { seqkit } from './process/input_validation/seqkit'

workflow input_validation_wf {
    take:   fasta
    main:   seqkit(input_suffix_check(fasta)) 
    emit:   seqkit.out
}