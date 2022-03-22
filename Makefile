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

BE_LOCAL_PATH ?= ../../../../be

AF_LOCAL_PATH = ../../../features/atlassian
AG_LOCAL_PATH = ../../../pkg/atlas-gonnect

AF_GO_PACKAGE = github.com/go-enjin/third_party/features/atlassian
AG_GO_PACKAGE = github.com/go-enjin/third_party/pkg/atlas-gonnect

APP_NAME    ?= be-atlassian
APP_SUMMARY ?= Atlassian Enjin

AC_NAME        ?= "be-atlassian"
AC_KEY         ?= "com.github.go-enjin.examples.be.atlassian"
AC_DESCRIPTION ?= "Go-Enjin\ Atlassian\ integration\ demonstration"
AC_BASE_URL    ?= "nil"
AC_VENDOR_NAME ?= "Go-Enjin"
AC_VENDOR_URL  ?= "https://github.com/go-enjin"

AC_VALIDATE_IP ?= false

DENY_DURATION ?= 60

BUILD_TAGS = locals,database,atlassian
GOPKG_KEYS = AF AG

DIST_CLEAN = .bin db.sqlite

define _apply_prefix =
$(shell if [ "${APP_PREFIX}" != "" -a "${APP_PREFIX}" != "prd" ]; then \
	echo "${APP_PREFIX}-$(1)"; \
else \
	echo "$(1)"; \
fi)
endef

define _make_ac_vars =
${ENV_PREFIX}_AC_KEY_$(1)="$(call _apply_prefix,${AC_KEY})" \
${ENV_PREFIX}_AC_NAME_$(1)="${AC_NAME}" \
${ENV_PREFIX}_AC_BASE_URL_$(1)="${AC_BASE_URL}" \
${ENV_PREFIX}_AC_DESCRIPTION_$(1)="${AC_DESCRIPTION}" \
${ENV_PREFIX}_AC_VENDOR_NAME_$(1)="${AC_VENDOR_NAME}" \
${ENV_PREFIX}_AC_VENDOR_URL_$(1)="${AC_VENDOR_URL}" \
${ENV_PREFIX}_AC_VALIDATE_IP_$(1)="${AC_VALIDATE_IP}"
endef

define override_run =
	@if [ "${AC_BASE_URL}" = "nil" ]; then \
		echo "# AC_BASE_URL not present"; \
		false; \
	fi
	@if [ ! -x "${APP_NAME}" ]; then \
		echo "${APP_NAME} not found or not executable"; \
		false; \
	fi
	@echo "# running ${APP_NAME}"
	@${CMD} \
		$(call _env_run_vars) \
		$(call _make_ac_vars,V1) \
		${ENV_PREFIX}_AC_VERSION_V1="1.0.0" \
		./${APP_NAME}
endef

include ./Enjin.mk
