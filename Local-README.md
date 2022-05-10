#### This project is for the Devops bootcamp exercise for 
#### "Containers - Docker" 


### create jar file - bootcamp-java-mysql-project-1.0-SNAPSHOT.jar

    ./gradlew build

### create docker image - java-app:1.0-SNAPSHOT

    docker build -t java-app:1.0-SNAPSHOT .

### start the application

    docker-compose -f docker-compose-full.yaml up

### debugging note:
The index.html must be in one of the following directories in order to be packaged in a jar:
    ["classpath:/META-INF/resources/", "classpath:/resources/", "classpath:/static/", "classpath:/public/", "/"]    

Webapp directory will be silently ignored. So don't use that when building a jar, only works for war.      
Reference: https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#boot-features-spring-mvc-static-content
