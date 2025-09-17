process phage_map_report {
        label 'ubuntu'  
    input:
        tuple val(name), path(jpgs), path(input), path(markdown)
    output:
        tuple val(name), path("${name}_report_plasmids.Rmd"), path("${name}_report_plasmids.?.svg")
    script:
        number = Math.abs(new Random().nextInt() % 9000000000)
        """
        # generate html container file and rename svgs                    
        bash plasmid_report_parser.sh ${name} html_inject.txt ${number}

        # get header lines of RMD and inject html block
        HEADLINES=\$(grep -n '</script>' ${markdown} | cut -f1 -d ":")
        TAILLINES=\$(echo \$(( \$(wc -l ${markdown} | cut -f1 -d " ") - \${HEADLINES} )) )

        head -\${HEADLINES} ${markdown} | sed -e 's@#HASHID#@${number}@g' > ${name}_report_plasmids.Rmd
        cat html_inject.txt >> ${name}_report_plasmids.Rmd
        tail -\${TAILLINES} ${markdown} >> ${name}_report_plasmids.Rmd
        
        """
    stub:
        """
        # rename input file to avoid collisions later
        cp *.svg ${name}_report_plasmids.svg

        # modify markdown with input
        sed -e 's@#RESULTSENV#@${name}_report_plasmids.svg@g' ${markdown} > ${name}_report_plasmids.1.Rmd
        """
}

/*
Example code that the shell script is generating for the markdown

<select onchange="showImage(this.value)">
  <option value="image1">Plasmid-Phage 1</option>
  <option value="image2">Plasmid-Phage 2</option>
  <!-- Add more options as needed -->
</select>

<div class="image-container" id="image1" >
  <img src="#RESULTSENV1#" alt="Plasmid-Phage 1">
</div>

<div class="image-container" id="image2" style="display:none;">
  <img src="#RESULTSENV2#" alt="Plasmid-Phage 2">
</div>
*/