# Phage benchmark Workflow

* by Christian Brandt & Mike Marquet

## The following Phage-Tools are included

* [MARVEL Metagenomic Analysis and Retrieval of Viral Elements](https://github.com/LaboratorioBioinformatica/MARVEL#metagenomic-analysis-and-retrieval-of-viral-elements)
  * [paper](https://www.frontiersin.org/articles/10.3389/fgene.2018.00304/full)
* [VirFinder: R package for identifying viral sequences from metagenomic data using sequence signatures](https://github.com/jessieren/VirFinder)
  * [paper](https://link.springer.com/epdf/10.1186/s40168-017-0283-5?)
* [PPR-Meta: a tool for identifying phages and plasmids from metagenomic fragments using deep learning](https://github.com/zhenchengfang/PPR-Meta)
  * [paper](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6586199/)
   + [x] Docker file created
* [VirSorter](https://github.com/simroux/VirSorter)
  * [paper](https://peerj.com/articles/985/)
* [MetaPhinder](https://github.com/vanessajurtz/MetaPhinder)
  * [paper](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0163111)
* [DeepVirFinder](https://github.com/jessieren/DeepVirFinder)
  * [paper](https://arxiv.org/abs/1806.07810)

## Installation

* this workflow runs in a workflow manager `nextflow` using `docker`
* this means it will get all programs and dependencies automatically

### Dependencies

* this are the dependencies for the workflow itself
    * docker (add docker to your Usergroup, so no sudo is needed)
    * nextflow + java runtime 
    * git
    * wget
    * tar


## Execution

* for local use you could either clone the git and do:

```bash
./phage.nf --fasta 'test-data/*.fasta'
```

* or execute it directly via 

```bash
nextflow run replikation/wf_phage_benchmark --fasta 'your-fasta-files/*.fasta'
# or
nextflow run replikation/wf_phage_benchmark --fasta your-file.fasta
```


## Help

```bash
nextflow run replikation/wf_phage_benchmark --help
# or
./phage.nf --help
```