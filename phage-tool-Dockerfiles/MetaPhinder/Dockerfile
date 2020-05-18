FROM ubuntu:bionic

RUN apt update && apt install -y procps python3 python-pip git ncbi-blast+ && \
    git clone https://github.com/vanessajurtz/MetaPhinder && \
    pip install -U numpy && \
    apt remove -y git python-pip && apt-get clean &&  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN chmod +x /MetaPhinder/MetaPhinder.py
ENV PATH /MetaPhinder:$PATH 