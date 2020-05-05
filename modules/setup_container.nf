process setup_container {
        label 'noContainer'
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
        download_singularity.sh ${config_file}

        touch everything_done.txt
        """
}