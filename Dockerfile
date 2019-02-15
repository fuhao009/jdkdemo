FROM frolvlad/alpine-java:jdk8-full AS builder
#FROM openjdk:8-jdk

ARG MAVEN_VERSION=3.6.0
ARG USER_HOME_DIR="/root"
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && apk add --no-cache curl bash  \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

COPY mvn-entrypoint.sh /usr/local/bin/mvn-entrypoint.sh
#RUN  sed -i '/<mirrors>/a\ <mirror>\n<id>goodrain-repo</id>\n<name>goodrain repo</name>\n<url>http://maven.goodrain.me</url>\n<mirrorOf>central</mirrorOf>\n</mirror>' ${MAVEN_HOME}/conf/settings.xml
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
