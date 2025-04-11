####################################################################################################
# PREPARATION
####################################################################################################

# include global and local configs
source ../../configs/env.sh
source ./config.sh

echo
echo "## Run Studygen Started"
echo
echo "Environment Variables:"
echo "-- ENV_STUDYGEN_PATH             $ENV_STUDYGEN_PATH"
echo "-- CONFIG_TPR_SYS:               $CONFIG_TPR_SYS"
echo "-- CONFIG_TPT_SYS:               $CONFIG_TPT_SYS"
echo "-- CONFIG_TPR_DIAS:              $CONFIG_TPR_DIAS"
echo "-- CONFIG_TPT_DIAS:              $CONFIG_TPT_DIAS"
echo

# create output dir if not exists
dir_out=./output/studygen
mkdir -p $dir_out


$ENV_STUDYGEN_PATH \
  -i i4.nii.gz \
  -o $dir_out \
  -s srd.nii.gz \
  -s_ref $CONFIG_TPR_DIAS \
  -s_tgt $CONFIG_TPT_DIAS \
  -s srs.nii.gz \
  -s_ref $CONFIG_TPR_SYS \
  -s_tgt $CONFIG_TPT_SYS