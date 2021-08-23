process shuffle_reads_nts {
      //publishDir "${params.output}/${name}/sh", mode: 'copy', pattern: "${name}_pos_ctg.fa"
      label 'ruby'
    input:
      tuple val(name), file(reads)
    output:
      tuple val(name), file("${name}_shuffled.fastq")
    script:
      """
      #!/usr/bin/env ruby

        fastq = File.open("${reads}", 'r')
        shuffled = File.open("${name}_shuffled.fastq", 'w')

        i = 0

        out = ''
        fastq.each do |line|
            i += 1
            if i == 1 || i == 3 || i == 4
                out << line
            end
            if i == 2
                out << line.chomp.split("").shuffle.join << "\\n"
            end
            if i == 4
                shuffled << out if out.length > 1
                out = ''
            end
        end

        shuffled.close
        fastq.close
      """
stub:
        """
        touch ${name}_shuffled.fastq
        """
}

