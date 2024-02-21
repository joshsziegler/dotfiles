#!/bin/bash

if [ ! -f ~/code/ag/deploy/terraform/.env ]
then
cat << EOF > ~/code/ag/deploy/terraform/.env
export TF_HTTP_USERNAME=joshz
export TF_HTTP_PASSWORD=REPLACE_ME_WITH_GITLAB_API_KEY
EOF
fi

cat << EOF > ~/code/ag/deploy/terraform/ag-atrc/.envrc
export AWS_PROFILE='atrc-gov-cross'
EOF

cat << EOF > ~/code/ag/deploy/terraform/ag-design-pickle/.envrc
export AWS_PROFILE='ag-design-pickle-cross'
EOF

cat << EOF > ~/code/ag/deploy/terraform/ag-test/.envrc
dotenv ../.env
export AWS_PROFILE=ag-development-cross
export TF_HTTP_ADDRESS="https://gitlab.office.analyticsgateway.com/api/v4/projects/111/terraform/state/ag-test"
export TF_HTTP_LOCK_ADDRESS="$TF_HTTP_ADDRESS/lock"
export TF_HTTP_UNLOCK_ADDRESS="$TF_HTTP_ADDRESS/lock"
EOF

cat << EOF > ~/code/ag/deploy/terraform/personal_dev/.envrc
dotenv ../.env
export AWS_PROFILE=ag-development-cross
export TF_HTTP_ADDRESS="https://gitlab.office.analyticsgateway.com/api/v4/projects/111/terraform/state/dev-joshz"
export TF_HTTP_LOCK_ADDRESS="$TF_HTTP_ADDRESS/lock"
export TF_HTTP_UNLOCK_ADDRESS="$TF_HTTP_ADDRESS/lock"
EOF
