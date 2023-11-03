# Copyright (c) Microsoft Corporation.
# Licensed under the MIT license.

#!/bin/bash
set -e

printInfo() {
    printf "$YELLOW\n%s$RESET\n" "$1"
}
# Get the directory that this script is in
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
source "${DIR}/load-env.sh"
pushd "$DIR/../infra" > /dev/null

#make sure bicep is always the latest version
az bicep upgrade

#deploy bicep
az deployment sub what-if --location $LOCATION --template-file secure.bicep --parameters main.parameters.json --name $RG_NAME
if [ -z $SKIP_PLAN_CHECK ]
    then
        printInfo "Are you happy with the plan, would you like to apply? (y/N)"
        read -r answer
        answer=${answer^^}
        
        if [[ "$answer" != "Y" ]];
        then
            printInfo "Exiting: User did not wish to apply infrastructure changes." 
            exit 1
        fi
    fi
results=$(az deployment sub create --location $LOCATION --template-file secure.bicep --parameters main.parameters.json --name $RG_NAME)

#save deployment output
printInfo "Writing output to infra_secure_output.json"
pushd "$DIR/.."
echo $results > infra_secure_output.json
