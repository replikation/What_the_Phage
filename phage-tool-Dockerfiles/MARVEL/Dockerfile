FROM ubuntu:bionic

RUN apt update && apt install -y wget ncbi-blast+ procps hmmer git python3 python3-pip \
    libdatetime-perl libxml-simple-perl libdigest-md5-perl git default-jre bioperl && \
    git clone https://github.com/LaboratorioBioinformatica/MARVEL && \
    git clone https://github.com/tseemann/prokka.git && \
    pip3 install -U numpy scipy biopython scikit-learn && \
    apt remove -y git python-pip && apt-get clean &&  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN cpan Bio::Perl

WORKDIR /MARVEL/
RUN python3 download_and_set_models.py
# small hack due to stupid database pathing
RUN sed -i 's#models/#/MARVEL/models/#g' marvel_bins.py
RUN chmod +x /MARVEL/marvel_bins.py
WORKDIR /

ENV PATH /MARVEL:$PATH 
ENV PATH /prokka/bin:$PATH 
# remove old versions from previous blast install (biopython/perl) and do a fresh install
RUN rm /usr/bin/makeblastdb && rm /usr/bin/blast* && apt update && apt install ncbi-blast+ && \
    apt-get clean &&  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 
RUN prokka --setupdb