.PHONY: build check test

build:
	./scripts/build.sh

check:
	./scripts/check.sh

test: check
