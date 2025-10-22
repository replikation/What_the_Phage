/*************  
* --help
*************/
def helpMSG() {
    c_green = "\033[0;32m";
    c_reset = "\033[0m";
    c_yellow = "\033[0;33m";
    c_blue = "\033[0;34m";
    c_purple = "\033[0;35m";
    c_dim = "\033[2m";
    log.info """
    .
    ${c_purple}Usage examples:${c_reset}
    nextflow run replikation/What_the_Phage --fasta '*/*.fasta' --cores 20 --max_cores 40 \\
        --output results -profile local,docker 

    nextflow run phage.nf --fasta '*/*.fasta' --cores 20 \\
        --output results -profile lsf,singularity \\
        --cachedir /images/singularity_images \\
        --databases /databases/WtP_databases/ 

    ${c_purple}Input:${c_reset}
     --fasta             '*.fasta'   -> assembly file(s)
     --fastq             '*.fastq'   -> long read file(s)
    ${c_dim}  ..change above input to csv via --list ${c_reset}  
    ${c_dim}   e.g. --fasta inputs.csv --list    
        the .csv contains per line: name,/path/to/file${c_reset}  
     --setup              skips analysis and just downloads databases and containers

    ${c_purple}Execution/Engine profiles:${c_reset}
     WtP supports profiles to run via different ${c_green}Executers${c_reset} and ${c_blue}Engines${c_reset} e.g.:
     -profile ${c_green}local${c_reset},${c_blue}docker${c_reset}

      ${c_green}Executer${c_reset} (choose one):
      slurm
      local
      lsf
      ebi
      ${c_blue}Engines${c_reset} (choose one):
      docker
      singularity
    
    For a test run (~ 1h), add "smalltest" to the profile, e.g. -profile smalltest,local,singularity 
    
    ${c_purple}Options:${c_reset}
    --filter            min contig size [bp] to analyse [default: $params.filter]
    --cores             max cores per process for local use [default: $params.cores]
    --max_cores         max cores used on the machine for local use [default: $params.max_cores]    
    --output            name of the result folder [default: $params.output]

    ${c_purple}Tool control:${c_reset}
    Deploy all integrated phage prediction tools
    --all_tools         activate all phage prediction tools     

    Deactivate tools individually by adding one or more of these flags
    --dv                deactivates deepvirfinder
    --mp                deactivates metaphinder
    --pp                deactivates PPRmeta
    --sm                deactivates sourmash
    --vb                deactivates vibrant
    --vf                deactivates virfinder
    --vn                deactivates virnet
    --vs                deactivates virsorter
    --ph                deactivates phigaro
    --vs2               deactivates virsorter2
    --sk                deactivates seeker
    --pb2               deactivates phabox2_phamer

    Activate Pharokka Plot
    --pharokka

    switch databases for Phage tax classification
    default database    NCBI 4700 sequences + metadata
    --phage_scope_tax   800000 sequences + metadata  curated phagescope-Database

    ${c_purple}Custom phage annotation Database:${c_reset}
    --annotation_db     /path/to/your/custom_phage_annotation_db.tar.gz
                        Please provide a custom_phage_annotation_db.tar.gz archive that contains the following file formats:
                        *.hmm  *.hmm.h3f  *.hmm.h3i  *.hmm.h3m  *.hmm.h3p

    ${c_yellow}Workflow control:${c_reset}
    --identify          only phage identification, skips analysis
    --annotate          only annotation, skips phage identification
    --plot_completeness will plot Phage-contigs with CheckV-completeness > 75.00 (or you provide your cutoff value, e.g. 80.00)

    ${c_yellow}Databases, file, container behaviour:${c_reset}
    --databases         specifiy download location of databases 
                        [default: ${params.databases}]
                        ${c_dim}WtP downloads DBs if not present at this path${c_reset}

    --workdir           defines the path where nextflow writes temporary files 
                        [default: $params.workdir]

    --cachedir          defines the path where singularity images are cached
                        [default: $params.cachedir] 

    """.stripIndent()
}

def defaultMSG() {


println "_____ _____ ____ ____ ___ ___ __ __ _ _ "
println "  __      _______________________ "
println " /  \\    /  \\__    ___/\\______   \\"
println " \\   \\/\\/   / |    |    |     ___/"
println "  \\        /  |    |    |    |    "
println "   \\__/\\  /   |____|    |____|    "
println "        \\/                        "
println "_____ _____ ____ ____ ___ ___ __ __ _ _ "



   def c_turquoise = "\033[1;36m"      // Turquoise (bright cyan)
    def c_green = "\033[1;32m"          // Green (for ENABLED)
    def c_dim = "\033[2;37m"            // Grey/dim text
    def c_reset = "\033[0m"

    def c_enabled = "${c_green}ENABLED${c_reset}"
    def c_disabled = "${c_dim}DISABLED${c_reset}"
    def line = "─" * 30  // Unicode box drawing character U+2500

    // Conditional prints are located here
    def extraInfo = ""
    extraInfo += "${c_turquoise}identification:           ${c_reset}" + (params.identify || params.end_to_end ? c_enabled : c_disabled) + "\n"
    extraInfo += "${c_turquoise}annotation and taxonomy:  ${c_reset}" + (params.annotate_taxonomy || params.end_to_end ? c_enabled : c_disabled) + "\n"
    extraInfo += "${c_turquoise}prophage:                 ${c_reset}" + (params.prophage || params.end_to_end ? c_enabled : c_disabled) + "\n"
    extraInfo += "${c_turquoise}host:                     ${c_reset}" + (params.host || params.end_to_end ? c_enabled : c_disabled) + "\n"
    extraInfo += "${c_turquoise}lifecycle:                ${c_reset}" + (params.lifecycle || params.end_to_end ? c_enabled : c_disabled) + "\n"



    log.info """
${c_turquoise}${line} What the Phage Workflow Information ${line}${c_reset}
${c_turquoise}Profile:           ${c_reset}${workflow.profile}
${c_turquoise}Current User:      ${c_reset}${workflow.userName}
${c_turquoise}Nextflow Version:  ${c_reset}${nextflow.version}
${c_turquoise}Start Time:        ${c_reset}${nextflow.timestamp}
${c_turquoise}Databases:         ${c_reset}${params.databases}
${c_turquoise}Results Dir:       ${c_reset}${params.output}
${c_turquoise}Work Dir:          ${c_reset}${workflow.workDir}
${extraInfo}""" + 
    (workflow.profile == 'standard' ? """
${c_turquoise}CPUs:              ${c_reset}${params.cores}
${c_turquoise}Output Dir Name:   ${c_reset}${params.output}
""" : "") +
    (workflow.profile.contains('singularity') ? """
${c_turquoise}Singularity Cache: ${c_reset}${params.cachedir}
""" : "") +
"""
${c_turquoise}${line * 3}${c_reset}
"""
}