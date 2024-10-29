#! /bin/bash

{ 
  time bash ./run_batch_strain.sh > ../logs/run_strain_241026.log 2>&1; 
} 2>../logs/time_241026.log