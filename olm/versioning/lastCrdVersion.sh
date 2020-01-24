#!/bin/bash
#
# Copyright (c) 2012-2020 Red Hat, Inc.
# This program and the accompanying materials are made
# available under the terms of the Eclipse Public License 2.0
# which is available at https://www.eclipse.org/legal/epl-2.0/
#
# SPDX-License-Identifier: EPL-2.0
#
# Contributors:
#   Red Hat, Inc. - initial API and implementation

BASE_DIR=$(cd "$(dirname "$0")" && pwd)

find ${BASE_DIR}/../../deploy/crds/* | grep -e '.*crd.yaml$' | sort -n | tail -1 | sed 's/.*org_\(v.*\)_che\(cluster\)\?_crd.yaml$/\1/'
