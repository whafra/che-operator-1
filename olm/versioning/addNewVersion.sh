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
# Adds a new version of CRD
#

BASE_DIR=$(cd "$(dirname "$0")" && pwd)

currentVersion=$(${BASE_DIR}/lastCrdVersion.sh)
nextVersion="v"$(($(echo $currentVersion | sed 's/v\(.*\)/\1/')+1))

echo "Current CRD version: "$currentVersion
echo "Addin a new version: "$nextVersion
operator-sdk add api --api-version org.eclipse.che/$nextVersion --kind CheCluster

cp $BASE_DIR/../../pkg/apis/org/"$currentVersion"/che_types.go $BASE_DIR/../../pkg/apis/org/"$nextVersion"/che_types.go
cp $BASE_DIR/../../deploy/crds/org_"$currentVersion"_che_cr.yaml $BASE_DIR/../../deploy/crds/org_"$nextVersion"_che_cr.yaml
rm $BASE_DIR/../../deploy/crds/org_"$nextVersion"_checluster_cr.yaml

sed -i 's/package '$currentVersion'/package '$nextVersion'/g' $BASE_DIR/../../pkg/apis/org/$nextVersion/che_types.go
sed -i 's/org\.eclipse\.che\/'$currentVersion'/org\.eclipse\.che\/'$nextVersion'/g' $BASE_DIR/../../deploy/crds/org_"$nextVersion"_che_cr.yaml

echo "#######################################################"
echo "The next steps of introduction a new CRD version are:"
echo "1. Modify '$BASE_DIR/../../pkg/apis/org/$nextVersion/che_types.go'"
echo "2. Modify '$BASE_DIR/../../deploy/crds/org_"$nextVersion"_che_cr.yaml'"
echo "3. Run '$BASE_DIR/migrate.sh'"
echo "#######################################################"
