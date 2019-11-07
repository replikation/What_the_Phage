process metaphinder {
      publishDir "${params.output}/${name}/metaphinder", mode: 'copy', pattern: "${name}_*.list"
      label 'metaphinder'
    input:
      tuple val(name), file(fasta) 
    output:
      tuple val(name), file("${name}_*.list")
    script:
      """
      rnd=${Math.random()}
      mkdir ${name}
      MetaPhinder.py -i ${fasta} -o ${name} -d /MetaPhinder/database/ALL_140821_hr
      mv ${name}/output.txt ${name}_\${rnd//0.}.list
      """
}