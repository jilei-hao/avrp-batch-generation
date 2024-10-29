
# # all studies
# v_studies=(
#   "bav001-4DTEE"
#   "bav003-4DTEE"
#   "bav009-4DTEE"
#   "bav010-4DTEE"
#   "bav013-4DTEE"
#   "bav016-4DTEE"
#   "bav024-4DTEE"
#   "bav031-4DTEE"
#   "bav032-4DTEE"
#   "bav037-4DTEE"
#   "bav042-4DTEE"
#   "bav044-4DTEE"
#   "bav045-4DTEE"
#   "bav052-4DTEE"
#   "tav029-4DTEE"
#   "tav049-4DTEE"
#   "tav050-4DTEE"
#   "tav051-4DTEE"
#   "tav052-4DTEE"
#   "tav054-4DTEE"
#   "tav058-4DTEE"
#   "tav059-4DTEE"
#   "tav060-4DTEE"
# )

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
v_batch_output_dir=/home/jileihao/dev/spt-dev/avrp-batch-generation/output/batch_strain_output

# if v_batch_output_dir exists, archive it by appending YYMMDD-HHMMSS to the folder name
if [ -d $v_batch_output_dir ]; then
  # get existing folder creation data time
  creation_time=$(stat -c %y $v_batch_output_dir)
  creation_time=${creation_time:0:16}
  mv $v_batch_output_dir $v_batch_output_dir-$(date +"%y%m%d-%H%M%S" -d "$creation_time")
fi

mkdir -p $v_batch_output_dir

for study in "${v_studies[@]}"
do
  echo "----------------------------------------"
  echo "Running study: $study"
  echo "----------------------------------------"
  echo ""
  
  v_dir_study=$v_dir_study_root/$study
  v_dir_study_output=$v_batch_output_dir/$study

  # create output directory for the study
  mkdir -p $v_dir_study_output

  echo "Study directory: $v_dir_study"
  cd $v_dir_study

  # copy auto result
  cp -r $v_dir_study/output/strain/auto/medial_recon_and_strain/Strains $v_dir_study_output/auto

  # copy manual result
  cp -r $v_dir_study/output/strain/manual/medial_recon_and_strain/Strains $v_dir_study_output/manual

done