FROM java:8-jre

LABEL authors="Joost van der Griendt <joostvdg@gmail.com>"
LABEL version="0.1.0"
LABEL description="OpenDJ container"

WORKDIR /opt
EXPOSE 1389 1636 4444

ENV CHANGE_DATE='20181208-2100'
ENV TINI_VERSION v0.16.1 
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
ENV OPENDJ_JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
ENV VERSION=4.3.1
ENV ROOT_USER_DN='cn=admin'
ENV ROOT_PASSWORD='changeme'

ENTRYPOINT ["/tini", "-v","-g", "--"]
CMD ["/opt/opendj/bin/start-ds", "--nodetach"]

RUN wget --quiet \
    https://github.com/OpenIdentityPlatform/OpenDJ/releases/download/$VERSION/opendj-$VERSION.zip && \
    unzip opendj-$VERSION.zip && \
    rm -r opendj-$VERSION.zip

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

RUN /opt/opendj/setup --cli \
    -p 1389 \
    --ldapsPort 1636 \
    --enableStartTLS \
    --generateSelfSignedCertificate \
    --baseDN dc=example,dc=com \
    -h localhost \
    --rootUserDN "$ROOT_USER_DN" \
    --rootUserPassword "$ROOT_PASSWORD" \
    --acceptLicense \
    --no-prompt \
    --doNotStart

ADD Example.ldif /var/tmp/example.ldiff
# RUN /opt/opendj/bin/import-ldif --help
RUN /opt/opendj/bin/import-ldif --includeBranch dc=example,dc=com --backendID userRoot --offline --ldifFile /var/tmp/example.ldiff
