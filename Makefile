# Plugin parameters
PLUGIN_NAME=axiom/docker-logging-plugin
PLUGIN_TAG=0.0.1
DOCKER_BUILDER=axiom-docker-builder

all: clean docker rootfs create
arm64: clean docker_arm64 rootfs create

clean:
	@echo "### rm ./plugin"
	rm -rf ./plugin

docker:
	@echo "### docker build: rootfs image with axiom-logging-plugin"
	docker buildx create --name ${DOCKER_BUILDER} --use || true
	docker buildx --builder ${DOCKER_BUILDER} build --platform linux/amd64 \
	--tag ${PLUGIN_NAME}:rootfs --load .

docker_arm64:
	@echo "### docker build: rootfs image with axiom-logging-plugin"
	docker buildx create --name ${DOCKER_BUILDER} --use || true
	docker buildx --builder ${DOCKER_BUILDER} build --platform linux/arm64 \
	--tag ${PLUGIN_NAME}:rootfs --load .

rootfs:
	@echo "### create rootfs directory in ./plugin/rootfs"
	mkdir -p ./plugin/rootfs
	docker create --name tmprootfs ${PLUGIN_NAME}:rootfs
	docker export tmprootfs | tar -x -C ./plugin/rootfs
	@echo "### copy config.json to ./plugin/"
	cp config.json ./plugin/
	docker rm -vf tmprootfs

create:
	@echo "### remove existing plugin ${PLUGIN_NAME}:${PLUGIN_TAG} if exists"
	docker plugin rm -f ${PLUGIN_NAME}:${PLUGIN_TAG} || true
	@echo "### create new plugin ${PLUGIN_NAME}:${PLUGIN_TAG} from ./plugin"
	docker plugin create ${PLUGIN_NAME}:${PLUGIN_TAG} ./plugin

enable:
	@echo "### enable plugin ${PLUGIN_NAME}:${PLUGIN_TAG}"
	docker plugin enable ${PLUGIN_NAME}:${PLUGIN_TAG}

push: clean docker rootfs create enable
	@echo "### push plugin ${PLUGIN_NAME}:${PLUGIN_TAG}"
	docker plugin push ${PLUGIN_NAME}:${PLUGIN_TAG}
