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
echo "-- ENV_RUN_PROPAGATION_PTH:       $ENV_RUN_PROPAGATION_PATH"
echo "-- ENV_STRAIN_PATH:               $ENV_STRAIN_PATH"
echo "-- CONFIG_TPR:                    $CONFIG_TPR"
echo "-- CONFIG_TPT:                    $CONFIG_TPT"
echo

# 1 or 0
p_use_existing_propagation=$1
if [ -z "$p_use_existing_propagation" ]; then
  p_use_existing_propagation=0
fi

echo
echo "-- Use Existing Propagation: $p_use_existing_propagation"
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
p_tp_start=$(echo $p_full_target_tps | cut -d',' -f1)
p_tp_end=$(echo $p_full_target_tps | awk -F',' '{print $NF}')

read p_tp_open p_tp_close <<< \
  $(python3 "../../util/get_open_close_tps.py" "${CONFIG_TPR_SYS:-}" "${CONFIG_TPT_SYS:-}" "${CONFIG_TPR_DIAS:-}" "${CONFIG_TPT_DIAS:-}")

echo
echo "Parameters:";
echo "-- Segmentation Reference Base:  $p_seg_ref_base"
echo "-- Reference TP:                 $p_tpr"
echo "-- Full Target TPS:              $p_full_target_tps"
echo "-- TP Open:                      $p_tp_open"
echo "-- TP Close:                     $p_tp_close"
echo "-- TP Start:                     $p_tp_start"
echo "-- TP End:                       $p_tp_end"
echo


# output directories
out_root="./output/strain"
run_types=("auto" "manual")
matlab_path_string="addpath('$ENV_STRAIN_PATH'); addpath('$ENV_STRAIN_SCRIPT_PATH');"

# for each run_type, run following steps
for run_type in "${run_types[@]}"; do
  # defining all file names here
  out_dir="$out_root/$run_type"
  short_run_type=${run_type:0:1} # a for auto, m for manual, etc.
  p_fn_mesh_ref="$out_dir/mesh_ref.vtk"
  p_fn_seg_ref="./${p_seg_ref_base}_${short_run_type}.nii.gz"
  p_fn_seg_ref_wo_lumen="$out_dir/${p_seg_ref_base}_wo_lumen_${short_run_type}.nii.gz"
  p_fn_mesh_bnd="$out_dir/segref_bnd.vtk"
  p_fn_mesh_med="$out_dir/segref_med.vtk"
  v_propa_out_dir="$out_dir/propagation"
  p_medial_recon_out_dir="$out_dir/medial_recon_and_strain"
  v_mesh_bnd_pattern='mesh_bnd_tp'
  v_mesh_med_recon_pattern='mesh_med_recon_tp'
  v_ref_tp_string=$(printf "%03d" $p_tpr)
  v_path_medial_recon_ref=$p_medial_recon_out_dir/${v_mesh_med_recon_pattern}_${v_ref_tp_string}.vtk
  p_strain_out_dir=$(realpath $p_medial_recon_out_dir)


  echo
  echo "--------------------------------------------------"
  echo "Running: $run_type "
  echo "--------------------------------------------------"
  echo

  if [ $p_use_existing_propagation -eq 0 ]; then
    # if out_auto and out_manual exist, archive them by appending YYMMDD-HHMMSS to the folder name
    if [ -d $out_dir ]; then
      # get existing folder creation data time
      creation_time=$(stat -c %y $out_dir)
      creation_time=${creation_time:0:16}
      mv $out_dir $out_dir-$(date +"%y%m%d-%H%M%S" -d "$creation_time")
    fi

    mkdir -p $out_dir

    # STEP 1: MERGE ROOT LABELS --------------------------------------------------
    echo "-- Remove Lumen ..."
    python3 ../../util/remove_lumen.py $p_fn_seg_ref $p_fn_seg_ref_wo_lumen 3 > /dev/null


    # STEP 2: CREATE LABEL MESH --------------------------------------------------
    echo "-- Creating Label Mesh ..."
    $ENV_LABEL_MODEL_GEN_PATH $p_fn_seg_ref_wo_lumen $p_fn_mesh_ref > /dev/null


    # STEP 3: CREATE MEDIAL MESH -------------------------------------------------
    echo "-- Creating Medial Mesh ..."
    matlab -batch "$matlab_path_string medial_mesh_generic('$p_fn_mesh_ref', '$p_fn_mesh_med','$p_fn_mesh_bnd', '1', '2', '4')"
    
    # STEP 4: RUN PROPAGATION ----------------------------------------------------
    echo "-- Running Propagation ..."
    
    mkdir -p $v_propa_out_dir
    $ENV_RUN_PROPAGATION_PATH \
      -i i4.nii.gz \
      -s $p_fn_seg_ref_wo_lumen \
      -tpr $p_tpr \
      -tpt $p_full_target_tps \
      -em "bnd" "$p_fn_mesh_bnd" \
      -em "med" "$p_fn_mesh_med" \
      -o $v_propa_out_dir
  else
    # if output directory does not exist, exit
    if [ ! -d $v_propa_out_dir ]; then
      echo
      echo "Error: Output directory does not exist: $v_propa_out_dir! Cannot use existing propagation. Exiting ..."
      echo
      exit 1
    fi
    
    echo "-- Using Existing Propagation ..."
  fi

  # STEP 5: CREATE MEDIAL MESH FROM BOUNDARY MESH -----------------------------
  echo "-- Creating Medial Mesh from Boundary Mesh ..."
  mkdir -p $p_medial_recon_out_dir

  # copy the boundary mesh to the medial recon folder
  cp $v_propa_out_dir/${v_mesh_bnd_pattern}*.vtk $p_medial_recon_out_dir

  matlab -batch "$matlab_path_string \
    medial_recon_from_bnd_generic('$p_medial_recon_out_dir', '$v_mesh_bnd_pattern','$v_mesh_med_recon_pattern', \
    '$p_fn_mesh_bnd', '$p_fn_mesh_med', '$p_tpr', '$p_tp_start', '$p_tp_end')"

  # if the reference medial mesh does not exist, copy reference medial mesh to the medial recon folder 
  if [ ! -f $v_path_medial_recon_ref ]; then
    cp $p_fn_mesh_med $v_path_medial_recon_ref
  fi

  # STEP 6: Run Strain Analysis -----------------------------------------------
  echo "-- Running Strain Analysis ..."
  v_current_dir=$(pwd)

  
  cd $ENV_STRAIN_PATH
  # if p_tp_open equals to p_tp_start, call strain with tp_open = tp_start + 1 tp_ref = tp_open
  if [ $p_tp_open -eq $p_tp_start ]; then
    v_new_tp_open=$((p_tp_open + 1))
    python3 $ENV_STRAIN_SCRIPT_PATH/compute_strain.py $p_strain_out_dir $p_frame_time_in_ms $v_new_tp_open $p_tp_close $p_tp_open
  else
    python3 $ENV_STRAIN_SCRIPT_PATH/compute_strain.py $p_strain_out_dir $p_frame_time_in_ms $p_tp_open $p_tp_close
  fi
  
  cd $v_current_dir

done