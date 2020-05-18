FROM continuumio/miniconda3

RUN apt update && apt install -y procps make gcc && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN conda config --add channels conda-forge && \
    conda config --add channels bioconda && \
    conda config --add channels default

RUN conda install -c bioconda mcl=14.137 muscle blast perl-bioperl perl-file-which \
    hmmer=3.1b2 perl-parallel-forkmanager perl-list-moreutils diamond=0.9.14 && conda clean -a

RUN git clone https://github.com/simroux/VirSorter.git
RUN cd VirSorter/Scripts && make

RUN cd /bin && wget http://metagene.nig.ac.jp/metagene/mga_x86_64.tar.gz && tar -xvzf mga_x86_64.tar.gz && rm mga_x86_64.tar.gz

ENV PATH /VirSorter:$PATH
