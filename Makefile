VERSION ?= $(shell git describe --always --dirty --tags)
NUMBER ?= $(shell git log --oneline | wc -l)

apk ios:
	flutter build $@ --release --build-name "$(VERSION)" --build-number "$(NUMBER)"

run:
	flutter run

.PHONY: apk ios run
