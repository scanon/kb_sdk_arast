FROM kbase/kbase:sdkbase.latest
MAINTAINER Fangfang Xia
# -----------------------------------------

# Insert apt-get instructions here to install
# any required dependencies for your module.

# RUN apt-get update

# -----------------------------------------
RUN apt-get update && \
    apt-get install -y cmake libffi-dev libssl-dev libboost-all-dev sparsehash rabbitmq-server mpich2 && \
    cpanm install Cwd && \
    cpanm install Data::Dumper && \
    cpanm install File::Basename && \
    cpanm install File::Copy && \
    cpanm install Getopt::Long && \
    pip install PrettyTable daemon lockfile cherrypy && \
    cpanm install  File::Spec::Link && \
    pip install --upgrade requests[security]

ADD ./tools /tmp/tools/

RUN \
    cd /kb/ && \
    git clone https://github.com/kbase/assembly.git && \
    cd assembly/tools && \
    ./add-comp.pl -d /kb/runtime/assembly regular && \
    rm -rf /mnt/tmp

RUN \
    apt-get install -y mongodb && \
    mkdir /db && \
    mongod --smallfiles --dbpath /db --logpath /tmp/mongo.log --fork && \
    sleep 5 && ps|grep mongo|awk '{print $1}'|xargs kill

# Install AssemblyRAST client

RUN \
    cd /kb/assembly && \
    git checkout next && \
    pip install yapsy && \
    make -f Makefile.standalone


# Copy local wrapper files, and build

COPY ./ /kb/module
RUN mkdir -p /kb/module/work

WORKDIR /kb/module

RUN make

ENTRYPOINT [ "./scripts/entrypoint.sh" ]

CMD [ ]
