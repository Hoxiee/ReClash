SHELL := /bin/bash

.PHONY: help submodules prepare analyze test run

help:
	@echo 'make submodules  # update git submodules (mihomo core sources)'
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
