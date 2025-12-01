FROM maven:3.8.6-jdk-8 AS builder

WORKDIR /lavagna
COPY ./project/pom.xml .

RUN mvn -B dependency:go-offline

COPY ./project /lavagna

RUN apt-get update && \
    apt-get install -y ca-certificates openssl netcat && \
    update-ca-certificates

RUN mvn -B clean package -DskipTests

FROM eclipse-temurin:8-jre-alpine
WORKDIR /lavagna
COPY --from=builder /lavagna/target/lavagna-*.war /lavagna/lavagna.war
COPY  entry-point.sh /lavagna/entry-point.sh
RUN chmod +x /lavagna/entry-point.sh
EXPOSE 8080
ENTRYPOINT ["/lavagna/entry-point.sh"]
