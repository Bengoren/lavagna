# Docker file for demo purposes

# Alpine - so download is fast
FROM maven:3.8.6-jdk-8

WORKDIR /lavagna
COPY ./project/pom.xml .

RUN mvn -B dependency:go-offline

COPY ./project /lavagna

RUN apt-get update && \
    apt-get install -y ca-certificates openssl netcat && \
    update-ca-certificates

RUN mvn -B clean package -DskipTests

EXPOSE 8080

COPY entry-point.sh /lavagna/entry-point.sh
RUN chmod +x /lavagna/entry-point.sh

ENTRYPOINT ["/lavagna/entry-point.sh"]