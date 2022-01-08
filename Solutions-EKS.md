</details>

******

<details>
<summary>Exercise 1: Create EKS cluster </summary>
 <br />

- First you need to install eksctl command line tool locally. See the installation guide here: https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html

**Steps**
```sh
# create cluster with 3 EC2 instances and store access configuration to cluster in kubeconfig.my-cluster.yaml file 
eksctl create cluster --name=my-cluster --nodes=3 --kubeconfig=./kubeconfig.my-cluster.yaml

# create fargate profile in the cluster. It will apply for all K8s components in my-app namespace
eksctl create fargateprofile \
    --cluster my-cluster \
    --name my-fargate-profile \
    --namespace my-app

# point kubectl to your cluster - use absolute path to kubeconfigfile
export KUBECONFIG={absolute-path}/kubeconfig.my-cluster.yaml

# validate cluster is accessible and nodes and fargate profile created
kubectl get node
eksctl get fargateprofile --cluster my-cluster

```

</details>

******

<details>
<summary>Exercise 2: Deploy Mysql and phpmyadmin </summary>
 <br />

**General notes**
- All the k8s manifest files for the exercise are in "k8s-deployment" folder, so:
```sh
# clone this repository locally
git clone git@gitlab.com:devops-bootcamp3/bootcamp-java-mysql.git

# check out the solutions branch
git checkout feature/solutions

# change to k8s-deployment folder
cd k8s-deployment

```

- Mysql Chart link: 
https://github.com/bitnami/charts/tree/master/bitnami/mysql 

```sh
# install Mysql chart 
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/mysql -f mysql-chart-values-eks.yaml --version 8.8.6
# Note that chart version version 8.8.8+ has a bug setting the db user password incorrectly, which affects EKS installation: https://giters.com/bitnami/charts/issues/8557, that's why we are installing an older version. 


# deploy phpmyadmin with its configuration for Mysql DB access
kubectl apply -f db-config.yaml
kubectl apply -f db-secret.yaml
kubectl apply -f phpmyadmin.yaml

# access phpmyadmin and login to mysql db
kubectl port forward svc/phpmyadmin-service 8081:8081

# access in browser on
localhost:8081

# login with one of these 2 credentials
"my-user" : "my-pass"
"root" : "secret-root-pass"

```

</details>

******

<details>
<summary>Exercise 3: Deploy your Java Application with 3 replicas </summary>
 <br />

**Steps**
```sh

# Create namespace my-app to deploy our java application, because we are deploying java-app with fargate profile. And fargate profile we create applies for my-app namespace. 
kubectl create namespace my-app

# We now have to create all configuration and secrets for our java app in the my-app namespace

# Create my-registry-key secret to pull image 
DOCKER_REGISTRY_SERVER=docker.io
DOCKER_USER=your dockerID, same as for `docker login`
DOCKER_EMAIL=your dockerhub email, same as for `docker login`
DOCKER_PASSWORD=your dockerhub pwd, same as for `docker login`

kubectl create secret -n my-app docker-registry my-registry-key \
--docker-server=$DOCKER_REGISTRY_SERVER \
--docker-username=$DOCKER_USER \
--docker-password=$DOCKER_PASSWORD \
--docker-email=$DOCKER_EMAIL


# Again from k8s-deployment folder, execute following commands. By adding the my-app namespace, these components will be created with Fargate profile
kubectl apply -f db-secret.yaml -n my-app
kubectl apply -f db-config.yaml -n my-app
kubectl apply -f java-app.yaml -n my-app

```

</details>

******

<details>
<summary>Exercise 4 & 5: Automate deployment & Use ECR as Docker repository </summary>
 <br />

**Current cluster setup**

At this point, you already have an EKS cluster, where: 
- Mysql chart is deployed and phpmyadmin is running too
- my-app namespace was created
- db-config and db-secret were created in the my-app namspace for the java-app
- my-registry-key secret was created to fetch image from docker-hub
- your java app is also running 

**Steps to automate deployment for existing setup**
```sh
# Create a docker registry secret for ECR
DOCKER_REGISTRY_SERVER=your ECR registry server
DOCKER_USER=your dockerID, same as for `docker login`
DOCKER_EMAIL=your dockerhub email, same as for `docker login`
DOCKER_PASSWORD=your dockerhub pwd, same as for `docker login`

kubectl create secret -n my-app docker-registry my-ecr-registry-key \
--docker-server=$DOCKER_REGISTRY_SERVER \
--docker-username=$DOCKER_USER \
--docker-password=$DOCKER_PASSWORD \
--docker-email=$DOCKER_EMAIL

# Create Jenkins pipeline using the Jenkinsfile in k8s-deployment folder

```

**Configure access credentials in Jenkins**

Before the pipeline can run, you will have to configure following in Jenkins:
- ECR credentials that Jenkins will use to push images
- AWS & K8s credentials that Jenkins will use to access the EKS cluster 

_You learn how to do this in the K8s on AWS module_

</details>

******

<details>
<summary>Exercise 6: Configure Autoscaling </summary>
 <br />

You learn how to scale the cluster up and down in the **_Kubernetes on AWS_** module, video **_3 - Configure Autoscaling in EKS cluster_**


