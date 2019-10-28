process metaphinder {
      publishDir "${params.output}/${name}/metaphinder", mode: 'copy', pattern: "${name}.txt"
      label 'metaphinder'
    input:
      tuple val(name), file(fasta) 
    output:
      tuple val(name), file("${name}.txt")
    script:
      """
      mkdir ${name}
      MetaPhinder.py -i ${fasta} -o ${name} -d /MetaPhinder/database/ALL_140821_hr
      mv ${name}/output.txt ${name}.txt
      """
}