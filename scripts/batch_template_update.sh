# studies to run
v_studies=(
  "bav001-4DTEE"
  "bav003-4DTEE"
  "bav009-4DTEE"
  "bav010-4DTEE"
  "bav013-4DTEE"
  "bav016-4DTEE"
  "bav024-4DTEE"
  "bav031-4DTEE"
  "bav032-4DTEE"
  "bav037-4DTEE"
  "bav042-4DTEE"
  "bav044-4DTEE"
  "bav045-4DTEE"
  "bav052-4DTEE"
  "tav029-4DTEE"
  "tav049-4DTEE"
  "tav050-4DTEE"
  "tav051-4DTEE"
  "tav052-4DTEE"
  "tav054-4DTEE"
  "tav058-4DTEE"
  "tav059-4DTEE"
  "tav060-4DTEE"
)

v_dir_study_root=/home/jileihao/dev/spt-dev/avrp-batch-generation/studies

v_template_path=/home/jileihao/dev/spt-dev/avrp-batch-generation/templates/template__run_strain_v2.sh

for study in "${v_studies[@]}"
do
  echo "----------------------------------------"
  echo "Running study: $study"
  echo "----------------------------------------"
  echo ""
  
  v_dir_study=$v_dir_study_root/$study
  echo "Study directory: $v_dir_study"
  cd $v_dir_study

  # execute run_strain.sh and redirect output to the log file
  v_fn_run_strain=run_strain.sh

  # remove existing run_strain.sh
  if [ -f $v_fn_run_strain ]; then
    rm $v_fn_run_strain
  fi

  # copy the template to the study directory
  cp $v_template_path $v_fn_run_strain
  
done