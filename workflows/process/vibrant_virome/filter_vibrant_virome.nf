process filter_vibrant_virome {
    label 'ubuntu'
    input:
        tuple val(name), path(results) 
    output:
        tuple val(name), path("vibrant-virome_*.tsv")
    script:
        """
        tail -n+2 *.tsv | \
        awk 'BEGIN {OFS=FS="\\t"; IGNORECASE=1} {if(\$2) sub(/virus/,"1"); print}' | \
        awk 'BEGIN {OFS=FS="\\t"; IGNORECASE=1} {if(\$2) sub(/organism/,"0"); print}' | \
        sed -r 's/_fragment_[0-9]//' > vibrant-virome_\${PWD##*/}.tsv
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