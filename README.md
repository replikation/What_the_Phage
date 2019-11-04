# What the Phage (WtP)

![](https://img.shields.io/badge/nextflow-19.10.0-brightgreen)
![](https://img.shields.io/badge/uses-docker-blue.svg)
![](https://img.shields.io/badge/licence-GPL--3.0-lightgrey.svg)

* by Christian Brandt & Mike Marquet

## What is this Repo?

* an attempt to streamline the usage of various phage identification and prediction tools
* the main focus is stability an data filtering / analysis for the user

## The following Phage-Tools are currently included

* [MARVEL Metagenomic Analysis and Retrieval of Viral Elements](https://github.com/LaboratorioBioinformatica/MARVEL#metagenomic-analysis-and-retrieval-of-viral-elements)
  * [paper](https://www.frontiersin.org/articles/10.3389/fgene.2018.00304/full)
* [VirFinder: R package for identifying viral sequences from metagenomic data using sequence signatures](https://github.com/jessieren/VirFinder)
  * [paper](https://link.springer.com/epdf/10.1186/s40168-017-0283-5?)
* [PPR-Meta: a tool for identifying phages and plasmids from metagenomic fragments using deep learning](https://github.com/zhenchengfang/PPR-Meta)
  * [paper](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6586199/)
* [VirSorter](https://github.com/simroux/VirSorter)
  * [paper](https://peerj.com/articles/985/)
* [MetaPhinder](https://github.com/vanessajurtz/MetaPhinder)
  * [paper](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0163111)
* [DeepVirFinder](https://github.com/jessieren/DeepVirFinder)
  * [paper](https://arxiv.org/abs/1806.07810)

## Workflow

![chart](figures/chart.png)

## Installation

* WtP runs with the workflow manager `nextflow` using `docker`
* this means all programs are automatically pulled via docker and only docker and nextflow needs to be installed

### Dependencies

>   * docker (add docker to your Usergroup, so no sudo is needed)
>   * nextflow + java runtime 
>   * git
>   * wget
>   * tar



### Install java
```
sudo apt install default-jre
```


### Install Nextflow:
```
curl -s https://get.nextflow.io | bash 
mv /path/to/nextflowdownload/nextflow /bin/
```

### Install Docker
```
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
```
add the docker group to your user via `sudo usermod -a -G docker $USER`

### Run our example files

```
git clone https://github.com/replikation/What_the_Phage.git
nextflow run replikation/What_the_Phage --fasta 'What_the_Phage/test-data/*.fasta'



## Execution

* for local use you could either clone the git and do:

```bash
./phage.nf --fasta 'test-data/*.fasta'
```

* or execute it directly via 

```bash
nextflow run replikation/What_the_Phage --fasta 'your-fasta-files/*.fasta'
# or
nextflow run replikation/What_the_Phage --fasta your-file.fasta
```


## Help

```bash
nextflow run replikation/What_the_Phage --help
# or
./phage.nf --help
```
