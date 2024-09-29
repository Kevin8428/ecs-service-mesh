- deploy with TF direct to AWS
- build:
    - 1 sns
    - 5 sqs queues that subscribe to sns
    - 5 services in one cluster
        - services contain tasks that spin up a handler
        - services call each other /status page
        - services consume from sqs
        - service tasks contain RDS creds via secrets manager
    - secrets in secrets manager
    - 1 rds instance that contains some dummy data
- then deploy via Make and from inside a container
- use linter to clean/modify


- layout
    Makefile
    README.md
    backend.tf
    main.tf
    version.tf
    /ecs
    /sns
    /sqs
    /monitoring
        - module for monitoring
    /secrets
        - module to store secrets using secrets manager
