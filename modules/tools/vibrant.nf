process vibrant {
      label 'vibrant'
      errorStrategy 'ignore'
    input:
      tuple val(name), file(fasta) 
      path(db)
    output:
      tuple val(name), file("vibrant_*.tsv")
      // output collection stream
      tuple val(name), file("vibrant_*.tsv"), file("VIBRANT_results_*.tar.gz")
    script:
      """
      
      tar xzf ${db}

      VIBRANT_run.py -i ${fasta} -t ${task.cpus} \
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

      # error control via touch
      cp VIBRANT_*/VIBRANT_results_*/VIBRANT_machine_*.tsv vibrant_\${PWD##*/}.tsv 2>/dev/null
      
      tar cf VIBRANT_results_\${PWD##*/}.tar.gz VIBRANT_*
      """
}

/*

slows pc down massively.... while tar proces 
folder structure of vibrant needs to be untouched
-t: increase the number of VIBRANT parallel runs (similar to threads). 
The integer entered here will have no impact on results but may impact runtime. 
To parallelize VIBRANT, the -t flag will indicate how many separate files to split the input file into; 
these will all be run in tandem. For example, an input file with 10 scaffolds that has invoked -t 5 will run 
VIBRANT 5 separate times simultaneously with each run consisting of 2 scaffolds each. Default = 1.

*/