# Build stage
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# Runtime stage (Tomcat 10.1 / Jakarta EE 10)
FROM tomcat:10.1-jdk17-temurin
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080 10000
CMD sed -i "s/port=\"8080\"/port=\"${PORT:-8080}\"/g" conf/server.xml && catalina.sh run
