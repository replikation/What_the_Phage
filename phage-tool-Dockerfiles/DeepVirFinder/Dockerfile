FROM continuumio/miniconda3
ENV VERSION 'no version available'
ENV TOOLNAME DeepVirFinder

RUN apt-get update && apt install -y procps g++ && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN conda config --add channels conda-forge && \
    conda config --add channels bioconda && \
    conda config --add channels default

RUN conda install python=3.6 numpy theano keras scikit-learn Biopython mkl-service && conda clean -a
RUN git clone https://github.com/jessieren/$TOOLNAME
RUN chmod +x /$TOOLNAME/dvf.py
ENV PATH /$TOOLNAME:$PATH

