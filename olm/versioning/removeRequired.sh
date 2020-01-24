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
# Removes required section from yaml
# Usage: removeRequired.sh <input_file.yaml> <output_file.yaml>
#

REQUIRED=false
while IFS= read -r line
do
    if [[ $REQUIRED == true ]]; then
        if [[ $line == *"- "* ]]; then
            continue
        else
            REQUIRED=false
        fi
    fi

    if [[ $line == *"required:"* ]]; then
        REQUIRED=true
        continue
    fi

    echo  "$line" >> $2
done < "$1"
