BUILD_ROOT ?= $(SRCROOT)/tmp
VENDOR_ROOT = $(SRCROOT)/vendor

MAJOR_VERSION = 1
MINOR_VERSION = 0

GRAPHICSMAGICK_ROOT = $(BUILD_ROOT)/gm
GRAPHICSMAGICK_TAR_XZ = $(VENDOR_ROOT)/GraphicsMagick-1.3.28.tar.xz
GRAPHICSMAGICK_EXE = $(GRAPHICSMAGICK_ROOT)/utilities/gm

DOCKER_DEVIMAGE = gcc:7

BEDROCK_ROOT := $(abspath make/baker)
include $(BEDROCK_ROOT)/boot.mk

build: $(GRAPHICSMAGICK_EXE)
	if [ -n "$$DEV_UID" ]; then \
		chown -R $$DEV_UID:$$DEV_GID $(SRCROOT)/tmp; \
	fi

clean: graphicsmagick-clean gem-clean

#- Build rules for graphicsmagick ----------------------------------------------
graphicsmagick-clean:
	rm -rf $(GRAPHICSMAGICK_ROOT)

$(GRAPHICSMAGICK_EXE): $(GRAPHICSMAGICK_ROOT)
	cd $(GRAPHICSMAGICK_ROOT) && \
	./configure CFLAGS="-Os -s" --enable-static --disable-shared && \
	make

$(GRAPHICSMAGICK_MAGIC_ROOT): $(GRAPHICSMAGICK_ROOT)

$(GRAPHICSMAGICK_ROOT):
	mkdir -p $(GRAPHICSMAGICK_ROOT)
	cd $(GRAPHICSMAGICK_ROOT) && xz -dc $(GRAPHICSMAGICK_TAR_XZ) | tar -xvf - --strip-components 1

#- Build rules for graphicsmagick-binary gem -----------------------------------
GEM_BRANCH = releases
GEM_ROOT = $(BUILD_ROOT)/graphicsmagick-binary
GEM_SOURCES = $(GEM_ROOT)/bin/gm-gem_linux_x86_64

gem-publish: gem-rebuild gem-push

gem-rebuild: gem-clean gem-build

gem-update: $(GEM_ROOT)
	cd $(GEM_ROOT) && \
		git remote update && \
		git reset --hard origin/$(GEM_BRANCH)

gem-build: gem-update $(GEM_SOURCES)
	cd $(GEM_ROOT) && \
		sed -e 's/version = .*/version = "$(VERSION)"/' graphicsmagick-binary.gemspec > .tmp.gemspec && \
		mv .tmp.gemspec graphicsmagick-binary.gemspec && \
		git add graphicsmagick-binary.gemspec $(GEM_SOURCES) && \
		git commit -m "Updated to $(VERSION)" && \
		git tag v$(VERSION)

gem-push: $(GEM_ROOT)
	cd $(GEM_ROOT) && \
		git push origin $(GEM_BRANCH) v$(VERSION)

gem-clean:
	rm -rf $(GEM_ROOT)

$(GEM_ROOT):
	mkdir -p $(GEM_ROOT)
	cd $(GEM_ROOT) && git clone --branch $(GEM_BRANCH) git@github.com:coupa/graphicsmagick-binary.git .

$(GEM_ROOT)/bin/gm-gem_linux_x86_64: $(GRAPHICSMAGICK_EXE) $(GEM_ROOT)
	cp $(GRAPHICSMAGICK_EXE) $@

$(GEM_ROOT)/magic: $(GRAPHICSMAGICK_MAGIC_ROOT)
	rm -rf $@
	cp -r $(GRAPHICSMAGICK_MAGIC_ROOT) $@



