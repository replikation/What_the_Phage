process pharokka {
    publishDir "${params.output}/${name}/annotation_results/pharokka", mode: 'copy'
    errorStrategy 'ignore'
    label 'pharokka'
    input:
        tuple val(name), path(fasta)
    output: 
        tuple val(name), path("*_pharokka_out"), emit: pharokka_folder_ch, optional: true
        tuple val(name), path("${name}_annotation_pharokka.gff"), emit: pharokka_gff_ch, optional: true
    script:
        """

        pharokka.py -i ${fasta} -o ${name}_pharokka_out -t 10 -d /pharokka_v1.4.0_databases -t ${task.cpus} -f -p ${name}
        mv ${name}_pharokka_out/${name}.gff .
        mv ${name}.gff ${name}_annotation_pharokka.gff

        """
      stub:
        """
        mkdir stub_pharokka_out

        """
}