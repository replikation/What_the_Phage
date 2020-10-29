process removeSmallReads {
  label 'ubuntu'
  input:
      tuple val(name), file(reads) 
  output:
	    tuple val(name), file("${name}_filtered.fastq") 
  shell:
      """
      case "!{reads}" in
        *.fastq.gz ) 
          zcat !{reads} | paste - - - - | awk -F"\\t" 'length(\$2)  >= 400' | sed 's/\\t/\\n/g' > "!{name}_filtered.fastq"
          ;;
        *.fastq)
          cat !{reads} | paste - - - - | awk -F"\\t" 'length(\$2)  >= 400' | sed 's/\\t/\\n/g' > "!{name}_filtered.fastq"
          ;;
      esac   
      """
}

/* Comments:
This is a super fast process to remove short reads.

it can take .fastq or .fastq.gz
*/