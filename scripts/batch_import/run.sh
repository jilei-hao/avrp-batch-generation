#! /bin/bash

ENV_PROJECT_ROOT=/Users/jileihao/dev/avrspt-dev/avrp-batch-generation

# import environment variables
source $ENV_PROJECT_ROOT/configs/env.sh

echo "study root: $ENV_STUDY_ROOT"
echo "gateway URL: $ENV_GATEWAY_URL"
echo "dataserver URL: $ENV_DATASERVER_URL"

v_import_script="$ENV_PROJECT_ROOT/scripts/batch_import/import_study.js"


# redirect stdout and stderr to a log file
exec > $ENV_PROJECT_ROOT/logs/run_batch_import.log 2>&1

## all studies
# studies_dirs=("$study_root/bavcta003/scan3" \
#   "$study_root/bavcta003/scan4" \
#   "$study_root/bavcta005/scan2" \
#   "$study_root/bavcta007/baseline" \
#   "$study_root/bavcta008/baseline" \
#   "$study_root/bavcta010/baseline" \
#   "$study_root/bavcta013/baseline" \
#   "$study_root/bavcta015/baseline" \
#   "$study_root/bavcta016/baseline" \
#   "$study_root/bav16/pre-op-TEE" \
#   "$study_root/bav17/pre-op-TEE" \
#   "$study_root/bav20/pre-op-TEE" \
#   "$study_root/bav24/pre-op-TEE" \
#   "$study_root/bav32/pre-op-TEE" \
#   "$study_root/bav38/pre-op-TEE" \
#   "$study_root/bav44/pre-op-TEE")

## active studies
studies_dirs=("$ENV_STUDY_ROOT/bavcta005/scan2")

echo "Start batch importing studies"


for sdir in "${studies_dirs[@]}"; do
  cd $sdir

  ## get the folder name of current directory
  sn=$(basename $PWD)

  ## get the folder name of the parent directory
  cn=$(basename $(dirname $PWD))

  echo
  echo "------------------------------------------------------------------------"
  echo "-- Start Importing $cn/$sn"

  ## if ./output not exist, skip
  if [ ! -d "./output" ]; then
    echo "output folder does not exist, skip"
    continue
  fi

  ## execute batch_import.js if any error happens, continue to next study
  if ! node $v_import_script -cn $cn -sn $sn -data $PWD/output; then
    echo "Error happens, continue to next study"
    continue
  fi

  echo "-- Finish Importing $cn/$sn"
done