#!/bin/bash

# only necessary on AMIs that aren't already configured to attach to cluster
sudo su -c 'echo ECS_CLUSTER=${ecs_cluster_name} >> /etc/ecs/ecs.config'

${init_script}
