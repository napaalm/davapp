VERSION ?= $(shell git describe --always --dirty --tags)
NUMBER ?= $(shell git log --oneline | wc -l)
SOURCE_URL ?= $(shell git remote get-url origin | rev | cut -f 2- -d '.' | rev)
API_URL ?= https://liceodavinci.edu.it/api
AUTH_URL ?= https://sso.elearningdavinci.it/

apk appbundle ipa:
	flutter build $@ --release --build-name "$(VERSION)" --build-number "$(NUMBER)" --dart-define=SOURCE_URL="$(SOURCE_URL)" --dart-define=API_URL="$(API_URL)" --dart-define=AUTH_URL="$(AUTH_URL)"

run:
	flutter run --dart-define=SOURCE_URL="$(SOURCE_URL)" --dart-define=API_URL="$(API_URL)" --dart-define=AUTH_URL="$(AUTH_URL)"

.PHONY: apk appbundle ipa run
