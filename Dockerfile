## Dependency
FROM hesamrad/crew:jdk17-alp3.21.2-mvn3.8.4 AS dependency_maven
LABEL MAINTAINER="hesam@crewmeister.com"
COPY pom.xml ./
COPY .mvn ./.mvn
RUN mvn -X -B dependency:resolve


## Building
FROM dependency_maven AS build_maven
COPY src ./src
RUN mvn -B clean package -DskipTests=true


## Run Jar
FROM hesamrad/crew:jdk17-alp3.21.2
WORKDIR /app

ENV JAVA_OPTS="\
    -XX:+UseContainerSupport \
    -XX:+ExitOnOutOfMemoryError \
    -Djava.security.egd=file:/dev/./urandom"

COPY --from=build_maven /target/crewmeisterchallenge-0.0.1-SNAPSHOT.jar run.jar
ENTRYPOINT ["/bin/sh", "-c", "exec java $JAVA_OPTS -jar ./run.jar"]


