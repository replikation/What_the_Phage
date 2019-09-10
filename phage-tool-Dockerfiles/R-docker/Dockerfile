FROM rocker/verse:latest

# install dependencies for virsorter
RUN Rscript -e "install.packages('dplyr', repos = 'http://cran.us.r-project.org')" && \
    Rscript -e "install.packages('ggplot2', repos = 'http://cran.us.r-project.org')" && \ 
    Rscript -e "install.packages('tidyr', repos = 'http://cran.us.r-project.org')" && \  
    Rscript -e "install.packages('RColorBrewer', repos = 'http://cran.us.r-project.org')" && \ 
    Rscript -e "install.packages('ggthemes', repos = 'http://cran.us.r-project.org')" && \ 
    Rscript -e "install.packages('gridExtra', repos = 'http://cran.us.r-project.org')" && \ 
    Rscript -e "install.packages('reshape2', repos = 'http://cran.us.r-project.org')" && \ 
    rm -rf /tmp/downloaded_packages/ /tmp/*.rds

RUN apt-get update && apt install -y procps g++ && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /scripts
COPY heatmap.R /scripts
COPY convert.sh /scripts
RUN chmod +x /scripts/convert.sh /scripts/heatmap.R
ENV PATH /scripts:$PATH
ENTRYPOINT ["/bin/bash"]
