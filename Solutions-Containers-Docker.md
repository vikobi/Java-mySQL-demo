</details>

******

<details>
<summary>Exercise 0: Clone project and create own Git repository </summary>
 <br />

**steps:**

```sh
# clone repository & change into project dir
git clone git@gitlab.com:devops-bootcamp3/bootcamp-java-mysql.git
cd bootcamp-java-mysql

# remove remote repo reference and create your own local repository
rm -rf .git
git init 
git add .
git commit -m "initial commit"

# create git repository on Gitlab and push your newly created local repository to it
git remote add origin git@gitlab.com:{gitlab-user}/{gitlab-repo}.git
git push -u origin master

# you can find the environment variables defined in src/main/java/com/example/DatabaseConfig.java file

```

</details>

******

<details>
<summary>Exercise 1: Start Mysql container </summary>
 <br />

**steps**

```sh
# start mysql container using docker
docker run -p 3306:3306 \
--name mysql \
-e MYSQL_ROOT_PASSWORD=rootpass \
-e MYSQL_DATABASE=team-member-projects \
-e MYSQL_USER=admin \
-e MYSQL_PASSWORD=adminpass \
-d mysql mysqld --default-authentication-plugin=mysql_native_password

# create java jar file
./gradlew build

# set env vars in Terminal for the java application (these will read in DatabaseConfig.java)
export DB_USER=admin
export DB_PWD=adminpass
export DB_SERVER=localhost
export DB_NAME=team-member-projects

# start java application
java -jar build/libs/bootcamp-java-mysql-project-1.0-SNAPSHOT.jar

```

</details>

******

<details>
<summary>Exercise 2: Start Mysql GUI container </summary>
 <br />

**steps**
```sh
# start phpmyadmin container using the official image
docker run -p 8083:80 \
--name phpmyadmin \
--link mysql:db \
-d phpmyadmin/phpmyadmin

# access it in the browser on
localhost:8083

# login to phpmyadmin UI with either of 2 mysql user credentials:
* admin:adminpass
* root:rootpass

```

</details>

******

<details>
<summary>Exercise 3: Use docker-compose for Mysql and Phpmyadmin </summary>
 <br />

**docker-compose.yaml**
```sh
version: '3'
services:
  mysql:
    image: mysql
    ports:
      - 3306:3306
    environment:
      - MYSQL_ROOT_PASSWORD=rootpass
      - MYSQL_DATABASE=team-member-projects
      - MYSQL_USER=admin    
      - MYSQL_PASSWORD=adminpass
    volumes:
    - mysql-data:/var/lib/mysql
    container_name: mysql
    command: --default-authentication-plugin=mysql_native_password
  phpmyadmin:
    image: phpmyadmin
    environment:
      - PMA_HOST=mysql
    ports:
      - 8083:80
    container_name: phpmyadmin
volumes:
  mysql-data:
    driver: local

```

**Start containers with docker-compose**
```sh
docker-compose -f docker-compose.yaml up    
```

</details>

******

<details>
<summary>Exercise 4: Dockerize your Java Application </summary>
 <br />

**Dockerfile**
```sh
FROM openjdk:8-jdk-alpine
EXPOSE 8080
RUN mkdir /opt/app
COPY build/libs/bootcamp-java-mysql-project-1.0-SNAPSHOT.jar /opt/app
WORKDIR /opt/app
CMD ["java", "-jar", "bootcamp-java-mysql-project-1.0-SNAPSHOT.jar"]

```

</details>

******

<details>
<summary>Exercise 5: Build and push Java Application Docker Image </summary>
 <br />

**steps:**
```sh
# create jar file - bootcamp-java-mysql-project-1.0-SNAPSHOT.jar
./gradlew build

# create docker image - {repo-name}/{image-name}:{image-tag}
docker build -t {repo-name}/java-app:1.0-SNAPSHOT .

# push docker to remote docker repo {repo-name}
docker push {repo-name}/java-app:1.0-SNAPSHOT

```

</details>

******

<details>
<summary>Exercise 6: Add application to docker-compose </summary>
 <br />

**docker-compose-with-app.yaml**
```sh
version: '3'
services:
  my-java-app:
    image: java-mysql-app:1.0 # specify the full image name with repository name
    environment:
      - DB_USER=${DB_USER}
      - DB_PWD=${DB_PWD}
      - DB_SERVER=${DB_SERVER}
      - DB_NAME=${DB_NAME}
    ports:
    - 8080:8080
    container_name: my-java-app
    depends_on:
      - mysql
  mysql:
    image: mysql
    ports:
      - 3306:3306
    environment:
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
      - MYSQL_DATABASE=${DB_NAME}
      - MYSQL_USER=${DB_USER}
      - MYSQL_PASSWORD=${DB_PWD}
    volumes:
    - mysql-data:/var/lib/mysql
    container_name: mysql
    command: --default-authentication-plugin=mysql_native_password
  phpmyadmin:
    image: phpmyadmin
    ports:
      - 8083:80
    environment:
      - PMA_HOST=${PMA_HOST}
      - PMA_PORT=${PMA_PORT}
      - MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
    container_name: phpmyadmin
    depends_on:
      - mysql
volumes:
  mysql-data:
    driver: local

```

**docker-compose-with-app.yaml**
```sh
# set all needed environment variables
export DB_USER=admin
export DB_PWD=adminpass
export DB_SERVER=localhost
export DB_NAME=team-member-projects

export MYSQL_ROOT_PASSWORD=rootpass

export PMA_HOST=mysql
export PMA_PORT=3306

# start all 3 containers 
docker-compose -f docker-compose.yaml up    
```

</details>

******

<details>
<summary>Exercise 7: Run application on server with docker-compose </summary>
 <br />

**Dockerfile**
```sh
# on Linux server - to add an insecure docker registry, add the file /etc/docker/daemon.json with the following content
{
  "insecure-registries" : [ "{repo-address}:{repo-port}" ]
}

# restart docker for the configuration to take affect
sudo service docker restart

# check the insecure repository was added - last section "Insecure Registries:"
docker info

# do docker login to repo
docker login {repo-address}:{repo-port}

# change hardcoded HOST env var in src/main/resources/static/index.html file, line 48
const HOST = "{server-ip-address}";

# rebuild the application and image and push to repo
./gradlew build
docker build -t {repo-name}/java-app:1.0-SNAPSHOT .
docker push {repo-name}/java-app:1.0-SNAPSHOT 

# copy docker-compose file to remote server
scp -i ~/.ssh/id_rsa docker-compose.yaml {server-user}:{server-ip}:/home/{server-user}

# ssh into the remote server
# set all env vars as you did in exercise 6
# run docker compose file
# open port 8080 on server to access java application

```

</details>



