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

# point kubectl to your cluster
export KUBECONFIG=kubeconfig.my-cluster.yaml

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
helm install my-release bitnami/mysql -f mysql-chart-values-eks.yaml

# deploy phpmyadmin with its configuration for Mysql DB access
kubectl apply -f db-config.yaml
kubectl apply -f db-secret.yaml
kubectl apply -f phpmyadmin.yaml
```

</details>

******

<details>
<summary>Exercise 3: Deploy your Java Application with 3 replicas </summary>
 <br />

**Steps**
```sh
# Create my-registry-key secret to pull image
DOCKER_REGISTRY_SERVER=docker.io
DOCKER_USER=your dockerID, same as for `docker login`
DOCKER_EMAIL=your dockerhub email, same as for `docker login`
DOCKER_PASSWORD=your dockerhub pwd, same as for `docker login`

kubectl create secret docker-registry my-registry-key \
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
<summary>Exercise 4: XXXXXXX </summary>
 <br />

**Minikube & LKE**
```sh
kubectly apply -f phpmyadmin.yaml

```

</details>

******

<details>
<summary>Exercise 5: Deploy Ingress Controller </summary>
 <br />

**Minikube**
```sh
# minikube comes with ingress addon, so we just need to activate it
minikube addons enable ingress 

```

**LKE**
```sh
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx

```

**Notes on installing Ingress-controller on LKE**
- Chart link: https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx
- Known issue when pulling ingress-nginx images from k8s repository:
https://www.reddit.com/r/kubernetes/comments/rorzhd/nginx_ingress_unable_to_pull_official_images/

As a workaround, try a different region or just use Minikube

</details>

******

<details>
<summary>Exercise 6: Create Ingress rule </summary>
 <br />

**Minikube**

- set the host name in java-app-ingress.yaml line 6 to my-java-app.com
- get minikube ip address with command `minikube ip`, example: 192.168.64.27
- add `192.168.64.27 my-java-app.com` in /etc/hosts file
- create ingress component: `kubectl apply -f java-app-ingress.yaml`
- access application from browser on address: `my-java-app.com`

**LKE**
- set the host name in java-app-ingress.yaml line 6 to Linode node-balancer address
- create ingress component: `kubectl apply -f java-app-ingress.yaml`
- access application from browser on Linode node-balancer address

</details>

******

<details>
<summary>Exercise 7: Port-forward for phpmyadmin </summary>
 <br />

**Minikube & LKE**
```sh
kubectl port-forward svc/phpmyadmin-service 8081:8081

```

</details>

******

<details>
<summary>Exercise 8: Create Helm Chart for Java App </summary>
 <br />

**Steps**

- create helm chart boilerplate for your application with chart-name `java-app` using command: `helm create java-app`

***Note**: This will generate `java-app` folder with chart files*

- clean up all unneeded contents from `java-app` folder, as you learned in the module
- create template files for `db-config.yaml`, `db-secret.yaml`, `java-app-deployment.yaml`, `java-app-ingress.yaml`, `java-app-service.yaml`
- create `values-override.yaml` and set all the correct values there 
- set default chart values in `values.yaml` file

<br>

:exclamation: **Check the final version of chart files in `java-app` folder in this `feature/solutions` branch**

<br>

***Note**: the `ingress.hostName` must be set to `my-java-app.com` for Minikube & Linode node balancer address*

- validate that your chart is correct and debug any issues, do a dry-run

`helm install my-cool-java-app java-app -f java-app/values-deploy.yaml --dry-run --debug`

- if dry-run shows the k8s manifest files with correct values, everything is working, so you can create the chart release

`helm install my-cool-java-app java-app -f java-app/values-deploy.yaml` 

- extract the chart `java-app` folder and host into its own new git repository `java-app-chart` 

</details>


