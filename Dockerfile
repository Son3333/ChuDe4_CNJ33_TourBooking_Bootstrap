# Build stage
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
ENV MAVEN_OPTS="-Dfile.encoding=UTF-8"
RUN mvn clean package -DskipTests -Dfile.encoding=UTF-8

# Runtime stage (Tomcat 10.1 / Jakarta EE 10)
FROM tomcat:10.1-jdk17-temurin
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV JAVA_OPTS="-Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8"
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080 10000
CMD sed -i 's/<Server port="8005"/<Server port="-1"/' conf/server.xml && sed -i "s/port=\"8080\"/port=\"${PORT:-8080}\"/g" conf/server.xml && catalina.sh run
