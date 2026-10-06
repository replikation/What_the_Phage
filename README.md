<div align="center">

![What the Phage](figures/logo-wtp_small.png)

# What the Phage (WtP) v2.0

**Identify, characterize & understand your phages in one run.**

[![Release](https://img.shields.io/github/v/release/replikation/What_the_Phage?style=flat-square)](https://github.com/replikation/What_the_Phage/releases)
[![License](https://img.shields.io/badge/license-GPL--3.0-lightgrey.svg?style=flat-square)](LICENSE)
[![CI](https://github.com/replikation/What_the_Phage/actions/workflows/nextflow-test.yml/badge.svg)](https://github.com/replikation/What_the_Phage/actions)
[![Nextflow](https://img.shields.io/badge/nextflow-25.10%2B-brightgreen.svg?style=flat-square)](https://www.nextflow.io)
[![Docker](https://img.shields.io/badge/uses-docker-blue.svg?style=flat-square)](https://www.docker.com)
[![Singularity](https://img.shields.io/badge/uses-singularity-yellow.svg?style=flat-square)](https://sylabs.io)
[![Publication](https://img.shields.io/badge/Publication-Gigascience-blueviolet.svg?style=flat-square)](https://doi.org/10.1093/gigascience/giac110)
[![Webpage](https://img.shields.io/badge/WtP_v2.0-webpage-purple.svg?style=flat-square)](https://mult1fractal.github.io/WtP_v2_0_webpage/)

[Webpage](https://mult1fractal.github.io/WtP_v2_0_webpage/) · [Live report](https://replikation.github.io/What_the_Phage/) · [Releases](https://github.com/replikation/What_the_Phage/releases) · [Issues](https://github.com/replikation/What_the_Phage/issues)

</div>

What the Phage is a scalable, containerized Nextflow workflow for phage identification and characterization from assembled contigs.

- **16 established phage-identification tools** whose scores are normalized and combined per contig
- **7 analysis modules** that run independently or chained end-to-end (quality, identification, annotation, taxonomy, prophage, host, lifecycle)
- **1 self-contained interactive HTML report** per sample, plus per-sample JSON for downstream use — [open a live example](https://replikation.github.io/What_the_Phage/)

WtP is under active development. For a stable experience, use a release, e.g. `nextflow run replikation/What_the_Phage -r v2.0 ...`.

> **Before installing or running WtP, please read the [WtP v2.0 webpage](https://mult1fractal.github.io/WtP_v2_0_webpage/).**
> It covers the installation guide, all run options, database requirements and a live demo of the report.

## Documentation

Everything you need to install and run WtP lives here:

**[mult1fractal.github.io/WtP_v2_0_webpage](https://mult1fractal.github.io/WtP_v2_0_webpage/)**

Installation guide, full run options, database sizes, expected runtimes and a live demo of the interactive report.


## Tested configurations

| Setup | Status |
| --- | --- |
| `local` executor + `docker` engine (`-profile local,docker`) | Tested |
| Google Cloud (`-profile ukj_cloud`) | Tested |
| `slurm`, `lsf`, `ebi` executors, `singularity` engine | Not tested yet |

> The `slurm`, `lsf`, `ebi` and `singularity` setups are not actively tested.. here I depend on community feedback. If you run WtP on any of them, please share how it went via [Issues](https://github.com/replikation/What_the_Phage/issues). Thanks!


## Workflow


Every module is an independent Nextflow workflow. Run them all with `--end_to_end`, or invoke only the steps you need.

| Module | Tools | Purpose |
| --- | --- | --- |
| Input validation | built-in | header sanitizing, length filter (default 1500 bp) |
| Quality | CheckV | completeness, contamination, provirus flag |
| Identification | DeepVirFinder, MetaPhinder, PPR-Meta, Phigaro, Seeker, Sourmash, VIBRANT, VirFinder, VirNet, VirSorter, VirSorter2, PhaBox (PhaMer) + virome modes | consensus phage prediction |
| Annotation | Prodigal, pVOG/HMMER, Pharokka, PhaBox (PhaVIP), geNomad | gene calling and function |
| Taxonomy | Sourmash, geNomad, PhaBox (PhaGCN), taxmyPHAGE | classification, combined overview |
| Prophage | geNomad, PhaBox, VirSorter2, Phigaro | integrated provirus detection |
| Host | PhaBox (CHERRY), iPHoP (optional, `--iphop`) | host prediction |
| Lifecycle | BACPHLIP, PhaBox (PhaTYP), consensus call | virulent vs. temperate |
| Report | HTML report | interactive per-sample results with genome viewer |

## Output

```
results/
├── <sample>/CheckV/                  # quality metrics
├── <sample>/identified_contigs_by_tools/  # raw tool output + per-contig agreement
├── <sample>/annotation/              # prodigal, HMM, pharokka, phabox2, genomad
├── <sample>/taxonomic-classification/
├── <sample>/prophage/
├── <sample>/host_prediction/
├── <sample>/lifecycle/
├── report/                           # interactive HTML report + JSON
└── literature/                       # tool citations (Citations.bib)
```


## Citation

If you use WtP, please cite:

> Marquet M, Hölzer M, Pletz MW, Viehweger A, Makarewicz O, Ehricht R, Brandt C.
> What the Phage: A scalable workflow for the identification and analysis of phage sequences.
> *GigaScience* (2022). doi: [10.1093/gigascience/giac110](https://doi.org/10.1093/gigascience/giac110)

Please also cite the individual tools used — a ready-to-use bibliography is written to `results/literature/` with every run.

## License

GPL-3.0 — see [LICENSE](LICENSE).
