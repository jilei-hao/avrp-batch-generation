#! /bin/bash

####################################################################################################
# PREPARATION
####################################################################################################

# include global and local configs
source ../../configs/env.sh
source ./config.sh

echo
echo "## Strain Pipeline Started"
echo
echo "Environment Variables:"
echo "-- ENV_RUN_PROPAGATION_PTH:      $ENV_RUN_PROPAGATION_PATH"
echo "-- ENV_STRAIN_PATH:              $ENV_STRAIN_PATH"
echo "-- CONFIG_TPR_SYS:               $CONFIG_TPR_SYS"
echo "-- CONFIG_TPT_SYS:               $CONFIG_TPT_SYS"
echo "-- CONFIG_TPR_DIAS:              $CONFIG_TPR_DIAS"
echo "-- CONFIG_TPT_DIAS:              $CONFIG_TPT_DIAS"
echo


# parameters for the script
p_frame_time_in_ms=50

if [ -n "$CONFIG_TPR_SYS" ]; then
  p_seg_ref_base="srs"
  p_tpr=$CONFIG_TPR_SYS
elif [ -n "$CONFIG_TPR_DIAS" ]; then
  p_seg_ref_base="srd"
  p_tpr=$CONFIG_TPR_DIAS
else
  echo "Error: Missing reference TP. Both CONFIG_TPR_SYS and CONFIG_TPR_DIAS are empty."
  exit 1
fi

# Use parameter expansion to provide default empty string if variables are unset
p_full_target_tps=$(python3 ../../util/get_full_target_tps.py "${CONFIG_TPT_SYS:-}" "${CONFIG_TPT_DIAS:-}")

read p_tp_open p_tp_close <<< \
  $(python3 "../../util/get_open_close_tps.py" "${CONFIG_TPR_SYS:-}" "${CONFIG_TPT_SYS:-}" "${CONFIG_TPR_DIAS:-}" "${CONFIG_TPT_DIAS:-}")

echo
echo "Parameters:";
echo "-- Segmentation Reference Base:  $p_seg_ref_base"
echo "-- Reference TP:                 $p_tpr"
echo "-- Full Target TPS:              $p_full_target_tps"
echo "-- TP Open:                      $p_tp_open"
echo "-- TP Close:                     $p_tp_close"
echo




# output directories
out_root="./output/strain"
run_types=("auto" "manual")

# for each run_type, run following steps
for run_type in "${run_types[@]}"; do
  out_dir="$out_root/$run_type"

  short_run_type=${run_type:0:1}

  p_fn_seg_ref="./${p_seg_ref_base}_${short_run_type}.nii.gz"
  p_fn_mesh_bnd="$out_dir/segref_bnd.vtk"
  p_fn_mesh_med="$out_dir/segref_med.vtk"

  # if out_auto and out_manual exist, archive them by appending YYMMDD-HHMMSS to the folder name
  if [ -d $out_dir ]; then
    mv $out_dir $out_dir-$(date +"%y%m%d-%H%M%S")
  fi

  mkdir -p $out_dir

  echo
  echo "Running: $run_type "

  # STEP 1: CREATE LABEL MESH -------------------------------------------------
  echo "-- Creating Label Mesh ..."
  $ENV_LABEL_MODEL_GEN_PATH $p_fn_seg_ref $p_fn_mesh_bnd > /dev/null

  


done

# $ENV_RUN_PROPAGATION_PATH \
# -i i4.nii.gz \
# -s srs_a.nii.gz \
# -o $out_auto \
# -tpr $CONFIG_TPR_FULL \
# -tpt $CONFIG_TPT_FULL 