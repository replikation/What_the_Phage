FROM continuumio/miniconda3

RUN apt-get update && apt-get install -y procps && \
    apt-get upgrade -y && apt-get autoremove

RUN conda config --add channels conda-forge && \
    conda config --add channels bioconda && \
    conda config --add channels default

RUN conda install -y -c bioconda virsorter=2

RUN conda clean -y --all

