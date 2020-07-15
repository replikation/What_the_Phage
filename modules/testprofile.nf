process testprofile {
        publishDir "${params.output}/test-git", mode: 'copy', pattern: "ERR*"
        label 'noDocker'
    output:
        file("ERR*")
    script:
        """
        git clone https://github.com/mult1fractal/WtP_test-data.git
        mv WtP_test-data/01.Phage_assemblies/* .
        """
}