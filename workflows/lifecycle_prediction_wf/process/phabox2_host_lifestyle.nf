process phabox2_host_lifecycle {
        publishDir "${params.output}/${name}/host_lifecycle", mode: 'copy' , pattern: "*.tsv"
        errorStrategy 'ignore'
        label 'phabox2'
    input:
        tuple val(name), path(fasta)
    output:
        
        tuple val(name), path("${name}_gene_annotation_*.tsv"), emit: phabox2_annotation, optional: true
    script:
        """
        phabox2 --task phatyp --dbdir /phabox_db_v2_1/ --outpth ${name}_results_host_lifecycle --contigs ${fasta}
        
        mv ${name}_results_host_lifecycle/final_prediction/phatyp_prediction.tsv ${name}_results_host_lifecycle/final_prediction/${name}_phatyp_prediction_\${PWD##*/}.tsv
        mv ${name}_results_host_lifecycle/final_prediction/${name}_phatyp_prediction_\${PWD##*/}.tsv .
        
        
        phabox2 --task phatyp --dbdir /phabox_db_v2_1/ --outpth ${name}_results_host_lifecycle --contigs ${fasta}
        
    
        mv ${name}_results_host_lifecycle/final_prediction/cherry_prediction.tsv ${name}_results_host_lifecycle/final_prediction/${name}_cherry_prediction_\${PWD##*/}.tsv
        mv ${name}_results_host_lifecycle/final_prediction/${name}_cherry_prediction_\${PWD##*/}.tsv .
        

        """
    stub:
        """
        touch ${name}_cherry_prediction_\${PWD##*/}.tsv
        """
}




// phatyp 
// root@bcf3d50100e5:/# cat phabox2_host_lifecycle/final_prediction/phatyp_prediction.tsv 
// Accession	Length	TYPE	PhaTYPScore
// pos.phage.0	146647	virulent	1.0
// pos.phage.1	58871	virulent	0.99
// pos.phage.2	58560	virulent	0.56
// pos.phage.3	59443	virulent	1.0
// pos.phage.4	51290	virulent	1.0
// pos.phage.5	43293	temperate	1.0
// pos.phage.6	43851	virulent	1.0
// pos.phage.7	44262	virulent	1.0
// pos.phage.8	41865	virulent	1.0
// pos.phage.9	221908	virulent	1.0


// cherry
// root@bcf3d50100e5:/# cat phabox2_host_lifecycle/final_prediction/cherry_prediction.tsv 
// Accession	Length	Host	CHERRYScore	Method	Host_NCBI_lineage	Host_GTDB_lineage
// pos.phage.9	221908	species:Bacillus subtilis	1.00	AAI-based	d__Bacteria;p__Bacillota;c__Bacilli;o__Bacillales;f__Bacillaceae;g__Bacillus;s__Bacillus subtilis	-
// pos.phage.8	41865	genus:Salmonella	0.64	AAI-based	d__Bacteria;p__Pseudomonadota;c__Gammaproteobacteria;o__Enterobacterales;f__Enterobacteriaceae;g__Salmonella;s__	-
// pos.phage.7	44262	genus:Xanthomonas	1.00	AAI-based	d__Bacteria;p__Pseudomonadota;c__Gammaproteobacteria;o__Lysobacterales;f__Lysobacteraceae;g__Xanthomonas;s__	-
// pos.phage.6	43851	genus:Xanthomonas	1.00	AAI-based	d__Bacteria;p__Pseudomonadota;c__Gammaproteobacteria;o__Lysobacterales;f__Lysobacteraceae;g__Xanthomonas;s__	-
// pos.phage.5	43293	species:Staphylococcus epidermidis	0.90	AAI-based	d__Bacteria;p__Bacillota;c__Bacilli;o__Bacillales;f__Staphylococcaceae;g__Staphylococcus;s__Staphylococcus epidermidis	-
// pos.phage.4	51290	species:Bifidobacterium animalis	0.93	CRISPR-based (DB)	d__Bacteria;p__Actinobacteria;c__Actinobacteria;o__Bifidobacteriales;f__Bifidobacteriaceae;g__Bifidobacterium;s__Bifidobacterium animalis	d__Bacteria;p__Actinomycetota;c__Actinomycetes;o__Actinomycetales;f__Bifidobacteriaceae;g__Bifidobacterium;s__Bifidobacterium animalis_B
// pos.phage.3	59443	genus:Arthrobacter	1.00	AAI-based	d__Bacteria;p__Actinomycetota;c__Actinomycetes;o__Micrococcales;f__Micrococcaceae;g__Arthrobacter;s__	-
// pos.phage.2	58560	-	-		-	-
// pos.phage.1	58871	-	-		-	-
// pos.phage.0	146647	species:Escherichia coli	0.91	AAI-based	d__Bacteria;p__Pseudomonadota;c__Gammaproteobacteria;o__Enterobacterales;f__Enterobacteriaceae;g__Escherichia;s__Escherichia coli	-
