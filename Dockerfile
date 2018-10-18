FROM nathonfowlie/centos-jre

LABEL arcseldon <arcseldon@gmail.com>

USER root
ENV ES_VERSION=2.3.5 \
    KIBANA_VERSION=4.5.3
RUN curl --silent --location https://rpm.nodesource.com/setup_6.x |   bash -
#RUN curl --silent --location https://rpm.nodesource.com/setup_10.x |  bash -
RUN  yum -y install nodejs
RUN  yum -y install wget
RUN  yum -y install which
#RUN apk add --quiet --no-progress --no-cache nodejs \
  
#RUN adduser  elasticsearch

USER root
  
WORKDIR /home/elasticsearch
RUN chgrp -R 0 /home/elasticsearch && chmod g+rwX /home/elasticsearch

RUN wget -q -O - http://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/${ES_VERSION}/elasticsearch-${ES_VERSION}.tar.gz \
 |  tar -zx \
 && mv elasticsearch-${ES_VERSION} elasticsearch \
 && wget -q -O - http://download.elastic.co/kibana/kibana/kibana-${KIBANA_VERSION}-linux-x64.tar.gz \
 |  tar -zx \
 && mv kibana-${KIBANA_VERSION}-linux-x64 kibana \
 && rm -f kibana/node/bin/node kibana/node/bin/npm \
 && ln -s $(which node) kibana/node/bin/node \
 && ln -s $(which npm) kibana/node/bin/npm \
 && ./elasticsearch/bin/plugin install license \
 && ./elasticsearch/bin/plugin install marvel-agent \ 
 && ./kibana/bin/kibana plugin --install elasticsearch/marvel/latest \ 
 && ./kibana/bin/kibana plugin --install elastic/sense 

ENV ES_JAVA_OPTS "-Xms1000m -Xmx1000m"

CMD elasticsearch/bin/elasticsearch --es.logger.level=OFF --network.host=0.0.0.0 & kibana/bin/kibana -Q

EXPOSE 9200 5601
