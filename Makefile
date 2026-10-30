SHELL := /bin/bash

.PHONY: help submodules prepare analyze test run site-sync site-check site-build

help:
	@echo 'make submodules  # initialize the pinned core and website repositories'
	@echo 'make site-sync   # synchronize website provider data and JSON schemas'
	@echo 'make site-check  # verify website data and documentation source parity'
	@echo 'make site-build  # build the Nuxt website without deploying it'
	@echo 'make prepare     # resolve dependencies and generate app sources'
	@echo 'make analyze     # prepare and analyze the application'
	@echo 'make test        # prepare and run the root test suite'
	@echo 'make run         # prepare and launch in safe mode'
	@echo ''
	@echo 'The Go core and Rust helper build automatically through the setup build'
	@echo 'hook during flutter build; see .agents/commands.md.'

submodules:
	git submodule update --init --recursive

prepare:
	dart tool/prepare.dart

analyze:
	dart tool/prepare.dart -- analyze --no-fatal-infos

test:
	dart run tool/test.dart

run:
	dart tool/prepare.dart -- run --dart-define=SAFE_MODE=true

site-sync:
	node tool/site_docs.mjs --sync

site-check:
	node --test test/tool/site_docs_test.mjs
	node tool/site_docs.mjs --check

site-build:
	bash tool/build_site.sh
