#! /bin/bash

# include global and local configs
source ../../configs/env.sh
source ./scripts/config.sh

echo "ENV_GREEDY_PROPAGATION_PATH:  $ENV_GREEDY_PROPAGATION_PATH"
echo "ENV_STRAIN_PATH:              $ENV_STRAIN_PATH"


out_root="./output/strain"
out_auto="$out_root/auto"
out_manual="$out_root/manual"

mkdir -p $out_auto
mkdir -p $out_manual

$ENV_GREEDY_PROPAGATION_PATH -spi ./i4.nii.gz \
-sps ./srs_a.nii.gz \
-spo $out_auto \
-sps-op "seg_%02d_resliced.nii.gz" \
-sps-mop "seg-mesh_%02d_resliced.vtk" \
-spr $CONFIG_TPR_FULL \
-spt $CONFIG_TPT_FULL \
-sp-verbose 2
