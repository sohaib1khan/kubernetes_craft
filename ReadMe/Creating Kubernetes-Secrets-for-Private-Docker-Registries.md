# Creating Kubernetes Secrets for Private Docker Registries

If you're deploying containers from images stored in a private registry, Kubernetes will need authentication credentials to pull them. This guide demonstrates how to create a Kubernetes secret for this purpose.

## Prerequisites:

1.  Ensure `kubectl` is configured correctly and is able to communicate with your cluster.
2.  You should have a username and password to authenticate against your private registry.

```
kubectl create namespace NAMESPACE-NAME
```

### 2. Generate Base64 Encoded Credentials

Encode your registry username and password in Base64. This encoded value will be used in the secret.

echo -n 'YOUR-USERNAME:YOUR-PASSWORD' | base64 

```
echo -n 'YOUR-USERNAME:YOUR-PASSWORD' | base64
```

Copy the output as it will be used in the next step.

### 3. Generate Docker Configuration for Kubernetes

Using the encoded value from the previous step, generate a `.dockerconfigjson` value.

```
echo -n '{"auths": {"YOUR-REGISTRY-URL": {"auth": "YOUR-BASE64-ENCODED-VALUE"}}}' | base64
```

Copy this output, it will be used to create the secret.

### 4. Create a Kubernetes Secret

Using the encoded value from the previous step, create a Kubernetes secret YAML configuration. Name it `secrets.yaml` or include it in your deployment YAML.

```
apiVersion: v1
kind: Secret
metadata:
  name: my-regcred
  namespace: chatbot-namespace
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: YOUR-ENCODED-DOCKER-CONFIG-FROM-STEP-3
```

Replace `YOUR-ENCODED-DOCKER-CONFIG-FROM-STEP-3` with the value you obtained in step 3.

### 5. Apply the Secret to Your Cluster

Apply the secret to your cluster using `kubectl`.

```
kubectl apply -f secrets.yaml
```

### 6. Use the Secret in Your Deployment

Ensure your deployment's Pod specification references this secret for image pulls:

```
spec:
  containers:
  - name: your-container-name
    image: your-private-image
  imagePullSecrets:
  - name: my-regcred
```

If you're deploying containers from images stored in a private registry, Kubernetes will need authentication credentials to pull them. This guide demonstrates how to create a Kubernetes secret for this purpose.

1. Create a namespace on kubernetes where the image is going to be downloaded to 

2. create a file called secrets.yaml or something similar or add it an existing deployment file  and add the following code 

```
apiVersion: v1
kind: Secret
metadata:
  name: my-regcred
  namespace: chatbot-namespace
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: ENCODED-WILL-KEY-GO-HERE
```

3.  on the terminal, run the following command which will the username and password for your docker repo or whatever registry you are using 

```
echo -n 'YOUR-USERNAME:YOUR-PASSWORD' | base64
```

4. After the running commmand you will get an encoded values, take that value and instert into the following command 

```
echo -n '{"auths": {"registry.helixx.cloud": {"auth": "YOUR-COMBINED-ENCODED-VALUES-GOES-HERE"}}}' | base64
```

5. you will get another values which will need to be updated in the secrets.yaml file or if its included in the deployments file 

```
apiVersion: v1
kind: Secret
metadata:
  name: my-regcred
  namespace: chatbot-namespace
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: ENCODED-VALUE-OF-COMBINED-GOES-HERE
```