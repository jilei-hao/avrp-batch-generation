#! /bin/bash

# get project directory
DIR=/Users/jileihao/dev/avrspt-dev/avrp-handler

# get the path to the global measurement file
gm="$DIR/src/modules/measurement/global_measurements.py"

# get data dir
data_dir="/Users/jileihao/dev/avrspt-dev/avrp-batch-generation/studies/bavcta010/baseline/output"

# add src to python path
export PYTHONPATH=$DIR


# execute
python3 $gm --fusionType "LR" \
--outputDir $data_dir \
--labelModels \
"$data_dir/mesh_lb01_tp01.vtp" \
"$data_dir/mesh_lb02_tp01.vtp" \
"$data_dir/mesh_lb03_tp01.vtp" \
"$data_dir/mesh_lb04_tp01.vtp" \
"$data_dir/mesh_lb05_tp01.vtp" \
"$data_dir/mesh_lb06_tp01.vtp"