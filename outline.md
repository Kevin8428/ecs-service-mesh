1. extend poc to use private subnet and nat gateway
2. update main project to
    - only have one private subnet
    - have apps deployed on this subnet
    - have nat gateway
    - deploy just ECS/SQS part of main project first

- https://rhuaridh.co.uk/blog/aws-private-subnet.html
- https://harshitdawar.medium.com/launching-a-vpc-with-public-private-subnet-nat-gateway-in-aws-using-terraform-99950c671ce9
- process:
    - create vpc
    - create private subnet
    - create public subnet
        - enable auto-assign public IP address
    - create internet gateway
        - unless using default VPC, which should have one already
        - each VPC gets only one IGW
    - create routing table for IGW
    - associate routing table with public subnet
        - provides internet gateway access
    - create EIP for nat gateway
    - create nat gateway for things to access internet
    - create routing table for nat GW access
    - associate routing table with private subnet
        - or with instance on private subnet



- questions
    - is vpc endpoint needed to make this work?
    - if so, is this practical?
    - shouldn't an ECS container be able to reach SQS?
    - awsvpc networkign mode vs others
    - learn about ECS networking
    - what is a NAT gateway


- cloud map
    - create a CM namespace
    - create a `CM service` in the namespace
        - this returns a svc-id
        - represents a component of application eg payment processing
        - service-discovery.create_service()
            - provide DNS record - ttl, type, namespace, routing policy
            - provide 
    - DNS config `for CM service`
        - if service supports instance discovery by DNS queries
            - CM creates a Route 53 DNS record
            - must specify a Route 53 routing policy and DNS record type to be applied to all DNS records that CM creates
    - register resource as a `service instance` of the `CM service`
        - service-discovery.register_instance()
            - provide `service id` 
                - this is the CM service id you get when generating a service
                - can find this
            - provide ip and port of `CM service`
                - can find these in UI inside namespace
    - discover instances to call
        - `instances = client.discover_instances(NamespaceName='development_dns', ServiceName='worker')`

push to sns -> sqs -> consumer-service -> api service -> rds

- networking
    - https://dev.to/tinystacks/service-discovery-with-aws-cloud-map-1mmg
    - https://stackoverflow.com/questions/77340374/aws-ecs-fargate-service-connect-not-updating-etc-hosts
        - link here shows github file config
    - https://stackoverflow.com/questions/75213261/aws-service-connect-with-terraform
    - https://www.reddit.com/r/aws/comments/zpc7rh/how_to_have_inter_container_communication/
    - Service Connect
        - with `awsvpc` networking mode

- deploy with TF direct to AWS
- build:
    - 1 sns
    - 5 sqs queues that subscribe to sns
    - 5 services in one cluster
        - api inside service
        - services contain tasks that spin up a handler
        - services call each other /status page
        - services consume from sqs
        - service tasks contain RDS creds via secrets manager
    - secrets in secrets manager
    - 1 rds instance that contains some dummy data
- then deploy via Make and from inside a container
- use linter to clean/modify
- create seed file for db
- state file in s3
- tag all resources
- squash commits before pushing
- create new vpc
