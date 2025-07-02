#! /bin/bash

fn_template=/home/jileihao/dev/spt-dev/avrp-batch-generation/scripts/strain-all-data/template__run_strain_standalone.sh
study_root=/home/jileihao/data/strain/Strain_alldata/studies


for study_dir in ${study_root}/*
do
  # if run.sh already exists, overwrite it
  if [ -f "$study_dir/run.sh" ]; then
    echo "run.sh already exists in $study_dir, overwriting..."
  else
    echo "Creating run.sh in $study_dir..."
  fi

  # Copy the template script to the study directory
  cp $fn_template $study_dir/run.sh
done