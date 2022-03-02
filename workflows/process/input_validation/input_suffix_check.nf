process input_suffix_check {
    publishDir "${params.output}/${name}/Input_fasta", mode: 'copy', pattern: "${name}.fa.gz"
    label 'ubuntu'
    input:
        tuple val(name), path(file) 
    output:
        tuple val(name), path("${name}.fa.gz")
    script:
        """
        case "${file}" in
            *.gz) 
                zcat ${file} > ${name}.fa
                ;;
            *.fna)
                cp ${file} ${name}.fa
                ;;
            *.fasta)
                cp ${file} ${name}.fa
                ;;
            *.fa)
                ;;
            *)
                echo "file format not supported...what the phage...(.fa .fasta .fna .gz is supported)"
                exit 1
        esac
        
        # tr whitespace at the end of lines
        sed 's/[[:blank:]]*\$//' -i ${name}.fa
        # remove ' and "
        tr -d "'"  < ${name}.fa | tr -d '"' | tr -d "[]" > tmp.file && mv tmp.file ${name}.fa
        # replace ( ) | . , / and whitespace with _
        sed 's#[()|.,/ ]#_#g' -i ${name}.fa
        # remove empty lines
        sed '/^\$/d' -i ${name}.fa
        # pack file
        gzip ${name}.fa
        """
    stub:
        """
        touch ${name}.fa.gz
        """
}


/*
COMMENTS:
        # tr whitespace at the end of lines
        # sed 's/[[:blank:]]*$//' -i ${name}.fa
        # replace other spaces with _
        # sed 's, ,_,g' -i ${name}.fa

*/