#!/bin/bash
set -e
set -x

SCRIPT="enable-ubuntu-auto-updates.sh"
#AGS=("aaco" "ascend" "demo" "design-pickle" "dev" "dsass" "hpc-access-point" "hpcmp-aws" "hpcmp-azure" "nexus" "ppo" "sdpe")
AGS=("aaco" "ascend" "demo" "design-pickle" "dev" "hpcmp-aws" "hpcmp-azure" "ppo" "sdpe")

SSH="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

for SYSTEM in ${AGS[@]}
do
    TARGET=${SYSTEM}.analyticsgateway.com
    echo "${TARGET}"

    ### Do Work Here for HEAD
    rsync -v ${SCRIPT} ${TARGET}:~/
    ${SSH} ${TARGET} "./${SCRIPT}"
    ${SSH} ${TARGET} "rm ${SCRIPT}"

    ### Do Work Here for SIDECAR
    rsync -v -e "${SSH} -J ${TARGET}" ${SCRIPT} agadmin@sidecar:~/
    ${SSH} -J ${TARGET} agadmin@sidecar "./${SCRIPT}"
    ${SSH} -J ${TARGET} agadmin@sidecar "rm ${SCRIPT}"

done


