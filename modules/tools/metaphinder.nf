process metaphinder {
      label 'metaphinder'
      errorStrategy 'ignore'
      def random = (Math.random() + Math.random()).toString().md5().toString()
    input:
      tuple val(name), file(fasta) 
    output:
      tuple val(name), file("${name}_${random}.list")
      // output collection stream
      tuple val(name), file("${name}_${random}.list"), file("${name}_${random}_blast.out")
    script:
      """
      mkdir ${name}
      MetaPhinder.py -i ${fasta} -o ${name} -d /MetaPhinder/database/ALL_140821_hr
      mv ${name}/output.txt ${name}_${random}.list
      mv ${name}/blast.out ${name}_${random}_blast.out
      """
}


process metaphinder_own_DB {
      label 'metaphinder'
      errorStrategy 'ignore'
      def random = (Math.random() + Math.random()).toString().md5().toString()
    input:
      tuple val(name), file(fasta)
      file(database)
    output:
      tuple val(name), file("${name}_${random}.list")
      // output collection stream
      tuple val(name), file("${name}_${random}.list"), file("${name}_${random}_blast.out")
    script:
      """
      rnd=${Math.random()}
      mkdir ${name}
      MetaPhinder.py -i ${fasta} -o ${name} -d phage_db
      mv ${name}/output.txt ${name}_${random}.list
      mv ${name}/blast.out ${name}_${random}_blast.out
      """
}