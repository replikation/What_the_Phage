process setup_container {
        label 'noContainer'
        errorStrategy = "retry"
        maxRetries = 3
    input:
        file(config_file)
    output:
        file("everything_done.txt")
    script:
        if (workflow.profile.contains('docker')) 
        """        
        download_docker.sh ${config_file}

        touch everything_done.txt
        """
        else if (workflow.profile.contains('singularity'))
        """
        if  [[ ${params.cachedir} == "/*" ]] ; then
                download_singularity.sh ${config_file} ${params.cachedir} 
        else
                download_singularity.sh ${config_file} ${workflow.launchDir}/${params.cachedir} 
        fi
        
        touch everything_done.txt
        """
}
