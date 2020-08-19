process phigaro_collect_data {
//       publishDir "${params.output}/${name}/raw_data", mode: 'copy', pattern: "phigaro_results_${name}.tar.gz"
//       label 'ubuntu'
//     input:
//       tuple val(name), file(output_lists)
//     output:
//       tuple val(name), file("pprmeta_results_${name}.tar.gz")
//     script:
//       """
//       cat ${output_lists} | head -1 > ${name}_overview.txt
//       tail -q -n+2 ${output_lists} >> ${name}_overview.txt
//       tar -czf pprmeta_results_${name}.tar.gz ${name}_overview.txt
//       """
// }