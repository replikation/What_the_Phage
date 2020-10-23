FROM continuumio/miniconda3:latest

RUN apt-get update -y && apt-get install -y procps && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN conda config --add channels conda-forge && \
	conda config --add channels default && \
	conda create -y --name seeker python=3.7 pip && \
	conda clean --all

ENV PATH /opt/conda/envs/seeker/bin:$PATH

SHELL ["conda", "run", "-n", "seeker", "/bin/bash", "-c"]

RUN pip install --no-cache-dir --use-feature=2020-resolver seeker==1.0.3


