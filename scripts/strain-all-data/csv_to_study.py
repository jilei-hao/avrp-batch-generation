import os
import sys
import csv

def parse_csv(fn_csv):
  """
  Parses a CSV file and returns a list of dictionaries with the data.
  Each dictionary corresponds to a row in the CSV file.
  """
  config = []
  with open(fn_csv, 'r', encoding='utf-8-sig') as f:  # Use 'utf-8-sig' to handle BOM
    reader = csv.DictReader(f)
    for row in reader:
      # Remove BOM from the first key if present
      if '\ufeff' in row:
        row = {key.lstrip('\ufeff'): value for key, value in row.items()}
      config.append(row)
  return config


def create_symlink(dir_input_files, study_id, dir_study, fn_dest):
  """
  Creates a symlink for the input files in the study folder.
  The symlink points to the original file in the input directory.
  """
  # -- find the image file contains the study ID
  image_files = [f for f in os.listdir(dir_input_files) if study_id in f]
  if len(image_files) == 0:
    print(f"Image file for study ID {study_id} not found, skipping...")
    return
  elif len(image_files) > 1:
    print(f"Multiple image files found for study ID {study_id}: {image_files}, skipping...")
    return
  
  fn_image = image_files[0]
  fn_image_path = os.path.join(dir_input_files, fn_image)
  fn_image_dest = os.path.join(dir_study, fn_dest)
  if not os.path.exists(fn_image_dest):
    os.symlink(fn_image_path, fn_image_dest)
    print(f"Created symlink for image: {fn_image_dest}")
  else:
    print(f"Image symlink already exists: {fn_image_dest}")


def create_config_file(dir_study, config):
  """
  Creates a configuration file in the study folder.
  The configuration file contains the reference frame and the list of frames.
  """
  tp_ref = config['tp_ref']
  tp_list = config['tp_list']
  tp_start = config['tp_start']
  tp_end = config['tp_end']
  tp_open = config['tp_open']
  tp_close = config['tp_close']

  # create the config file
  fn_config = os.path.join(dir_study, "config.sh")
  with open(fn_config, 'w') as f:
    f.write(f"CONFIG_TPR=\"{tp_ref}\"\n")
    f.write(f"CONFIG_TPT=\"{','.join(map(str, tp_list))}\"\n")
    f.write(f"CONFIG_TP_START=\"{tp_start}\"\n")
    f.write(f"CONFIG_TP_END=\"{tp_end}\"\n")
    f.write(f"CONFIG_TP_OPEN=\"{tp_open}\"\n")
    f.write(f"CONFIG_TP_CLOSE=\"{tp_close}\"\n")


def generate_one_study(config_row, dir_input, dir_study_root):
  """
  Generates a study folder based on the configuration row.
  Each study folder is created in the study root directory.
  """
  study_id = config_row['Study_ID']
  tp_ref_sys = int(config_row['Systole_Ref_Frame']) if config_row['Systole_Ref_Frame'].isdigit() else None
  tp_list_sys = [int(tp) for tp in config_row['Systole_Frames'].split(',')]
  tp_ref_dias = int(config_row['Diastole_Ref_Frame']) if config_row['Diastole_Ref_Frame'].isdigit() else None
  tp_list_dias = [int(tp) for tp in config_row['Diastole_Frames'].split(',')]

  tp_ref = tp_ref_sys if tp_ref_sys is not None else tp_ref_dias
  tp_list = sorted(set(tp_list_sys + tp_list_dias))

  if tp_ref is None:
    print(f"Reference frame for study ID {study_id} is None, skipping...")
    return
  
  # determine start, end, open and close
  tp_start = min(tp_list)
  tp_end = max(tp_list)
  tp_open = tp_list_sys[0]
  tp_close = next((tp for tp in tp_list_dias if tp > tp_open), None)

  print(f"-- Study ID: {study_id}")
  print(f"   Reference Frame: {tp_ref}")
  print(f"   Tp List: {tp_list}")
  print(f"   Start: {tp_start}, End: {tp_end}, Open: {tp_open}, Close: {tp_close}")


  # Create the study folder
  dir_study = os.path.join(dir_study_root, study_id)
  if not os.path.exists(dir_study):
    os.makedirs(dir_study)
    print(f"Created study folder: {dir_study}")
  else:
    print(f"Study folder already exists: {dir_study}")


  # Link image to the study folder
  dir_input_images = os.path.join(dir_input, "image_4d")
  create_symlink(dir_input_images, study_id, dir_study, 'i4.nii.gz')

  
  # Link segmentation to the study folder
  dir_input_segmentation = os.path.join(dir_input, "reference_segmentation")
  create_symlink(dir_input_segmentation, study_id, dir_study, 'sr.nii.gz')


  # Create the config file
  config = {
    "tp_ref": tp_ref,
    "tp_list": tp_list,
    "tp_start": tp_start,
    "tp_end": tp_end,
    "tp_open": tp_open,
    "tp_close": tp_close
  }
  create_config_file(dir_study, config)



def generate_studies(config, dir_input, dir_study_root):
  """
  Generates study folders based on the configuration.
  Each study folder is created in the study root directory.
  """
  for config_row in config:
    generate_one_study(config_row, dir_input, dir_study_root)


def main():
  # VALIDATE INPUTS 
  # get the path to the csv file from the first argument
  if len(sys.argv) != 3:
    print("Usage: python csv_to_study.py <path to the input folder> <path to study root>")
    sys.exit(1)

  dir_input = sys.argv[1]
  if not os.path.isdir(dir_input):
    print(f"File {dir_input} does not exist")
    sys.exit(1)


  # get the study root for creating study folders
  dir_study_root = sys.argv[2]
  if not os.path.isdir(dir_study_root):
    #create the study root if it does not exist
    os.makedirs(dir_study_root)
    print(f"Created study root folder: {dir_study_root}")


  # PRASE THE CSV FILE
  config = parse_csv(os.path.join(dir_input, "study_config.csv"))
  print("Parsed config:", config)

  if config is None:
    print(f"Failed to parse the CSV file")
    sys.exit(1)

  # GENERATE STUDIES
  generate_studies(config, dir_input, dir_study_root)

if __name__ == "__main__":
  main()