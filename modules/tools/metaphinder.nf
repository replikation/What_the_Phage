process metaphinder {
      label 'metaphinder'
      errorStrategy 'ignore'
    input:
      tuple val(name), file(fasta) 
    output:
      tuple val(name), file("${name}_*.list")
      // output collection stream
      tuple val(name), file("${name}_*.list"), file("${name}_*_blast.out")
    script:
      """
      rnd=${Math.random()}
      mkdir ${name}
      MetaPhinder.py -i ${fasta} -o ${name} -d /MetaPhinder/database/ALL_140821_hr
      mv ${name}/output.txt ${name}_\${rnd//0.}.list
      mv ${name}/blast.out ${name}_\${rnd//0.}_blast.out
      """
}


process metaphinder_own_DB {
      label 'metaphinder'
      errorStrategy 'ignore'
    input:
      tuple val(name), file(fasta)
      file(database)
    output:
      tuple val(name), file("${name}_*.list")
      // output collection stream
      tuple val(name), file("${name}_*.list"), file("${name}_*_blast.out")
    script:
      """
      rnd=${Math.random()}
      mkdir ${name}
      MetaPhinder.py -i ${fasta} -o ${name} -d phage_db
      mv ${name}/output.txt ${name}_\${rnd//0.}.list
      mv ${name}/blast.out ${name}_\${rnd//0.}_blast.out
      """
}