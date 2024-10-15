#! /bin/bash

# include global and local configs
source ../../configs/env.sh
source ./config.sh

echo "ENV_RUN_PROPAGATION_PTH:      $ENV_RUN_PROPAGATION_PATH"
echo "ENV_STRAIN_PATH:              $ENV_STRAIN_PATH"


out_root="./output/strain"
out_auto="$out_root/auto"
out_manual="$out_root/manual"

mkdir -p $out_auto
mkdir -p $out_manual


$ENV_RUN_PROPAGATION_PATH \
-i i4.nii.gz \
-s srs_a.nii.gz \
-o $out_auto \
-tpr $CONFIG_TPR_FULL \
-tpt $CONFIG_TPT_FULL 