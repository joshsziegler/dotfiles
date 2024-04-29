#!/bin/bash
set -e # Stop execution if a command errors
#set -x # Echo commands and expand any variables
###############################################################################
# Runs SCRIPT_PATH on each host in HOSTS.
# Rsyncs the script to the host's home directory, runs it, and then deletes it.
###############################################################################

#SCRIPT_PATH="bin/enable-ubuntu-auto-updates.sh"
SCRIPT_PATH="tools/set-user-ids.sh"
SCRIPT=`basename $SCRIPT_PATH`
HOSTS=("aaco" "demo" "design-pickle" "dev" "dsass" "hpcmp-aws" "hpcmp-azure" "nexus" "ppo" "public" "sdpe")

# SSH without checking the host identity or saving it
SSH="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

for HOST in ${HOSTS[@]}
do
    TARGET=${HOST}.analyticsgateway.com
    echo ""
    echo "${TARGET}"

    ### Do Work Here for HEAD
    rsync -q ${SCRIPT_PATH} ${TARGET}:~/
    # SSH to the TARGET and run SCRIPT, hiding the SSH warning about the hostfile
    ${SSH} ${TARGET} "./${SCRIPT}"  2> >(grep -v "Permanently added" 1>&2)
    ${SSH} ${TARGET} "rm ${SCRIPT}" 2> >(grep -v "Permanently added" 1>&2)

    ### Do Work Here for SIDECAR
    #rsync -q -e "${SSH_PATH} -J ${TARGET}" ${SCRIPT} agadmin@sidecar:~/
    #${SSH} -J ${TARGET} agadmin@sidecar "./${SCRIPT}"
    #${SSH} -J ${TARGET} agadmin@sidecar "rm ${SCRIPT}"
done


