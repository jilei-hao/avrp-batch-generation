import os
import sys

def extract_study_id(file_name):
  # return segment of file anme between two underscores and starting with 'bav' or 'tav'
  start = file_name.find('bav')
  if start == -1:
    start = file_name.find('tav')
  if start == -1:
    return None
  
  end = file_name.find('_', start)
  if end == -1:
    end = file_name.find('.', start)
  if end == -1:
    return None
  return file_name[start:end]

def import_manual_data():
  dirManualSrc = sys.argv[1]
  dirStudyRoot = sys.argv[2]

  manual_map = {}

  # iterate through the manual directory
  for root, dirs, files in os.walk(dirManualSrc):
    for file in files:
      if file.endswith(".nii.gz"):
        study_id = extract_study_id(file)
        if study_id is not None:
          manual_map[study_id] = os.path.join(root, file)

  # copy data to the study directory
  for study_id in manual_map.keys():
    dirStudy = os.path.join(dirStudyRoot, f'{study_id}-4DTEE')
    fnManual = os.path.join(dirStudy, 'srs_m.nii.gz')
    if os.path.exists(dirStudy):
      os.system(f'cp {manual_map[study_id]} {fnManual}')
    else:
      print(f"Study folder does not exist for {study_id}. Skipping.")


if __name__ == '__main__':
  import_manual_data()


