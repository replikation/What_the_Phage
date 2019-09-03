FROM ubuntu:bionic


#install dependencies for PPR-Meta-tool
#falls gpu vorhanden: pip install tensorflow-gpu==1.4.1  #GPU version
RUN apt update && apt install -y python2.7 python-pip git unzip wget libxt6 && \
    git clone https://github.com/zhenchengfang/PPR-Meta.git && \
    pip install -U numpy h5py tensorflow keras==2.0.8 && \
    apt-get clean &&  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


#installing MCR


RUN mkdir /mcr-install && \
    mkdir /opt/mcr && \
    cd /mcr-install && \
    wget http://ssd.mathworks.com/supportfiles/downloads/R2018a/deployment_files/R2018a/installers/glnxa64/MCR_R2018a_glnxa64_installer.zip && \
    cd /mcr-install && \
    unzip -q MCR_R2018a_glnxa64_installer.zip && \
    ./install -destinationFolder /opt/mcr -agreeToLicense yes -mode silent && \
    cd / && \
    rm -rf mcr-install

ENV LD_LIBRARY_PATH /opt/mcr/v94/runtime/glnxa64:/opt/mcr/v94/bin/glnxa64:/opt/mcr/v94/sys/os/glnxa64:/opt/mcr/v94/extern/bin/glnxa64


WORKDIR /PPR-Meta  
RUN chmod +x PPR_Meta
ENV PATH /PPR-Meta:$PATH