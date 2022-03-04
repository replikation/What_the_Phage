![logo](figures/logo-wtp_small.png)

![](https://img.shields.io/github/v/release/replikation/What_the_Phage)
![](https://img.shields.io/badge/licence-GPL--3.0-lightgrey.svg)
![](https://github.com/replikation/What_the_Phage/workflows/Syntax_check/badge.svg)

![](https://img.shields.io/badge/nextflow-20.07.1-brightgreen)
![](https://img.shields.io/badge/uses-docker-blue.svg)
![](https://img.shields.io/badge/uses-singularity-yellow.svg)

[![Generic badge](https://img.shields.io/badge/Preprint-bioRxiv-red.svg)](https://www.biorxiv.org/content/10.1101/2020.07.24.219899v2)
[![Generic badge](https://img.shields.io/badge/Documentation-available-purple.svg)](https://mult1fractal.github.io/wtp-documentation/)

[![Twitter Follow](https://img.shields.io/twitter/follow/gcloudChris.svg?style=social)](https://twitter.com/gcloudChris) 
[![Twitter Follow](https://img.shields.io/twitter/follow/mult1fractal.svg?style=social)](https://twitter.com/mult1fractal) 

# What the Phage (WtP)

* by Christian Brandt & Mike Marquet
* **this tool is under active development,feel free to report issues and add suggestions**
* Use a release candidate for a stable experience via `-r` e.g. `-r v1.1.0`
  * These are extensively tested release versions of WtP
  * [releases of WtP are listed here](https://github.com/replikation/What_the_Phage/releases)  

## Preprint:

> **What the Phage: A scalable workflow for the identification and analysis of phage sequences**
>
> M. Marquet, M. Hölzer, M. W. Pletz, A. Viehweger, O. Makarewicz, R. Ehricht, C. Brandt
>
> doi: https://doi.org/10.1101/2020.07.24.219899

# What is this repo

#### TL;DR
* WtP is a scalable and easy-to-use workflow for phage identification and analysis. Our tool currently combines 12 established phage identification tools 
* An attempt to streamline the usage of various phage identification and prediction tools
* The main focus is stability and data filtering/analysis for the user
* The tool is intended for assembled fasta files to predict phages in contigs
* Proper prophage detection is not implemented - but CheckV reports them
* A full report can be found [here](https://replikation.github.io/What_the_Phage/)


<p align="left">
    <a href="https://replikation.github.io/What_the_Phage/">
        <img src="figures/Result_report_example_picture.PNG" width="500" title="Report file">
</p>

--------------------------------------------------------------

# Documentation 


* The [documentation](https://mult1fractal.github.io/wtp-documentation/) contains:
  * General information 
  * Installation guide
  * Tool overview
  * Result interpretation
  * Troubleshooting 
  
