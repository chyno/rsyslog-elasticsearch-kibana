FROM nathonfowlie/centos-jre

LABEL arcseldon <arcseldon@gmail.com>

#USER root
ARG ek_version=6.4.2

#RUN curl --silent --location https://rpm.nodesource.com/setup_6.x |   bash -
RUN  yum -y install wget
RUN  yum -y install which
RUN curl --silent --location https://rpm.nodesource.com/setup_8.x |  bash -
RUN  yum -y install nodejs
RUN npm install -g n
RUN n 8.11.4

#RUN apk add --quiet --no-progress --no-cache nodejs \
  
RUN useradd -d /home/elasticsearch  -m -s /bin/bash elasticsearch

  
WORKDIR /home/elasticsearch
RUN chmod 777 /home/elasticsearch
RUN chown -R elasticsearch /home/elasticsearch

RUN chgrp -R 0 /home/elasticsearch && chmod g+rwX /home/elasticsearch

WORKDIR /home/elasticsearch

ENV ES_TMPDIR=/home/elasticsearch/elasticsearch.tmp

RUN wget -q -O - https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-oss-${ek_version}.tar.gz \
 |  tar -zx \
 && mv elasticsearch-${ek_version} elasticsearch \
 && mkdir -p ${ES_TMPDIR} \
 && wget -q -O - https://artifacts.elastic.co/downloads/kibana/kibana-oss-${ek_version}-linux-x86_64.tar.gz \
 |  tar -zx \
 && mv kibana-${ek_version}-linux-x86_64 kibana \
 && rm -f kibana/node/bin/node kibana/node/bin/npm \
 && ln -s $(which node) kibana/node/bin/node \
 && ln -s $(which npm) kibana/node/bin/npm

RUN sed 's/#network.host: 192.168.0.1/network.host: 127.0.0.1/' /home/elasticsearch/elasticsearch/config/elasticsearch.yml > /home/elasticsearch/elasticsearch/config/elasticsearch.yml.changed \
&& mv /home/elasticsearch/elasticsearch/config/elasticsearch.yml.changed /home/elasticsearch/elasticsearch/config/elasticsearch.yml

USER elasticsearch
CMD sh elasticsearch/bin/elasticsearch  -E http.host=0.0.0.0 --verbose & kibana/bin/kibana --host 0.0.0.0 -Q

EXPOSE 9200 5601

