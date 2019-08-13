FROM rocker/verse:latest

# install dependencies for virsorter
RUN Rscript -e "install.packages('gapminder', repos = 'http://cran.us.r-project.org')" && \
    Rscript -e "install.packages('glmnet', repos = 'http://cran.us.r-project.org')" && \ 
    Rscript -e "install.packages('Rcpp', repos = 'http://cran.us.r-project.org')"

# install qvalue
RUN install2.r --error BiocManager \
    && Rscript -e 'requireNamespace("BiocManager"); BiocManager::install();' \
    && Rscript -e 'requireNamespace("BiocManager"); BiocManager::install(c("qvalue"));' \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

#get/install VIRfinder
RUN apt-get update --fix-missing && apt-get install -y \
    git
    
RUN git clone https://github.com/jessieren/VirFinder.git
RUN R CMD INSTALL /VirFinder/linux/VirFinder_1.1.tar.gz
