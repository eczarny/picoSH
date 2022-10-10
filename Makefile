#
# picoSH Makefile
#

# Docker configuration
DOCKER_TAG_BASE = eczarny
DOCKER_IMAGE_BASE = $(DOCKER_TAG_BASE)/picosh-base
DOCKER_IMAGE_BOOTLOADER = $(DOCKER_TAG_BASE)/picosh-bootloader
DOCKER_IMAGE_KERNEL = $(DOCKER_TAG_BASE)/picosh-kernel
DOCKER_IMAGE_DWM = $(DOCKER_TAG_BASE)/picosh-dwm
DOCKER_IMAGE_SLSTATUS = $(DOCKER_TAG_BASE)/picosh-slstatus

# Build directores
BUILD = build
TAG = $(BUILD)/tags

all:
	$(info Build the picoSH disk image)
	$(info ---)
	$(info The following targets are available:)
	$(info   - build [builds the picoSH OS image])
	$(info   - shell [runs the Docker image with an interactive shell])
	$(info   - clean [removes temporary build artifacts])
	$(info   - nuke [removes all build artifacts])

$(TAG)/docker-build-base:
	docker build --pull -t $(DOCKER_IMAGE_BASE) -f docker/Dockerfile-base .
	$(call tag,docker-build-base)

$(TAG)/docker-build-bootloader: $(TAG)/docker-build-base
	docker build -t $(DOCKER_IMAGE_BOOTLOADER) -f docker/Dockerfile-bootloader .
	$(call tag,docker-build-bootloader)

$(TAG)/docker-build-kernel: $(TAG)/docker-build-base
	docker build -t $(DOCKER_IMAGE_KERNEL) -f docker/Dockerfile-kernel .
	$(call tag,docker-build-kernel)

$(TAG)/docker-build-dwm: $(TAG)/docker-build-base
	docker build -t $(DOCKER_IMAGE_DWM) -f docker/Dockerfile-dwm .
	$(call tag,docker-build-dwm)

$(TAG)/docker-build-slstatus: $(TAG)/docker-build-base
	docker build -t $(DOCKER_IMAGE_SLSTATUS) -f docker/Dockerfile-slstatus .
	$(call tag,docker-build-slstatus)

.PHONY: docker-build
docker-build: $(TAG)/docker-build-bootloader $(TAG)/docker-build-kernel $(TAG)/docker-build-dwm

.PHONY: docker-nuke
docker-nuke:
	docker rmi -f $(DOCKER_IMAGE_BASE) $(DOCKER_IMAGE_BOOTLOADER) $(DOCKER_IMAGE_KERNEL)

$(TAG)/prepare: repair
	mkdir -p $(BUILD)
	$(call tag,prepare)

$(TAG)/build-dwm: $(TAG)/prepare $(TAG)/docker-build-dwm
	docker run --rm -v $(shell pwd):/var/picosh-build -w /var/picosh-build $(DOCKER_IMAGE_DWM) ./scripts/build-dwm.sh
	$(call tag,build-dwm)

$(TAG)/build-slstatus: $(TAG)/prepare $(TAG)/docker-build-slstatus
	docker run --rm -v $(shell pwd):/var/picosh-build -w /var/picosh-build $(DOCKER_IMAGE_SLSTATUS) ./scripts/build-slstatus.sh
	$(call tag,build-slstatus)

$(TAG)/build-rootfs: $(TAG)/prepare $(TAG)/build-dwm $(TAG)/build-slstatus
	PICOSH_HOME=$(shell pwd) ./scripts/build-rootfs.sh
	$(call tag,build-rootfs)

$(TAG)/build-bootloader: $(TAG)/prepare $(TAG)/docker-build-bootloader
	docker run --rm -v $(shell pwd):/var/picosh-build -w /var/picosh-build $(DOCKER_IMAGE_BOOTLOADER) ./scripts/build-bootloader.sh
	$(call tag,build-bootloader)

$(TAG)/build-kernel: $(TAG)/prepare $(TAG)/build-rootfs $(TAG)/docker-build-kernel
	docker run --rm -v $(shell pwd):/var/picosh-build -w /var/picosh-build $(DOCKER_IMAGE_KERNEL) ./scripts/build-kernel.sh
	$(call tag,build-kernel)

$(TAG)/build-image: $(TAG)/prepare $(TAG)/build-rootfs $(TAG)/build-bootloader $(TAG)/build-kernel
	PICOSH_HOME=$(shell pwd) ./scripts/build-image.sh
	$(call tag,build-image)

.PHONY: build
build: $(TAG)/build-image

.PHONY: shell
shell: $(TAG)/docker-build-base
	docker run --rm -it -v $(shell pwd):/var/picosh-build -w /var/picosh-build $(DOCKER_IMAGE_BASE) /bin/bash

.PHONY: shell-dwm
shell-dwm: $(TAG)/docker-build-dwm
	docker run --rm -it -v $(shell pwd):/var/picosh-build -w /var/picosh-build $(DOCKER_IMAGE_DWM) /bin/bash

.PHONY: shell-slstatus
shell-slstatus: $(TAG)/docker-build-slstatus
	docker run --rm -it -v $(shell pwd):/var/picosh-build -w /var/picosh-build $(DOCKER_IMAGE_SLSTATUS) /bin/bash

.PHONY: shell-bootloader
shell-bootloader: $(TAG)/docker-build-bootloader
	docker run --rm -it -v $(shell pwd):/var/picosh-build -w /var/picosh-build $(DOCKER_IMAGE_BOOTLOADER) /bin/bash

.PHONY: shell-kernel
shell-kernel: $(TAG)/docker-build-kernel
	docker run --rm -it -v $(shell pwd):/var/picosh-build -w /var/picosh-build $(DOCKER_IMAGE_KERNEL) /bin/bash

.PHONY: clean
clean:
	find $(BUILD)/tags -type f ! -name "docker-build-*" -exec rm -rf {} \;
	find $(BUILD) -type f ! -wholename "*/tags/*" -exec rm -rf {} \;
	sudo rm -rf /tmp/picosh-staging

.PHONY: nuke
nuke: clean
	rm -rf $(BUILD)

# OneDrive has a tendency to strip permissions, this target makes repairs easier
.PHONY: repair
repair:
	find rootfs/ -type f -name "*.sh" -exec chmod +x {} \;
	find scripts/ -type f -name "*.sh" -exec chmod +x {} \;

define tag
	@echo Completed step $1
	@mkdir -p $(TAG)
	@touch $(TAG)/$1
endef
