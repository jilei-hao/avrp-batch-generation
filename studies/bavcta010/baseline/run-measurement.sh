#! /bin/bash

# add python path
proj_dir=/Users/jileihao/dev/avrspt-dev/automatic_measurement/automatic_measurement

export PYTHONPATH=$PYTHONPATH:$proj_dir

script_dir="$proj_dir/scripts"

# Redirect stdout and stderr to a log file
exec > ./run_measurement.log 2>&1

# remesh=$script_dir/remesh.py
# coaptation=$script_dir/coaptation.py
# commissural_angle=$script_dir/commissural_angle.py
# cusp_area=$script_dir/cusp_area.py
# fml=$script_dir/fml.py
# geometric_height=$script_dir/geometric_height.py

# python3 $coaptation --path ./output/assembled_mesh_tp01.vtp --leaflet L --separate 1
generator=$script_dir/avrp_cs_generator.py 
# fused_labels="1,3"

# process for all time points
# for f in ./output/assembled_mesh_tp*.vtp; do 
#   tp=$(echo $f | sed 's/.*_tp\([0-9]*\).vtp/\1/')
#   echo "Processing time point $tp"
#   python3 $generator -i $f -o ./output -fl "1,3" -tp $tp
# done

# process for all time points (parallel)
find ./output -name 'assembled_mesh_tp*.vtp' | sed 's/.*_tp\([0-9]*\).vtp/\1/' | while read tp; do
  echo "python3 $generator -i ./output/assembled_mesh_tp${tp}.vtp -fl 1,3 -o ./output -tp $tp"
done | xargs -P 8 -I {} bash -c "{}"

