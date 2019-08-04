#!/usr/bin/env nextflow

/*
* PHAGE WORKFLOW -- phage workflow
*
* Author: christian.jena@gmail.com && mike.marquet@med.uni-jena.de
*/



// help
def helpMSG() {
    log.info """

    Usage:
	nextflow run phage.mf    

    Mandatory:

    Options:
    """.stripIndent()
}

if (params.help) { exit 0, helpMSG() }


