#! /bin/bash

dir_study="/home/jileihao/data/strain/Strain_alldata/studies"

error_studies=()

for study_dir in ${dir_study}/*
do
  # extract study name
  study=$(basename "$study_dir")
  
  # parse run_standalone_strain.log for errors
  log_file="$study_dir/run_standalone_strain.log"
  if [ -f "$log_file" ]; then
    echo "----------------------------------------"
    echo "Checking log for study: $study"
    echo "----------------------------------------"
    echo ""

    # Check for errors in the log file
    if grep -q "Error" "$log_file"; then
      error_studies+=("$study")
    fi
  else
    echo "Log file not found for study: $study"
    error_studies+=("$study")
  fi
done

if [ ${#error_studies[@]} -gt 0 ]; then
  echo "----------------------------------------"
  echo "Studies with errors found:"
  for study in "${error_studies[@]}"; do
    echo "$study"
  done
  echo "----------------------------------------"
else
  echo "No errors found in any studies."
fi