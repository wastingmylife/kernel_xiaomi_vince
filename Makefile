NAME ?= WindStorm-Kernel
DATE := $(shell date "+%d%m%Y-%I%M")
VERSION := 4.9-$(LINUX_VERSION)

SZIP := $(NAME)-$(VERSION)-STABLE-$(DATE).zip


EXCLUDE := Makefile *.git* *.jar* WindStorm* *placeholder*

stable: $(SZIP)

$(SZIP):
	@echo "Creating ZIP: $(SZIP)"
	@zip -r9 "$@" . -x $(EXCLUDE)
	@echo "Generating SHA1..."
	@sha1sum "$@" > "$@.sha1"
	@cat "$@.sha1"
	@echo "Done."

clean:
	@rm -vf *.zip*
	@rm -vf zImage
	@echo "Done."