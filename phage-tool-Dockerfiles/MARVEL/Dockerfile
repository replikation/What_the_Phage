FROM continuumio/miniconda3:latest

RUN apt-get update && apt-get upgrade -y && apt-get install -y procps
    
RUN conda config --add channels conda-forge && \
	conda config --add channels defaults && \
    conda config --add channels bioconda

# Install all dependencies with conda
RUN conda install -y \
    python=3.7 \
    hmmer \
    biopython=1.75 \
    scikit-learn=0.19.1 \
    numpy \
    prokka \
    scipy

# TEMPORARY: Use this branch with the fix from thr fork
RUN git clone https://github.com/papanikos/MARVEL.git -b fix_1 

WORKDIR /MARVEL/
# Get the data
RUN python3 download_and_set_models.py
# small hack due to stupid database pathing
RUN sed -i 's#models/#/MARVEL/models/#g' marvel_bins.py
#Make the script executable
RUN chmod +x /MARVEL/marvel_bins.py

# Go back to root dir
WORKDIR /

# Include the executable marvel_bins.py in the PATH
ENV PATH /MARVEL:$PATH 

# Cleanup packages to reduce image size
RUN conda clean --all && apt-get autoremove
