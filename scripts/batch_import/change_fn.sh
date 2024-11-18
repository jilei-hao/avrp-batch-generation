#! /bin/bash

folder="/Users/jileihao/dev/avrspt-dev/avrp-batch-generation/studies/bavcta005/scan2/output"

cd $folder

for f in mesh_med_recon*.vtp; do
  echo "Processing $f"
  # extract tp between tp_ and .
  tp=$(echo $f | sed -n 's/.*tp_\([0-9]*\)\..*/\1/p')
  echo "tp: $tp"
  new_fn="medial-root-strain_tp_${tp}.vtp"
  mv $f $new_fn
done