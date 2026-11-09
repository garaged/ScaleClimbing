SHELL := /bin/bash

.PHONY: help check ci test smoke specs docs architecture security clean manual-m0 manual-m1 manual-m2 manual-m3 manual-m4 manual-m5 manual-m6 manual-m7 manual-m8 manual-m9 ios-build ios-ui-test
help:
	@echo "ScaleClimbing: make check | make ios-build | make ios-ui-test | make manual-m9"

check: specs docs architecture security test smoke
ci: check
test:
	swift test
smoke:
	swift run scaleclimbing-smoke
specs:
	./scripts/check-openspec.sh
docs:
	./scripts/check-docs.sh
architecture:
	./scripts/check-architecture.sh
security:
	./scripts/check-security-baseline.sh

ios-build:
	xcodebuild -project Apps/iOS/ScaleClimbing.xcodeproj -scheme ScaleClimbing -configuration Debug -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
ios-ui-test:
	bash scripts/run-ios-ui-tests.sh

manual-m4:
	@cat docs/engineering/manual-testing-m4.md
manual-m5:
	@cat docs/engineering/manual-testing-m5.md
manual-m6:
	@cat docs/engineering/manual-testing-m6.md
manual-m7:
	@cat docs/engineering/manual-testing-m7.md
manual-m8:
	@cat docs/engineering/manual-testing-m8.md
manual-m9:
	@cat docs/engineering/manual-testing-m9.md

manual-m0:
	@cat docs/engineering/manual-testing.md
manual-m1:
	@cat docs/engineering/manual-testing-m1.md
manual-m2:
	@cat docs/engineering/manual-testing-m2.md
manual-m3:
	@cat docs/engineering/manual-testing-m3.md
clean:
	rm -rf .build
