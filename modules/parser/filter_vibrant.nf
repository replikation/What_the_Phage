process filter_vibrant {
    label 'ubuntu'
    input:
        tuple val(name), file(results) 
    output:
        tuple val(name), file("vibrant_*.txt")
    script:
        """
        tail -q  -n+2 *.tsv | awk '{if(\$2=="virus"){print \$1}}' | sed -r 's/_fragment_[0-9]//' > vibrant_\${PWD##*/}.txt
        """
}

process filter_vibrant_virome {
    label 'ubuntu'
    input:
        tuple val(name), file(results) 
    output:
        tuple val(name), file("vibrant-virome_*.txt")
    script:
        """
        tail -q  -n+2 *.tsv | awk '{if(\$2=="virus"){print \$1}}' | sed -r 's/_fragment_[0-9]//' > vibrant-virome_\${PWD##*/}.txt
        """
}

// filter needs to be addet

/*
filteroutput needs to be:

contigname,score

whereas score is from 0 to 1 (usually the tools p value)
Needs to be parsed for "categories"
e.g. a tool with phage yes / no gets 0 or 1
for multiple kategories (eg. 1 to 4 wheras 1 is phage and 4 not)
  you pares 0 0.33 0.66 1    or whatever seems reasonable for the tool
*/