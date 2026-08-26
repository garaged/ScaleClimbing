SHELL := /bin/bash

.PHONY: help check ci test smoke specs docs security clean manual-m0

help:
	@echo "ScaleClimbing development commands"
	@echo "  make check       Run the full local validation gate"
	@echo "  make ci          Same as check; used by GitHub Actions"
	@echo "  make test        Run Swift unit tests"
	@echo "  make smoke       Run the CLI smoke executable"
	@echo "  make specs       Validate OpenSpec structure"
	@echo "  make docs        Validate required engineering/product docs"
	@echo "  make security    Run repository security baseline checks"
	@echo "  make manual-m0   Print the M0 manual acceptance checklist"
	@echo "  make clean       Remove Swift build artifacts"

check: specs docs security test smoke

ci: check

test:
	swift test

smoke:
	swift run scaleclimbing-smoke

specs:
	./scripts/check-openspec.sh

docs:
	./scripts/check-docs.sh

security:
	./scripts/check-security-baseline.sh

manual-m0:
	@cat docs/engineering/manual-testing.md

clean:
	rm -rf .build
