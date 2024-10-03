#!/bin/bash

# necessary for AMIs that aren't already configured with ecs-agent to attach to cluster
# OR if deploying to cluster other than default
sudo su -c 'echo ECS_CLUSTER=${ecs_cluster_name} >> /etc/ecs/ecs.config'

${init_script}
