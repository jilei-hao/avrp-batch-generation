import os
import sys
import csv

def parse_csv(fn_csv):
  """
  Parses a CSV file and returns a list of dictionaries with the data.
  Each dictionary corresponds to a row in the CSV file.
  """
  config = []
  with open(fn_csv, 'r') as f:
    reader = csv.DictReader(f)
    for row in reader:
      # print("Row:", row)
      config.append(row)
  return config

def generate_studies(config, study_root):
  """
  Generates study folders based on the configuration.
  Each study folder is created in the study root directory.
  """
  for config_row in config:
    study_id = config_row['Study_ID']
    tp_ref_sys = config_row['Systole_Ref_Frame']
    tp_list_sys = config_row['Systole_Frames']
    tp_ref_dias = config_row['Diastole_Ref_Frame']
    tp_list_dias = config_row['Diastole_Frames']

    

    study_folder = os.path.join(study_root, study_name)
    if not os.path.exists(study_folder):
      os.makedirs(study_folder)
      print(f"Created study folder: {study_folder}")
    else:
      print(f"Study folder already exists: {study_folder}")

    # create subfolders for each subject
    for subject in config_row['subjects'].split(','):
      subject_folder = os.path.join(study_folder, subject.strip())
      if not os.path.exists(subject_folder):
        os.makedirs(subject_folder)
        print(f"Created subject folder: {subject_folder}")
      else:
        print(f"Subject folder already exists: {subject_folder}")

def main():
  # get the path to the csv file from the first argument
  if len(sys.argv) != 3:
    print("Usage: python csv_to_study.py <path to csv file> <path to study root>")
    sys.exit(1)

  fn_csv = sys.argv[1]
  if not os.path.exists(fn_csv):
    print(f"File {fn_csv} does not exist")
    sys.exit(1)

  # get the study root for creating study folders
  study_root = sys.argv[2]
  if not os.path.isdir(study_root):
    print(f"Study root {study_root} is not a directory")
    sys.exit(1)

  config = parse_csv(fn_csv)
  print("Parsed config:", config)

  if config is None:
    print(f"Failed to parse {fn_csv}")
    sys.exit(1)

  # create the study folder
  # generate_studies(config, study_root)

if __name__ == "__main__":
  main()