#!/usr/bin/make -f

# Copyright (c) 2022  The Go-Enjin Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#: uncomment to echo instead of execute
#CMD=echo

SHELL = /bin/bash

BE_PATH ?= ../../../../be
AF_PATH ?= ../../../features/atlassian
AG_PATH ?= ../../../pkg/atlas-gonnect

AF_PACKAGE = github.com/go-enjin/third_party/features/atlassian
AG_PACKAGE = github.com/go-enjin/third_party/pkg/atlas-gonnect

ENJENV_BIN ?= $(shell which enjenv)

DEBUG ?= false

APP_NAME    ?= be-atlassian
APP_SUMMARY ?= Atlassian Enjin
APP_VERSION ?= $(shell ${ENJENV_BIN} git-tag --untagged v0.0.1 2> /dev/null)
REL_VERSION ?= $(shell ${ENJENV_BIN} rel-ver 2> /dev/null)
ENV_PREFIX  ?= BE

AC_NAME        ?= "be-atlassian"
AC_KEY         ?= "com.github.go-enjin.examples.be.atlassian"
AC_DESCRIPTION ?= "Go-Enjin Atlassian integration demonstration"
AC_BASE_URL    ?= "nil"
AC_VENDOR_NAME ?= "Go-Enjin"
AC_VENDOR_URL  ?= "https://github.com/go-enjin"

BUILD_TAGS = locals,database,atlassian

RELEASE = ""

.PHONY: all help clean dist-clean build dev release run _enjenv

_enjenv:
	@if [ ! -x "${ENJENV_BIN}" ]; then \
		echo "enjenv not found"; \
		false; \
	fi

help:
	@echo "usage: make <help|clean|dist-clean|build|dev|release|run>"

clean:
	@if [ -f "${APP_NAME}" ]; then rm -fv "${APP_NAME}"; fi

dist-clean: clean
	@if [ -f "db.sqlite" ]; then rm -fv "db.sqlite"; fi

build: LABEL=$(shell if [ "${RELEASE}" = "true" ]; then echo "Building release"; else echo "Building"; fi)
build: OPTION=$(shell if [ "${RELEASE}" = "true" ]; then echo "--optimize"; fi)
build:
	@echo "${LABEL}: ${APP_VERSION}, ${REL_VERSION}"
	@${CMD} ${ENJENV_BIN} golang build \
			--be-app-name "${APP_NAME}" \
			--be-summary "${APP_SUMMARY}" \
			--be-version "${APP_VERSION}" \
			--be-release "${REL_VERSION}" \
			--be-env-prefix "${ENV_PREFIX}" \
			${OPTION} -- -v -tags=${BUILD_TAGS}

release: RELEASE="true"
release: build

run:
	@if [ "${AC_BASE_URL}" = "nil" ]; then \
		echo "missing AC_BASE_URL setting"; \
		false; \
	fi
	@if [ -x "${APP_NAME}" ]; then \
		echo "# running ${APP_NAME}"; \
		${CMD} ${ENV_PREFIX}_DEBUG=${DEBUG} ./${APP_NAME} \
			--ac-validate-ip \
			--ac-name "${AC_NAME}" \
			--ac-key "${AC_KEY}" \
			--ac-base-url "${AC_BASE_URL}" \
			--ac-vendor-name "${AC_VENDOR_NAME}" \
			--ac-vendor-url "${AC_VENDOR_URL}" \
			--ac-description "${AC_DESCRIPTION}"; \
	else \
		echo "# ${APP_NAME} not found"; \
	fi

dev: DEBUG=true
dev: run

local: _enjenv
	@if [ -d "${BE_PATH}" ]; then \
		${CMD} ${ENJENV_BIN} go-local ${BE_PATH}; \
	else \
		echo "BE_PATH not set or not a directory: \"${BE_PATH}\""; \
	fi
	@if [ -d "${AF_PATH}" ]; then \
		${CMD} ${ENJENV_BIN} go-local ${AF_PACKAGE} ${AF_PATH}; \
	else \
		echo "AF_PATH not set or not a directory: \"${AF_PATH}\""; \
	fi
	@if [ -d "${AG_PATH}" ]; then \
		${CMD} ${ENJENV_BIN} go-local ${AG_PACKAGE} ${AG_PATH}; \
	else \
		echo "AG_PATH not set or not a directory: \"${AG_PATH}\""; \
	fi

unlocal: _enjenv
	@${CMD} ${ENJENV_BIN} go-unlocal
	@${CMD} ${ENJENV_BIN} go-unlocal ${AF_PACKAGE}
	@${CMD} ${ENJENV_BIN} go-unlocal ${AG_PACKAGE}

tidy:
	@${CMD} go mod tidy -go=1.16 && go mod tidy -go=1.17

be-update: _enjenv
	@${CMD} GOPROXY=direct go get -u github.com/go-enjin/be
