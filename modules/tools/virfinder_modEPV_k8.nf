process virfinder_modEPV_k8 {
      errorStrategy { task.exitStatus = 1 ? 'ignore' :  'terminate' }
      label 'virfinder'
    
    input:
      tuple val(name), file(fasta)
      path model
    
    output:
      tuple val(name), file("${name}_*.list")
    
    script:
      """
      virfinder_modEPV_k8_execute.Rscript ${model} ${fasta} .
      awk '{print \$1"\\t"\$2"\\t"\$3"\\t"\$4}' ${name}*.tsv > ${name}.txt
      cp ${name}.txt ${name}_\${PWD##*/}.list
      """
}
