# Pi-hole Gravity Update CronJob for Kubernetes

This README provides step-by-step instructions for deploying a `CronJob` on Kubernetes that updates Pi-hole's gravity (the blocklist) and sends a notification using Gotify upon completion.

## Overview

The `CronJob` is designed to:

1.  Identify the running Pi-hole pod in the `pihole` namespace.
2.  Execute the Pi-hole gravity update command within the identified pod.
3.  Send a success or failure notification to Gotify.

## Prerequisites

Before deploying the `CronJob`, ensure the following:

- You have a running Pi-hole instance deployed within the `pihole` namespace in your Kubernetes cluster.
- `kubectl` is set up and authenticated to communicate with your cluster.
- You have a Gotify server set up and a token available for sending messages.

## Deployment Steps

- **Clone the repository**:

If you're storing the `CronJob` definition in a git repository, clone it:

```
git clone [REPOSITORY_URL]
cd [REPOSITORY_DIRECTORY]
```

- **Update Gotify Details**:
    
    Open the `CronJob` YAML file and replace `GOTIFY-URL` with your Gotify server URL and `TOKEN` with your Gotify application token.
    
- **Deploy the `CronJob`**:
    
    Apply the `CronJob` configuration to your cluster:
    

```
kubectl apply -f [FILENAME].yaml
```

**Monitor the `CronJob`**:

Use the following command to monitor the job's execution:

```
kubectl get cronjobs.batch -n pihole
```

## Breakdown

- **Cron Schedule**: The `CronJob` runs every day at 8:00 PM.
    
- **Pod Execution**: The script first identifies the Pi-hole pod by querying pods with the label `app=pihole` in the `pihole` namespace. It then uses `kubectl exec` to run the gravity update command within the pod.
    
- **Notification**: After updating the gravity, a curl command sends a message to Gotify. If the gravity update is successful, a success message is sent. Otherwise, a failure message is sent.
    

## Conclusion

This `CronJob` is an automated way to keep your Pi-hole blocklist updated while being informed of its status. Make sure to periodically check the logs and Gotify messages to ensure everything is running as expected.