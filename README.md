#### This project is for the Devops bootcamp exercise for 
- "Containers - Docker" 
- "Container Orchestration - K8s"
- "Monitoring - Prometheus" 

# Solution
Start mysql container using docker

    docker run -p 3306:3306 \
    -e MYSQL_ROOT_PASSWORD=rootpass \
    -e MYSQL_DATABASE=team-member-projects \
    -e MYSQL_USER=admin \
    -e MYSQL_PASSWORD=adminpass \
    -d mysql mysqld --default-authentication-plugin=mysql_native_password

Alternatively start with docker-compose

    docker-compose -f docker-compose.yaml up

Create java jar file 

    ./gradlew build

Set env vars in Terminal and start the app from jar file

    [\W (master)]$ export DB_USER=admin
    [\W (master)]$ export DB_PWD=adminpass
    [\W (master)]$ export DB_SERVER=localhost
    [\W (master)]$ export DB_NAME=team-member-projects
    [\W (master)]$ java -jar build/libs/bootcamp-java-mysql-project-1.0-SNAPSHOT.jar

NOTE: this won't work if you set the env vars in terminal and then start the app in IntelliJ or start jar file from another terminal session 

# Alternative solution
Replace the hard-coded values in docker-compose with env vars

    MYSQL_DATABASE: ${DB_NAME}

Export env vars as shown above

    export DB_NAME=team-member-projects

Start docker-compose file in the same terminal session where you set env vars

    docker-compose -f docker-compose.yaml up --detach

NOTE: You can also start docker container with env var values

    docker run -p 3306:3306 \
    -e MYSQL_ROOT_PASSWORD=${ROOT_PWD} \
    -e MYSQL_DATABASE=${DB_NAME} \
    -e MYSQL_USER=${DB_USER} \
    -e MYSQL_PASSWORD=${DB_PWD} \
    -d mysql

Build and start jar file (In the same terminal session where you set the env vars)

    ./gradlew build
    java -jar build/libs/bootcamp-java-mysql-project-1.0-SNAPSHOT.jar


NOTE: some useful commands to check exactly which version of app, IP etc

    docker inspect 43594379ced9 | grep -i ipaddress
    docker inspect 43594379ced9 | grep -i image 
    docker inspect 43594379ced9 | grep -i version


Debugging: Mysql authentication problem

    mysql v8.x uses `caching_sha2_password` as the default authentication plugin instead of `mysql_native_password`. 
    However, many mysql drivers haven't added support for `caching_sha2_password` yet. 
    So we fix that by setting the old authentication plugin when we start the container.
