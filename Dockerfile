FROM openjdk:8-jdk-alpine
EXPOSE 8080
RUN mkdir /opt/app
COPY build/libs/bootcamp-java-mysql-project-1.0-SNAPSHOT.jar /opt/app
CMD ["java", "-jar", "/opt/app/bootcamp-java-mysql-project-1.0-SNAPSHOT.jar"]