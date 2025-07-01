#! /bin/bash

study_root="/home/jileihao/data/strain/Strain_alldata/studies"

studies_to_exclude=(
  # "bav001"
)

studies_to_include=(
bav026
bav046
bav053
)

p_run_on_include=1

p_use_existing_propagation=0

# Source conda to make it available in this script
source ~/tk/miniconda3/etc/profile.d/conda.sh
conda activate general_390

for study_dir in ${study_root}/*
do
  #extract study name
  study=$(basename "$study_dir")

  echo "----------------------------------------"
  echo "Running study: $study"
  echo "----------------------------------------"
  echo ""

  if [[ $p_run_on_include -eq 1 && ! " ${studies_to_include[@]} " =~ " ${study} " ]]; then
    echo "Skipping study: $study (not in include list)"
    continue
  fi

  if [[ " ${studies_to_exclude[@]} " =~ " ${study} " ]]; then
    echo "Skipping study: $study"
    continue
  fi
  

  cd $study_dir

  # execute run.sh and redirect output to the log file
  time bash ./run.sh $p_use_existing_propagation > run_standalone_strain.log 2>&1
done