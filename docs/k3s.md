### [◀](README.md)

# Orchestrating containers

[![K8s](https://d33wubrfki0l68.cloudfront.net/26a177ede4d7b032362289c6fccd448fc4a91174/eb693/images/docs/container_evolution.svg)](https://d33wubrfki0l68.cloudfront.net/26a177ede4d7b032362289c6fccd448fc4a91174/eb693/images/docs/container_evolution.svg)

 [From Kuberntes overview](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/) - ``` "Containers are a good way to bundle and run your applications. In a production environment, you need to manage the containers that run the applications and ensure that there is no downtime. For example, if a container goes down, another container needs to start. Wouldn’t it be easier if this behavior was handled by a system?" ```

Let's now put our hands on how Kubernetes can help in managing containers.

## Setup of a local instance

In this hands-on we will use [K3s](https://k3s.io) for a quick start on your machine but there are plenty of similar solution that you can choose, later below you can find references for some of them.

To install it, just execute:
```bash
curl -sfL https://get.k3s.io | sh -
```

And the verify that the cluster is up and running with:

```bash
sudo kubectl get nodes
```

## Kubernetes fundamentals

[From Kubernetes docs](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/) - "Kubernetes Objects are persistent entities in the Kubernetes system. Kubernetes uses these entities to represent the state of your cluster. Specifically, they can describe:

- What containerized applications are running (and on which nodes)
- The resources available to those applications
- The policies around how those applications behave, such as restart policies, upgrades, and fault-tolerance

A Kubernetes object is a “record of intent”–once you create the object, the Kubernetes system will constantly work to ensure that object exists. By creating an object, you’re effectively telling the Kubernetes system what you want your cluster’s workload to look like; this is your cluster’s desired state.

To work with Kubernetes objects–whether to create, modify, or delete them–you’ll need to use the Kubernetes API. When you use the kubectl command-line interface, for example, the CLI makes the necessary Kubernetes API calls for you. You can also use the Kubernetes API directly in your own programs using one of the Client Libraries."

In this hands-on we will quickly walk through two main objects: Pods and Services.
We will use, with some adaptations, [Kubernetes by example](http://kubernetesbyexample.com/) material, where you can find many other examples for different objects and use cases.

## Pods

"A pod is a collection of containers sharing a network and mount namespace and is the basic unit of deployment in Kubernetes. All containers in a pod are scheduled on the same node."

TODO: fai deploy di container testato con Davide


## Services

TODO: esponi container testato con Davide



## Homeworks



## Other references

- https://kubernetes.io/docs/tasks/tools/install-minikube/
- https://github.com/kubernetes-sigs/kind


- https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/
- http://kubernetesbyexample.com/


