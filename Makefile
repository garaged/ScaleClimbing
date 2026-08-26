SHELL := /bin/bash

.PHONY: help check ci test smoke specs docs architecture security clean manual-m0 manual-m1 manual-m2

help:
	@echo "ScaleClimbing development commands"
	@echo "  make check        Run the full local validation gate"
	@echo "  make ci           Same as check; used by GitHub Actions"
	@echo "  make test         Run Swift unit tests"
	@echo "  make smoke        Run the CLI smoke executable"
	@echo "  make specs        Validate OpenSpec structure"
	@echo "  make docs         Validate required engineering/product docs"
	@echo "  make architecture Validate component architecture rules"
	@echo "  make security     Run repository security baseline checks"
	@echo "  make manual-m0    Print the M0 manual acceptance checklist"
	@echo "  make manual-m1    Print the M1 manual acceptance checklist"
	@echo "  make manual-m2    Print the M2 manual acceptance checklist"
	@echo "  make clean        Remove Swift build artifacts"

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

manual-m0:
	@cat docs/engineering/manual-testing.md

manual-m1:
	@cat docs/engineering/manual-testing-m1.md

manual-m2:
	@cat docs/engineering/manual-testing-m2.md

clean:
	rm -rf .build
