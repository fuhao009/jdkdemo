FROM frolvlad/alpine-java:jdk8-full AS builder

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && apk add --no-cache curl bash  \
  && curl -fsSL -o /tmp/apache-maven.tar.gz https://apache.osuosl.org/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz\
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "/root/.m2"

COPY mvn-entrypoint.sh /usr/local/bin/mvn-entrypoint.sh
COPY settings-docker.xml /usr/share/maven/ref/

#ENTRYPOINT ["/usr/local/bin/mvn-entrypoint.sh"]
#CMD ["mvn"]
RUN mkdir /app

COPY . /app/

WORKDIR /app

RUN mvn -B -DskipTests=true clean install

FROM frolvlad/alpine-java:jre8-full

RUN mkdir -p /app/target && \
    apk add --no-cache bash
WORKDIR /app

COPY --from=builder /app/target /app/target/

COPY run.sh /app/run.sh
#COPY --from=builder /app/run.sh /app/run.sh

EXPOSE 5000

ENTRYPOINT ["/app/run.sh"]
