process vibrant {
      publishDir "${params.output}/${name}/Vibrant", mode: 'copy', pattern: "vibrant_*.tsv"
      label 'vibrant'
    input:
      tuple val(name), file(fasta) 
      path(db)
    output:
      tuple val(name), file("vibrant_*.tsv")
    script:
      """
      rnd=${Math.random()}
      
      tar xzf ${db}

      VIBRANT_run.py -i ${fasta} \
      -k database/KEGG_profiles_prokaryotes.HMM \
      -p database/Pfam-A_v32.HMM \
      -v database/VOGDB94_phage.HMM \
      -e database/Pfam-A_plasmid_v32.HMM \
      -a database/Pfam-A_phage_v32.HMM \
      -c database/VIBRANT_categories.tsv \
      -n database/VIBRANT_names.tsv \
      -s database/VIBRANT_KEGG_pathways_summary.tsv \
      -m database/VIBRANT_machine_model.sav \
      -g database/VIBRANT_AMGs.tsv 

      mv VIBRANT_${name}/VIBRANT_results_${name}/VIBRANT_machine_${name}.tsv vibrant_\${rnd//0.}.tsv
      """
}

//virsorter_\${rnd//0.}.list          VIBRANT_run.py -i ${fasta} 

// slows pc down massively.... while tar proces 
// folder structure of vibrant needs to be untouched
// -t: increase the number of VIBRANT parallel runs (similar to threads). The integer entered here will have no impact on results but may impact runtime. To parallelize VIBRANT, the -t flag will indicate how many separate files to split the input file into; these will all be run in tandem. For example, an input file with 10 scaffolds that has invoked -t 5 will run VIBRANT 5 separate times simultaneously with each run consisting of 2 scaffolds each. Default = 1.