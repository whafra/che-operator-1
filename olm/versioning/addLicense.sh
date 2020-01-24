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

#
# Add license to the heade of the file
# Usage: addLicense.sh <file> <comment_type>
#

echo $1_license

cat << EOF > $1_license
$2
$2 Copyright (c) 2012-2020 Red Hat, Inc.
$2 This program and the accompanying materials are made
$2 available under the terms of the Eclipse Public License 2.0
$2 which is available at https://www.eclipse.org/legal/epl-2.0/
$2
$2 SPDX-License-Identifier: EPL-2.0
$2
$2 Contributors:
$2   Red Hat, Inc. - initial API and implementation
$2
EOF

cat $1 >> $1_license
mv $1_license $1
