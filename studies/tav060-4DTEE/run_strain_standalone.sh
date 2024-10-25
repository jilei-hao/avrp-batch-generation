#! /bin/bash

source ../../configs/env.sh
source ./config.sh

echo "-- Running Standalone Strain Analysis ..."
echo "---- Running Auto ... "

read p_tp_open p_tp_close <<< \
  $(python3 "../../util/get_open_close_tps.py" "${CONFIG_TPR_SYS:-}" "${CONFIG_TPT_SYS:-}" "${CONFIG_TPR_DIAS:-}" "${CONFIG_TPT_DIAS:-}")

# output directories
out_root="./output/strain"
run_types=("auto" "manual")

# for each run_type, run following steps
for run_type in "${run_types[@]}"; do
  out_dir="$out_root/$run_type"

  p_medial_recon_out_dir="$out_dir/medial_recon_and_strain"
  p_frame_time_in_ms=50

  p_strain_out_dir=$(realpath $p_medial_recon_out_dir)
  v_current_dir=$(pwd)
  cd $ENV_STRAIN_PATH
  python3 $ENV_STRAIN_PATH/compute_strain.py $p_strain_out_dir $p_frame_time_in_ms $p_tp_open $p_tp_close
  cd $v_current_dir
done