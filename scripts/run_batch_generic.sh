
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

for study in "${v_studies[@]}"
do
  echo "----------------------------------------"
  echo "Running study: $study"
  echo "----------------------------------------"
  echo ""
  
  v_dir_study=$v_dir_study_root/$study
  echo "Study directory: $v_dir_study"
  cd $v_dir_study

  # put generic command here
  rm srs_m.nii.gz
done