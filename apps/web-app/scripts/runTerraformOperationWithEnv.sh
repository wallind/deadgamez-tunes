#!/usr/bin/env sh

TERRAFORM_INFRA_PATH="infra/terraform/env/dev"
OPERATIONS=("init-upgrade" "plan" "apply" "destroy")

if [[ $# -ne 1 ]] || [[ ! " ${OPERATIONS[@]} " =~ " $1 " ]]; then
  echo "ABORTING: Invalid arguments. Please specify one of the following: ${OPERATIONS[@]}"
  exit 1
fi

# abort if terraform is not installed and executable
if ! command -v terraform &> /dev/null; then
  echo "ABORTING: terraform is not installed or not executable."
  exit 1
fi

# MEANT TO BE RUN USING PACKAGE.JSON SCRIPTS

cd $TERRAFORM_INFRA_PATH

if [ ! -f .env ]; then
  printf "ABORTING: The %s/.env file does not exist. Please create it and try again.\n" $TERRAFORM_INFRA_PATH
  printf "\tThe file should have a GOOGLE_PROJECT_ID, GOOGLE_REGION, and GOOGLE_CLUSTER_ZONE variable(s)."
  exit 1
fi

echo "backing up $TERRAFORM_INFRA_PATH/main.tf to $TERRAFORM_INFRA_PATH/main.tf.bak..."
cp main.tf main.tf.bak
echo "Finished backing up $TERRAFORM_INFRA_PATH/main.tf."

echo "Replacing environment variables in $TERRAFORM_INFRA_PATH/main.tf..."
# using sed, replace the environment variables in the yaml files
# for each key=value pair in the .env file, replace in the file occurrences of '#KEY#' with 'value'
for i in $(cat .env); do
  key=$(echo $i | cut -d'=' -f1)
  value=$(echo $i | cut -d'=' -f2)
  sed -i "s/#$key#/$value/g" main.tf
done
echo "Finished replacing environment variables in $TERRAFORM_INFRA_PATH/main.tf"

case $1 in
"init-upgrade")
  echo "Running terraform init(-upgrade) command..."
  terraform init -upgrade || echo "terraform init command failed."
  echo "Finished running terraform init(-upgrade) command."
  ;;
"plan")
  echo "Running terraform plan command..."
  terraform validate && terraform plan || echo "terraform plan command failed."
  echo "Finished running terraform plan command."
  ;;
"apply")
  echo "Running terraform apply command..."
  terraform validate && terraform apply -auto-approve || echo "terraform apply command failed."
  echo "Finished running terraform apply command."
  ;;
"destroy")
  echo "Running terraform destroy command..."
  terraform validate && terraform destroy -auto-approve || echo "terraform destroy command failed."
  echo "Finished running terraform destroy command."
  ;;
esac

echo "Restoring $TERRAFORM_INFRA_PATH/main.tf from $TERRAFORM_INFRA_PATH/main.tf.bak..."
rm main.tf
mv main.tf.bak main.tf
