
#Overview
This is a basic cloud management system that allows users to run non-interactive jobs on a cluster of machines. The system has several key components: nodes, resource pods, resource clusters, a resource manager, a cloud dashboard, a cloud toolset, and jobs. The system assumes that there is a single resource pod and that only non-interactive jobs will be run.

##Class Structure Overview
The Simple Cloud Manager has the following classes:

• Node: represents a machine in the simple cloud. Each node has a specific CPU, memory, and storage limit factor.
• Resource Pod: a collection of nodes. We assume a single network is connecting all the machines.
• Resource Manager: a continuously running daemon that is responsible for making all the management decisions.
• Cloud Dashboard: a component of the ResourceManager or a standalone web server that is connected to the ResourceManager.
• Cloud Toolset: commands that are supported by the ResourceManager.
• Job: represents an actual program running in the machines.
• Proxy: 

Our VMs file structure is: 
VM #1: Ressource_Manager/
• middleware/middleware.py (for handling requests from client to proxy, and response back to client)
• monitoring/ressource_manager.py (rendering for the monitoring cloud dashboard)

VM #2: 
proxy/
• proxy.py (handling client requests)

cloud_toolset/
• cloud_toolset.py (receiving and sending client requests to the resource manager)

##Executing the Cloud Infrastructure
To execute the cloud infrastructure, follow these steps:

1. cd into private folder `cs598-group07-key` containing the private key
2. ssh into the client server by the following command `ssh -i cs598-group07-key comp598-user@winter2023-comp598-group07-01.cs.mcgill.ca`
3. Use the cloud toolset to launch jobs on the cluster by running `python3 cloud_toolset/cloud_toolset.py`
4. Enter the command `cloud init` to initialize and setup all cloud services. 
5. The following commands are supported:
• `cloud pod register POD_NAME`: Registers a new pod with the specified name to the main resource cluster. Note: pod names must be unique.
• `cloud pod ls`: Lists all resource pods in the main cluster. 
• `cloud pod rm POD_NAME`: Removes the specified pod.
• `cloud register NODE_NAME [POD_ID]`: Creates a new node and registers it to the specified pod ID.
• `cloud node ls [RES_POD_ID]`: Lists all the nodes in the specified resource pod.
• `cloud rm NODE_NAME`: removes the specified node
• `cloud launch PATH_TO_JOB`: launches a specified job with the full/relative path to the job file supplied. The job here should be a shell script.
• `cloud job ls [NODE_ID]`: Lists all the jobs that were assigned to the specified node
• `cloud abort JOB_ID`: prints out the specified job log
• `cloud log node NODE_ID`: prints out the entire log file of a specified node.

##Cloud Dashboard
To view the status of different cloud components (status/name/id of nodes and pods, etc) via a web interface, please use the [url to dashboard](https://winter2023-comp598-group07-02.cs.mcgill.ca/)

##Conclusion
This basic cloud management system allows users to run non-interactive jobs on a cluster of machines. The system is composed of several key components and can be executed using Docker and Docker-Compose.
