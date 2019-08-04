FROM continuumio/miniconda3
MAINTAINER Mike Marquet <stormrider935@googlemail.com>


 RUN conda config --add channels conda-forge && \
     conda config --add channels bioconda && \
     conda config --add channels default

RUN conda install prokka && conda clean -a

RUN conda install -c conda-forge -c bioconda prokka
RUN pip install -U numpy scipy biopython scikit-learn
RUN git clone https://github.com/LaboratorioBioinformatica/MARVEL

WORKDIR /MARVEL/
RUN python3 download_and_set_models.py

RUN chmod +x /MARVEL/marvel_bins.py
ENV PATH /MARVEL:$PATH 
