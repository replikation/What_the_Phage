process markdown_preparation {
    publishDir "${params.output}/${name}/Markdown/sup_files", mode: 'copy', pattern: "*tsv"
    publishDir "${params.output}/${name}/Markdown/sup_files", mode: 'copy', pattern: "*tbl"
    label 'rmarkdown_pandas'
    input:
        tuple val(name), path(overview)
        tuple val(name), path(annotationtable)
        tuple val(name), path(checkVtable)
    output:
        tuple val(name), path("${name}_contig_by_tool_category.tsv"), emit: contig_by_tool_category_ch
        tuple val(name), path("*${name}_annotationfile.tbl"), emit: sample_annotationfile_ch
        tuple val(name), path("*${name}_quality_summary.tsv"), emit: sample_CheckV_ch
    script:
        """
        contig_by_tool_markdown.py --overview_file ${overview} --output ${name}_contig_by_tool_category.tsv

        ## cat annotationfiles 
        tail -n+2 ${name}_contig_by_tool_category.tsv | cut -d"," -f3 | sort -u > category_list.txt
        ##make list of contigs from each category
        filename='category_list.txt'
        while read line; do
            grep \$line ${name}_contig_by_tool_category.tsv | cut -d"," -f1 > "\$line"_contig_list.lst     
            ## create files with header first
            touch "\$line"_annotationfile.tbl
            head -1 ${checkVtable} > "\$line"_${name}_draft_quality_summary.tsv
            while read ctgline; do
                ## grep contigs and fill header files
                grep \$ctgline ${annotationtable} >> "\$line"_${name}_annotationfile.tbl
                grep \$ctgline ${checkVtable} >> "\$line"_${name}_quality_summary.tsv
            done < "\$line"_contig_list.lst 
        done < \$filename
        """
    stub:
        """
        touch ${name}_contig_by_tool_category.tsv
        touch ${name}_annotationfile.tbl
        touch ${name}_quality_summary.tsv
        """
}