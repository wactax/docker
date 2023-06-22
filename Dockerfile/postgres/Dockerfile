FROM postgres:16beta1-alpine3.18 AS pg

ENV PG_BACKREST_VERSION=2.45

RUN apk update && apk add curl

#RUN sed -i "s#http://dl-cdn.alpinelinux.org#$(curl -sL https://mirrors.tuna.tsinghua.edu.cn/alpine/MIRRORS.txt | awk '/^http/{print $1}' | xargs -P 100 -I {} sh -c 'echo `curl --max-time 3 --connect-timeout 2 -s -w "%{time_connect}\n" -o /dev/null -m 5 {}` {}' | grep -v "0\.0000" | sort -n | head -1 | awk '{print $2}')#g" /etc/apk/repositories 

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
  && apk update && apk add llvm15 clang15 && apk add gcc g++ wget pkgconf dpkg-dev pcre-dev \
  openssl-dev zlib-dev icu-dev readline-dev libxslt-dev \
  libxml2-dev zstd-dev lz4-dev\
  bzip2-dev zlib-dev libuuid linux-headers \
  tzdata yaml-dev util-linux-dev make musl-dev \
  llvm git bash python3 py3-pip icu libxml2 zstd \
  shadow su-exec

COPY plugin /plugin

RUN /plugin/md5hash/build.sh
RUN /plugin/moreint.sh
#RUN cd /plugin/pg_cron && make && make install

RUN cd /tmp &&\
    wget https://ghproxy.com/https://github.com/pgbackrest/pgbackrest/archive/release/$PG_BACKREST_VERSION.tar.gz 

RUN \
  # download pgbackrest
  cd /tmp && \
  tar xf $PG_BACKREST_VERSION.tar.gz && \
  rm $PG_BACKREST_VERSION.tar.gz && \
  # install pgbackrest
  cd /tmp/pgbackrest-release-$PG_BACKREST_VERSION/src && \
  ./configure --with-zstd && make && cp pgbackrest /usr/bin/ && \
  rm -r /tmp/pgbackrest-release-$PG_BACKREST_VERSION

FROM postgres:16beta1-alpine3.18

RUN apk add --no-cache zstd-dev bzip2-dev

ENV PGPORT=9997
ENV LANG=en_US.utf8
ENV PGUSER=postgres
ENV PGDATA=/var/lib/postgresql/data
ENV PGUSER_UID=70
ENV PGUSER_GID=70

COPY ./pgbackrest.sh /pgbackrest.sh
COPY ./docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /pgbackrest.sh /docker-entrypoint.sh

COPY --from=pg /usr/bin/pgbackrest /usr/bin/pgbackrest
COPY --from=pg /usr/local/lib/postgresql /usr/local/lib/postgresql
COPY --from=pg /usr/local/share/postgresql/extension /usr/local/share/postgresql/extension

STOPSIGNAL SIGINT

# start database service
ENV PATH=/usr/local/pgsql/bin:$PATH
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["postgres"]
