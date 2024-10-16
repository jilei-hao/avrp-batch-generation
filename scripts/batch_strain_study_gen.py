# Generates studies for the strain pipeline

import os
import sys
import json

def generate_study(config_entry, dirStudyRoot, fnTemplate):
  case_name = config_entry[0]
  study_name = config_entry[1]
  tp_ref_sys = config_entry[2]
  tp_tgt_sys = config_entry[3]
  tp_ref_dias = config_entry[4]
  tp_tgt_dias = config_entry[5]

  dirStudy = os.path.join(dirStudyRoot, f"{case_name}-{study_name}")

  if os.path.exists(dirStudy):
    print(f"Study {case_name}-{study_name} already exists. Skipping.")
    return

  # create the study directory
  os.makedirs(dirStudy)

  # copy the template file to the study directory and rename it to run_strain.sh
  fnRunScript = os.path.join(dirStudy, "run_strain.sh")
  os.system(f"cp {fnTemplate} {fnRunScript}")

  # create and write config.sh
  fnConfig = os.path.join(dirStudy, "config.sh")
  with open(fnConfig, 'w') as f:
    f.write(f"CONFIG_TPR_SYS=\"{tp_ref_sys}\"\n")
    f.write(f"CONFIG_TPT_SYS=\"{tp_tgt_sys}\"\n")
    f.write(f"CONFIG_TPR_DIAS=\"{tp_ref_dias}\"\n")
    f.write(f"CONFIG_TPT_DIAS=\"{tp_tgt_dias}\"\n")



# read the config json from the arguments
def generate_studies():
  fnConfig = sys.argv[1]
  dirStudyRoot = sys.argv[2]
  fnTemplate = sys.argv[3]

  with open(fnConfig, 'r') as f:
    config = json.load(f)
  
  # print out the config
  print(json.dumps(config, indent=2))

  # iterate through the elements in the config array
  for i in range(len(config)):
    studyEntry = config[i]
    
    generate_study(studyEntry, dirStudyRoot, fnTemplate)




    


if __name__ == "__main__":
  generate_studies()