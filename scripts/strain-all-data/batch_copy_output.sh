#! /bin/bash

dir_study="/home/jileihao/data/strain/Strain_alldata/studies"
dir_output="/home/jileihao/data/strain/Strain_alldata/output"

for study_dir in ${dir_study}/*
do
  # extract study name
  study=$(basename "$study_dir")

  dir_study_output="$dir_output/$study"

  # create output directory
  mkdir -p "$dir_study_output"

  # copy data from study_dir/output/strain/medial_recon_and_strain/Strains to dir_study_output
  if [ -d "$study_dir/output/strain/medial_recon_and_strain/Strains" ]; then
    echo "Copying data for study: $study"
    cp -r "$study_dir/output/strain/medial_recon_and_strain/Strains/"* "$dir_study_output/"
  else
    echo "No Strains directory found for study: $study"
  fi
done