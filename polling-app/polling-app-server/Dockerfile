#### Stage 1: Build the application
FROM maven:3.3-jdk-8 as build

# Set the current working directory inside the image
WORKDIR /app

# Copy maven executable to the image
COPY /polling-app-server/mvnw .
COPY /polling-app-server/.mvn .mvn

# Copy the pom.xml file
COPY /polling-app-server/pom.xml .

# Build all the dependencies in preparation to go offline. 
# This is a separate step so the dependencies will be cached unless 
# the pom.xml file has changed.
RUN mvn -B dependency:go-offline

# Copy the project source
COPY /polling-app-server/src src

# Package the application
RUN mvn package -Dmaven.test.skip=true
RUN mkdir -p target/dependency && (cd target/dependency; jar -xf ../*.jar)

#### Stage 2: A minimal docker image with command to run the app 
FROM openjdk:8-jre-alpine

ARG DEPENDENCY=/app/target/dependency

# Copy project dependencies from the build stage
COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app

EXPOSE 8081

ENTRYPOINT ["java","-cp","app:app/lib/*","com.example.polls.PollsApplication"]