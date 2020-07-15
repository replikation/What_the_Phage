process testprofile {
        publishDir "${params.output}/test-git", mode: 'copy', pattern: "WtP_test-data/01.Phage_assemblies/ERR*.fasta.gz"
        label 'noDocker'
    output:
        file("WtP_test-data/01.Phage_assemblies/ERR*.fasta.gz")
    script:
        """
        git clone https://github.com/mult1fractal/WtP_test-data.git
        """
}