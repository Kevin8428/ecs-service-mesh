
SERVER_TAG := 0.2.1
WORKER_TAG := 0.1.15
WORKER_REPO := poc-worker
SERVER_REPO := poc

# TODO: improve commands here

tag_worker:
	docker tag $$(docker images -q $(WORKER_REPO):$(WORKER_TAG)) _.dkr.ecr.us-west-2.amazonaws.com/$(WORKER_REPO):$(WORKER_TAG)

build_worker:
	docker build -t $(WORKER_REPO):$(WORKER_TAG) -f apps/worker/Dockerfile ./apps/worker

release_worker: build_worker tag_worker
	docker push _.dkr.ecr.us-west-2.amazonaws.com/$(WORKER_REPO):$(WORKER_TAG)

tag_server:
	docker tag $$(docker images -q $SERVERREPO):$(SERVER_TAG)) _.dkr.ecr.us-west-2.amazonaws.com/$(SERVER_REPO):$(SERVER_TAG)

build_server:
	docker build -t $(SERVER_REPO):$(SERVER_TAG) -f apps/worker/Dockerfile ./apps/worker

release_server: build_server tag_server
	docker push _.dkr.ecr.us-west-2.amazonaws.com/$(SERVER_REPO):$SERVERR_TAG)

.PHONY: tag_worker build_worker release_worker tag_server build_server release_server
