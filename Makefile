all: build

OS=linux
ARCH=amd64
BIN=vulnweb
REPO=quay.io/brancz/vulnweb
TAG=latest

build:
	mkdir -p _output/bin/$(OS)/$(ARCH)
	GOOS=$(OS) GOARCH=$(ARCH) CGO_ENABLED=0 go build --installsuffix cgo --ldflags="-s" -o _output/bin/$(OS)/$(ARCH)/$(BIN)

container: build
	@sed \
		-e 's|ARG_OS|$(OS)|g' \
		-e 's|ARG_ARCH|$(ARCH)|g' \
		-e 's|ARG_BIN|$(BIN)|g' \
		Dockerfile.in > .dockerfile-$(ARCH)
	docker build -f .dockerfile-$(ARCH) -t $(REPO)-$(ARCH):$(TAG) .

.PHONY: all build
