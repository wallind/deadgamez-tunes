#!/usr/bin/env sh

K8S_INFRA_PATH="infra/k8s"
OPERATIONS=("apply" "destroy")

# abort if there isn't exactly one argument and it isn't either apply or destroy
if [[ $# -ne 1 ]] || [[ ! " ${OPERATIONS[@]} " =~ " $1 " ]]; then
  echo "ABORTING: Invalid arguments. Please specify one of the following: ${OPERATIONS[@]}"
  exit 1
fi

# abort if kubectl is not installed and executable
if ! command -v kubectl &> /dev/null; then
  echo "ABORTING: kubectl is not installed or not executable."
  exit 1
fi

cd $K8S_INFRA_PATH
# MEANT TO BE RUN USING PACKAGE.JSON SCRIPTS

if [ ! -f .env ]; then
  printf "ABORTING: The infra/k8s/.env file does not exist. Please create it and try again.\n"
  printf "\tThe file should have a GOOGLE_PROJECT_ID and LETSENCRYPT_EMAIL variables."
  exit 1
fi

echo "backing up $K8S_INFRA_PATH/*.yml files to $K8S_INFRA_PATH/backup/*..."
mkdir -p backup
cp *.yml backup/
echo "Finished backing up $K8S_INFRA_PATH/*.yml files."

echo "Replacing environment variables in $K8S_INFRA_PATH/*.yml files..."
# using sed, replace the environment variables in the yaml files
# for each key=value pair in the .env file, replace in the file occurrences of '#KEY#' with 'value'
for i in $(cat .env); do
  key=$(echo $i | cut -d'=' -f1)
  value=$(echo $i | cut -d'=' -f2)
  sed -i "s/#$key#/$value/g" *.yml
done
echo "Finished replacing environment variables in $K8S_INFRA_PATH/*.yml files."

case $1 in
"destroy")
  echo "Running kubectl delete command..."
  kubectl delete -k . || echo "kubectl delete command failed."
  echo "Finished running kubectl delete command."
  ;;
"apply")
  echo "Running kubectl apply command..."
  kubectl apply -k . || echo "kubectl apply command failed."
  echo "Finished running kubectl apply command."
  ;;
esac

echo "Restoring $K8S_INFRA_PATH/*.yml files from $K8S_INFRA_PATH/backup/*..."
rm *.yml
mv backup/*.yml .
