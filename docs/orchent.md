### [◀](README.md)

# Introduction to cloud platforms

When working with cloud resources, depending on the user needs, different layers of underlyng abstraction can be needed, and depending on how many layers and their composition one can define different categories.

[![PaaS](img/platform-spectrum-small.png)](https://dodas-ts.github.io/SOSC-2019/img/platform-spectrum-small.png)

This part of the hands-on will focus on PaaS, for other "as a Service", take a look at this interesting post [here](https://mesosphere.com/blog/iaas-vs-caas-vs-paas-vs-faas/) from which, for this page, pictures and description credits are.

## Platform as a Service on top of Infrastracture as a Service

[![PaaS](img/PaaS-IaaS.png)](https://dodas-ts.github.io/SOSC-2019/img/PaaS-IaaS.png)

Infrastructure as a service (IaaS)  is __a cloud computing offering in which a vendor provides users access to computing resources such as servers__, storage and networking. Organizations use their own platforms and applications within a service provider’s infrastructure.

Key features:

- Instead of purchasing hardware outright, users pay for IaaS on demand.
- Infrastructure is scalable depending on processing and storage needs.
- Saves enterprises the costs of buying and maintaining their own hardware.
- Because data is on the cloud, there can be no single point of failure.
- Enables the virtualization of administrative tasks, freeing up time for other work.

Platform as a service (PaaS) is __a cloud computing offering that provides users with a cloud environment in which they can develop, manage and deliver applications.__ In addition to storage and other computing resources, users are able to use a suite of prebuilt tools to develop, customize and test their own applications.

Key features:

- SaaS vendors provide users with software and applications via a subscription model.
- Users do not have to manage, install or upgrade software; SaaS providers manage this.
- Data is secure in the cloud; equipment failure does not result in loss of data.
- Use of resources can be scaled depending on service needs.
- Applications are accessible from almost any internet-connected device, from virtually anywhere in the world.

__In this hands-on a webserver will be deployed on cloud resources in an automated way thanks the use of a PaaS orchestrator and TOSCA system description files.__

## INDIGO-DC PaaS orchestrator

[![tosca](img/sosc-indigo.png)](https://dodas-ts.github.io/SOSC-2019/img/sosc-indigo.png)

[The INDIGO PaaS Orchestrator](https://github.com/indigo-dc/orchestrator) allows to instantiate resources on Cloud Management Frameworks (like OpenStack and OpenNebula) platforms based on deployment requests that are expressed through templates written in [TOSCA YAML Simple Profile v1.0](https://docs.oasis-open.org/tosca/TOSCA-Simple-Profile-YAML/v1.0/csprd01/TOSCA-Simple-Profile-YAML-v1.0-csprd01.html), and deploys them on the best cloud site available.

### Install orchent client

The requirement here is `golang` installation that can you find [here](https://golang.org/doc/install)

```bash
go get github.com/indigo-dc/orchent
go install github.com/indigo-dc/orchent
```

### Retrieve IAM token

``` bash
./scripts/get_orchent_token.sh
```

You'll be prompted with username and password requests. Just insert the one corresponding to you Indigo-IAM account.

The output of the command should be something like

``` text
Orchent access token has to be set with the following:
 export ORCHENT_TOKEN="eyJraWQiOiJyc......."
```

Copy and paste the export command to source the correct environement along with this:

``` bash
export ORCHENT_URL=https://orchestrator.cloud.cnaf.infn.it/orchestrator
```

### Using TOSCA

[![tosca](img/tosca.png)](https://dodas-ts.github.io/SOSC-2019/img/tosca.png)

The TOSCA metamodel uses the concept of __service templates to describe cloud workloads as a topology template__, which is a graph of node templates modeling the components a workload is made up of and as relationship templates modeling the relations between those components. TOSCA further provides a type __system of node types to describe the possible building blocks for constructing a service template__, as well as relationship type to describe possible kinds of relations. Both node and relationship types may define lifecycle operations to implement the behavior an orchestration engine can invoke when instantiating a service template. For example, a node type for some software product might provide a ‘create’ operation to handle the creation of an instance of a component at runtime, or a ‘start’ or ‘stop’ operation to handle a start or stop event triggered by an orchestration engine. Those lifecycle operations are backed by implementation artifacts such as scripts or Chef recipes that implement the actual behavior.

The TOSCA simple profile assumes a number of base types (node types and relationship types) to be supported by each compliant environment such as a ‘Compute’ node type, a ‘Network’ node type or a generic ‘Database’ node type. Furthermore, it is envisioned that a large number of __additional types for use in service templates will be defined by a community over time__. Therefore, template authors in many cases will not have to define types themselves but can __simply start writing service templates that use existing types__. In addition, the simple profile will provide means for easily customizing and extending existing types, for example by providing a customized ‘create’ script for some software.

### Deploy webserver on the cloud: TOSCA types

Tosca types are the building blocks needed to indicate the correct procedure for the vm creation and software deployment.

During this hands on the following types are used:

``` yaml
tosca_definitions_version: tosca_simple_yaml_1_0

capability_types:

  tosca.capabilities.indigo.OperatingSystem:
    derived_from: tosca.capabilities.OperatingSystem
    properties:
      gpu_driver:
        type: boolean
        required: no
      cuda_support:
        type: boolean
        required: no
      cuda_min_version:
        type: string
        required: no
      image:
        type: string
        required: no
      credential:
        type: tosca.datatypes.Credential
        required: no

  tosca.capabilities.indigo.Scalable:
    derived_from: tosca.capabilities.Scalable
    properties:
      min_instances:
        type: integer
        default: 1
        required: no
      max_instances:
        type: integer
        default: 1
        required: no
      count:
        type: integer
        description: the number of resources
        required: no
        default: 1
      removal_list:
        type: list
        description: list of IDs of the resources to be removed
        required: no
        entry_schema:
          type: string

  tosca.capabilities.indigo.Container:
    derived_from: tosca.capabilities.Container
    properties:
      instance_type:
        type: string
        required: no
      num_gpus:
        type: integer
        required: false
      gpu_vendor:
        type: string
        required: false
      gpu_model:
        type: string
        required: false  


  tosca.capabilities.indigo.Endpoint:
    derived_from: tosca.capabilities.Endpoint
    properties:
      dns_name:
        description: The optional name to register with DNS
        type: string
        required: false
      private_ip:
        description: Flag used to specify that this endpoint will require also a private IP although it is a public one.
        type: boolean
        required: false
        default: true
    attributes:
      credential:
        type: list
        entry_schema:
          type: tosca.datatypes.Credential


artifact_types:

  tosca.artifacts.Implementation.YAML:
    derived_from: tosca.artifacts.Implementation
    description: YAML Ansible recipe artifact
    mime_type: text/yaml
    file_ext: [ yaml, yml ]

  tosca.artifacts.AnsibleGalaxy.role:
    derived_from: tosca.artifacts.Root
    description: Ansible Galaxy role to be deployed in the target node

relationship_types:

  tosca.relationships.indigo.Manages:
    derived_from: tosca.relationships.Root

node_types:

  tosca.nodes.WebServer.Apache:
    derived_from: tosca.nodes.WebServer
    interfaces:
      Standard:
        create:
          implementation:  https://raw.githubusercontent.com/DODAS-TS/SOSC-2019/master/templates/hands-on-1/ansible-role-install.yml
        start:
          implementation:  https://raw.githubusercontent.com/DODAS-TS/SOSC-2019/master/templates/hands-on-1/ansible-role-apache.yml

  tosca.nodes.indigo.Compute:
    derived_from: tosca.nodes.indigo.MonitoredCompute
    attributes:
      private_address:
        type: list
        entry_schema:
          type: string
      public_address:
        type: list
        entry_schema:
          type: string
      ctxt_log:
        type: string
    capabilities:
      scalable:
        type: tosca.capabilities.indigo.Scalable
      os:
         type: tosca.capabilities.indigo.OperatingSystem
      endpoint:
        type: tosca.capabilities.indigo.Endpoint
      host:
        type: tosca.capabilities.indigo.Container
        valid_source_types: [tosca.nodes.SoftwareComponent]

  tosca.nodes.indigo.MonitoredCompute:
    derived_from: tosca.nodes.Compute
    properties:
      # Set the current data of the zabbix server
      # but it can also specified in the TOSCA document
      zabbix_server:
        type: string
        required: no
        default: orchestrator.cloud.cnaf.infn.it
      zabbix_server_port:
        type: tosca.datatypes.network.PortDef
        required: no
        default: 10051
      zabbix_server_metadata:
        type: string
        required: no
        default: Linux      668c875e-9a39-4dc0-a710-17c41376c1e0
    artifacts:
      zabbix_agent_role:
        file: indigo-dc.zabbix-agent
        type: tosca.artifacts.AnsibleGalaxy.role
    interfaces:
      Standard:
        configure:
          implementation: https://raw.githubusercontent.com/indigo-dc/tosca-types/master/artifacts/zabbix/zabbix_agent_install.yml
          inputs:
            zabbix_server: { get_property: [ SELF, zabbix_server ] }
            zabbix_server_port: { get_property: [ SELF, zabbix_server_port ] }
            zabbix_server_metadata: { get_property: [ SELF, zabbix_server_metadata ] }
```

### Deploy command with deployment template

The deployment template makes use of the TOSCA types defined above to create and orchestrate the deployment on the cloud resources.

``` yaml
tosca_definitions_version: tosca_simple_yaml_1_0

imports:
  - indigo_custom_types:  https://raw.githubusercontent.com/DODAS-TS/SOSC-2019/master/templates/common/types.yml

description: TOSCA template for a complete CMS Site over Mesos orchestrator

topology_template:

  inputs:

    input test:
      type: string 
      default: "test"
 
  node_templates:

    create-server-vm:
      type: tosca.nodes.indigo.Compute
      capabilities:
        endpoint:
          properties:
            network_name: PUBLIC
            dns_name: apachepublic
            ports:
              apache_port:
                protocol: tcp
                source: 4880
        scalable:
          properties:
            count: 1 
        host:
          properties:
            num_cpus: 2
            mem_size: "2 GB"
        os:
          properties:
            image: "ost://cloud.recas.ba.infn.it/1113d7e8-fc5d-43b9-8d26-61906d89d479"

    apache_install:
      type: tosca.nodes.WebServer.Apache
      requirements:
        - host: create-server-vm

  outputs:
    vm_ip:
      value: { concat: [ get_attribute: [ create-server-vm, public_address, 0 ] ] }
    cluster_credentials:
      value: { get_attribute: [ create-server-vm, endpoint, credential, 0 ] }
```

To start the deployment:

``` bash
orchent depcreate  templates/hands-on-1/Handson-Part1.yaml '{}'
```

the expected output is something like:

``` text
retrieving deployment list:
  page: 0/1 [ #Elements: 1, size: 10 ]
  links:
    self [https://orchestrator.cloud.cnaf.infn.it/orchestrator/deployments?createdBy=me]


Deployment [28dc62e6-facc-4f70-bc14-4a32e1149c94]:
  status: CREATE_IN_PROGRESS
  creation time: 2019-09-05T12:47+0000
  update time: 2019-09-05T12:47+0000
  callback:
```

### Monitor the deployment process

``` bash
orchent depls --created_by=me
```

get your deployment ID then check for:

``` bash
orchent depshow <deployment ID>
```

when the deployment is completed, the output should look like: 

``` text
Deployment [28dc62e6-facc-4f70-bc14-4a32e1149c94]:
  status: CREATE_COMPLETE
  creation time: 2019-09-05T12:47+0000
  update time: 2019-09-05T13:01+0000
  callback:
  status reason:
  task: NONE
  CloudProviderName: provider-BARI
  outputs:
  {
      "vm_ip": "90.147.75.108",
      "cluster_credentials": {
          "token": "-----BEGIN RSA PRIVATE KEY-----dasdgdsg............\n-----END RSA PRIVATE KEY-----\n"
      }
  }
  links:
    self [https://orchestrator.cloud.cnaf.infn.it/orchestrator/deployments/28dc62e6-facc-4f70-bc14-4a32e1149c94]
    resources [https://orchestrator.cloud.cnaf.infn.it/orchestrator/deployments/28dc62e6-facc-4f70-bc14-4a32e1149c94/resources]
    template [https://orchestrator.cloud.cnaf.infn.it/orchestrator/deployments/28dc62e6-facc-4f70-bc14-4a32e1149c94/template]
```

### Login into the deployed machine

``` bash
echo -e "-----BEGIN RSA PRIVATE KEY-----\n................\n-----END RSA PRIVATE KEY-----\n" > key.key
chmod 600 key.key
ssh -i key.key <vm_ip> -l cloudadm
```

## HOMEWORKS

- 

### [--> NEXT: Setting up Kubernetes locally](k3s.md)