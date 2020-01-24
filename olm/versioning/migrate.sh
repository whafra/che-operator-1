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
# Migrate code to a new version of CRD
#

BASE_DIR=$(cd "$(dirname "$0")" && pwd)

newVersion=$(${BASE_DIR}/lastCrdVersion.sh)
prevVersion="v"$(($(echo $newVersion | sed 's/v\(.*\)/\1/')-1))

echo "#######################################################"
echo "Code migration to: "$newVersion

echo "1. Generate CRD"
operator-sdk generate k8s
operator-sdk generate openapi

echo "2. Remove 'required' sections in CRD file"
. $BASE_DIR/removeRequired.sh $BASE_DIR/../../deploy/crds/org_"$newVersion"_checluster_crd.yaml $BASE_DIR/../../deploy/crds/org_"$newVersion"_che_crd.yaml

echo "3. Revert uneccessary changes"
git co $BASE_DIR/../../deploy/role.yaml
find $BASE_DIR/../../deploy/crds/ | grep checluster | xargs rm $1

echo "4. Add missing license"
. $BASE_DIR/addLicense.sh $BASE_DIR/../../deploy/crds/org_"$newVersion"_che_crd.yaml "#"
. $BASE_DIR/addLicense.sh $BASE_DIR/../../pkg/apis/org/$newVersion/doc.go "//"
. $BASE_DIR/addLicense.sh $BASE_DIR/../../pkg/apis/org/$newVersion/register.go "//"
. $BASE_DIR/addLicense.sh $BASE_DIR/../../pkg/apis/addtoscheme_org_"$newVersion".go "//"

echo "5. Rename imports to use pkg/apis/org/"$newVersion
for package in 'e2e' 'pkg/controller/che' 'pkg/deploy'
do
    find $package -type f -exec sed -i -e 's/pkg\/apis\/org\/'$prevVersion'/pkg\/apis\/org\/'$newVersion'/g' {} \;
done

echo "6. Update csv-config"
sed -i 's/org_'$prevVersion'_che_crd/org_'$newVersion'_che_crd/g' $BASE_DIR/../../olm/eclipse-che-preview-openshift/deploy/olm-catalog/csv-config.yaml
sed -i 's/org_'$prevVersion'_che_crd/org_'$newVersion'_che_crd/g' $BASE_DIR/../../olm/eclipse-che-preview-kubernetes/deploy/olm-catalog/csv-config.yaml

echo "7. Add previous versions into CRD file (storage: false)"
prevVersionNumber=$(($(echo $newVersion | sed 's/v\(.*\)/\1/')-1))
newCrdFile=$BASE_DIR/../../deploy/crds/org_"$newVersion"_che_crd.yaml

sed -i 's/version: '$newVersion'/version: v1/g' $newCrdFile

for v in $(seq 1 $prevVersionNumber)
do
    echo "  - name: v"$v >> $newCrdFile
    echo "    served: true" >> $newCrdFile
    echo "    storage: false" >> $newCrdFile
done

echo "Migration is performed."
echo "The next step is to update nighty olm files."
echo "#######################################################"
