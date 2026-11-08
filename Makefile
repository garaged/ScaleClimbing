SHELL := /bin/bash

.PHONY: help check ci test smoke specs docs architecture security clean manual-m0 manual-m1 manual-m2 manual-m3 ios-build
help:
	@echo "ScaleClimbing: make check | make ios-build | make manual-m2 | make manual-m3"

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
