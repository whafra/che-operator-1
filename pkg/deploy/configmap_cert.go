//
// Copyright (c) 2012-2019 Red Hat, Inc.
// This program and the accompanying materials are made
// available under the terms of the Eclipse Public License 2.0
// which is available at https://www.eclipse.org/legal/epl-2.0/
//
// SPDX-License-Identifier: EPL-2.0
//
// Contributors:
//   Red Hat, Inc. - initial API and implementation
//
package deploy

import (
	"context"
	"reflect"

	orgv1 "github.com/eclipse/che-operator/pkg/apis/org/v1"
	"github.com/google/go-cmp/cmp"
	"github.com/google/go-cmp/cmp/cmpopts"
	"github.com/sirupsen/logrus"
	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

var certConfigMapDiffOpts = cmp.Options{
	cmpopts.IgnoreFields(corev1.ConfigMap{}, "TypeMeta", "Data", "BinaryData"),
	cmp.Comparer(func(x, y metav1.ObjectMeta) bool {
		return reflect.DeepEqual(x.Labels, y.Labels)
	}),
}

func SyncCertConfigMapToCluster(checluster *orgv1.CheCluster, clusterAPI ClusterAPI) (*corev1.ConfigMap, error) {
	specConfigMap, err := GetSpecConfigMap(checluster, checluster.Spec.Server.ServerTrustStoreConfigMapName, map[string]string{}, clusterAPI)
	if err != nil {
		return nil, err
	}
	specConfigMap.ObjectMeta.Labels["config.openshift.io/inject-trusted-cabundle"] = "true"

	clusterConfigMap, err := getClusterConfigMap(specConfigMap.Name, specConfigMap.Namespace, clusterAPI.Client)
	if err != nil {
		return nil, err
	}

	if clusterConfigMap == nil {
		logrus.Infof("Creating a new object: %s, name %s", specConfigMap.Kind, specConfigMap.Name)
		err := clusterAPI.Client.Create(context.TODO(), specConfigMap)
		return nil, err
	}

	if clusterConfigMap.ObjectMeta.Labels["config.openshift.io/inject-trusted-cabundle"] == "" {
		clusterConfigMap.ObjectMeta.Labels["config.openshift.io/inject-trusted-cabundle"] = "true"
		logrus.Infof("Updating existed object: %s, name: %s", specConfigMap.Kind, specConfigMap.Name)
		err := clusterAPI.Client.Update(context.TODO(), clusterConfigMap)
		return nil, err
	}

	return clusterConfigMap, nil
}
