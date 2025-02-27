process chromomap {
      publishDir "${params.output}/${name}/", mode: 'copy', pattern: "sample_overview_${type}.html"
      label 'chromomap'
      errorStrategy 'retry'
      maxRetries 1
    input:
      tuple val(name), val(type), path(chromosome), path(annotation)
    output:
      tuple val(name), path("sample_overview_${type}.html")
    script:

      """
      anno_categroy_info=\$(cut -f5 ${annotation} | sort -u | wc -l) # returns number of category (other baseplate tail capsid)
      Chromomap_code.R ${chromosome} ${annotation} ${type} \$anno_categroy_info
      if [ -s sample_overview_${type}.html ]; then
            # The file is not-empty.
            sed -i 's/\\(<div id="htmlwidget-[^"]*" class="chromoMap html-widget" style="\\)[^"]*"/\\1width:960px;height:500px;overflow:auto;"/' sample_overview_${type}.html
      else
            # The file is empty.
            echo "nothing found" > sample_overview_${type}.html
      fi

      """
      stub:
        """
        touch sample_overview_${type}.html
        """
}