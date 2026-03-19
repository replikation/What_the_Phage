/*******************************************************
 * WHAT THE PHAGE // HELP MESSAGE
 *******************************************************/

def helpMSG() {
    def c_pink   = "\033[1;35m"
    def c_cyan   = "\033[1;36m"
    def c_yellow = "\033[1;33m"
    def c_dim    = "\033[2;37m"
    def c_reset  = "\033[0m"

    log.info """
    ${c_cyan}╔═════════════════════════════════════════════════════╗
    ║                 ${c_pink}WHAT THE PHAGE${c_cyan}                      ║
    ╚═════════════════════════════════════════════════════╝${c_reset}
    
    ${c_pink}[:: USAGE EXAMPLES ::]${c_reset}

    ${c_dim}> Standard execution:${c_reset}
    nextflow run phage.nf --fasta '*/*.fasta' --cores 20 \\
        --end_to_end --output results -profile local,docker
    
    ${c_dim}> HPC cluster (LSF/Singularity):${c_reset}
    nextflow run phage.nf --fasta '*/*.fasta' --cores 20 \\
        --end_to_end --output results -profile lsf,singularity \\
        --cachedir /images/singularity_images \\
        --databases /databases/WtP_databases/ 

    ${c_dim}> Modular execution (custom pipeline parameters):${c_reset}
    nextflow run phage.nf --fasta '*/*.fasta' --cores 20 \\
        --identify --prophage --output results -profile lsf,singularity \\
        --cachedir /images/singularity_images \\
        --databases /databases/WtP_databases/ 

    ${c_pink}[:: INPUT PARAMETERS ::]${c_reset}
    --fasta             ${c_yellow}'*.fasta'${c_reset}   -> assembly file(s)
    --setup             skips analysis, downloads databases and containers

    ${c_pink}[:: WORKFLOW CONTROL ::]${c_reset}
    --end_to_end        runs identification, annotation, taxonomy, prophage, host, lifecycle
    --identify          runs phage identification
    --annotation        runs annotation
    --taxonomy          runs taxonomy
    --prophage          runs prophage identification
    --host              runs host prediction
    --lifecycle         runs lifecycle prediction
    ${c_dim}(combine flags as needed: e.g. --identify --host)${c_reset}

    ${c_pink}[:: PROFILES & ENGINES ::]${c_reset}
    Execute via profile configurations: ${c_cyan}-profile <Executor>,<Engine>${c_reset}
    
    ${c_cyan}[ EXECUTORS ]${c_reset}  -> slurm | local | lsf | ebi
    ${c_pink}[ ENGINES ]${c_reset}    -> docker | singularity

    ${c_dim}Test environment configuration (~ 1h execution):${c_reset}
    -profile smalltest,local,singularity 

    ${c_pink}[:: OPTIONS ::]${c_reset}
    --filter            min contig size [bp] to bypass [default: $params.filter]
    --cores             max cores per process [default: $params.cores]
    --max_cores         max cores used on the machine [default: $params.max_cores]    
    --output            name of the result folder [default: $params.output]

    ${c_pink}[:: TOOL CONTROLS ::]${c_reset}
    ${c_dim}// Activate/Deactivate specific tools${c_reset}
    --all_tools         activate all phage prediction tools
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

    ${c_pink}[:: VISUALIZATION ::]${c_reset}
    --pharokka          activate Pharokka Plot
    --plot_completeness plot contigs with CheckV completeness > 75.00 

    ${c_pink}[:: DATABASES ::]${c_reset}
    ${c_dim}Default database: NCBI 4700 sequences + metadata${c_reset}
    --phage_scope_tax   switch to curated 800000 sequences + metadata
    --annotation_db     /path/to/custom_phage_annotation_db.tar.gz

    ${c_pink}[:: SYSTEM PATHS ::]${c_reset}
    --databases         database download location [default: ${params.databases}]
    --workdir           temporary work directory [default: $params.workdir]
    --cachedir          singularity cache directory [default: $params.cachedir] 
    """.stripIndent()
}

def defaultMSG() {
    def c_pink   = "\033[1;35m"
    def c_cyan   = "\033[1;36m"
    def c_green  = "\033[1;32m"
    def c_yellow = "\033[1;33m"
    def c_dim    = "\033[2;37m"
    def c_reset  = "\033[0m"

    def c_enabled  = "${c_pink}[ ENABLED ]${c_reset}"
    def c_disabled = "${c_dim}[ DISABLED ]${c_reset}"

    def idStatus     = (params.identify || params.end_to_end) ? c_enabled : c_disabled
    def annTaxStatus = (params.annotate_taxonomy || params.end_to_end) ? c_enabled : c_disabled
    def propStatus   = (params.prophage || params.end_to_end) ? c_enabled : c_disabled
    def hostStatus   = (params.host || params.end_to_end) ? c_enabled : c_disabled
    def lifeStatus   = (params.lifecycle || params.end_to_end) ? c_enabled : c_disabled

    log.info """
${c_cyan}      ▀▀▀▀▀▀ ▀▀▀▀▀▀ ▀▀▀▀ ▀▀▀▀ ▀▀▀ ▀▀▀ ▀▀ ▀▀ ▀ ▀${c_reset}
${c_pink}          __      _______________________ 
         /  \\    /  \\__    ___/\\______   \\
         \\   \\/\\/   / |    |    |     ___/
          \\        /  |    |    |    |    
           \\__/\\  /   |____|    |____|    
                \\/                        ${c_reset}
${c_cyan}      ▄▄▄▄▄▄ ▄▄▄▄▄▄ ▄▄▄▄ ▄▄▄▄ ▄▄▄ ▄▄▄ ▄▄ ▄▄ ▄ ▄${c_reset}

${c_cyan}[:: WHAT THE PHAGE :: WORKFLOW INFORMATION ::]${c_reset}
${c_green}» Profile:${c_reset}           ${workflow.profile}
${c_green}» Current User:${c_reset}      ${workflow.userName}
${c_green}» Nextflow Version:${c_reset}  v${nextflow.version}
${c_green}» Start Time:${c_reset}        ${nextflow.timestamp}

${c_pink}[:: DIRECTORIES ::]${c_reset}
${c_yellow}» Databases:${c_reset}         ${params.databases}
${c_yellow}» Results Dir:${c_reset}       ${params.output}
${c_yellow}» Work Dir:${c_reset}          ${workflow.workDir}""" + 

(workflow.profile == 'standard' ? """
${c_yellow}» CPUs:${c_reset}              ${params.cores}""" : "") +

(workflow.profile.contains('singularity') ? """
${c_yellow}» Singularity Cache:${c_reset} ${params.cachedir}""" : "") +

"""

${c_cyan}[:: WORKFLOW STEPS ::]${c_reset}
${c_dim}» Identification:......${c_reset}  ${idStatus}
${c_dim}» Annotation/Taxonomy:.${c_reset}  ${annTaxStatus}
${c_dim}» Prophage:............${c_reset}  ${propStatus}
${c_dim}» Host:................${c_reset}  ${hostStatus}
${c_dim}» Lifecycle:...........${c_reset}  ${lifeStatus}
${c_cyan}▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀${c_reset}
"""
}

def progressBar(workflow) {
    def c_pink   = "\033[1;35m"
    def c_cyan   = "\033[1;36m"
    def c_reset  = "\033[0m"
    def c_dim    = "\033[2;37m"

    def completed = workflow.stats.succeededCount + workflow.stats.cachedCount + workflow.stats.failedCount
    def total     = workflow.stats.submittedCount
    
    if (total > 0) {
        def percent = (completed * 100.0) / total
        def width   = 40
        def done    = (int) (percent / 100 * width)
        def remain  = width - done
        
        def bar = "${c_pink}" + "█" * done + "${c_dim}" + "░" * remain + "${c_reset}"
        
        print "\r${c_cyan}[ WORKFLOW PROGRESS ]${c_reset} ${bar} ${c_cyan}${String.format('%.1f', percent)}%${c_reset} ${c_dim}[${completed}/${total}]${c_reset}"
        if (completed == total) println ""
    }
}
