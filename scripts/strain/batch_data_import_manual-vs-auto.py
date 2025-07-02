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

def import_data():
  dirImageSrc = sys.argv[1]
  dirAutoSrc = sys.argv[2]
  dirManualSrc = sys.argv[3]
  dirStudyRoot = sys.argv[4]

  image_map = {}
  auto_map = {}
  manual_map = {}

  # iterate through the image directory
  for root, dirs, files in os.walk(dirImageSrc):
    for file in files:
      if file.endswith(".nii.gz"):
        study_id = extract_study_id(file)
        if study_id is not None:
          image_map[study_id] = os.path.join(root, file)

  # iterate through the auto directory
  for root, dirs, files in os.walk(dirAutoSrc):
    for file in files:
      if file.endswith(".nii.gz"):
        study_id = extract_study_id(file)
        if study_id is not None:
          auto_map[study_id] = os.path.join(root, file)

  # iterate through the manual directory
  for root, dirs, files in os.walk(dirManualSrc):
    for file in files:
      if file.endswith(".nii.gz"):
        study_id = extract_study_id(file)
        if study_id is not None:
          manual_map[study_id] = os.path.join(root, file)

  # copy data to the study directory
  for study_id in image_map.keys():
    dirStudy = os.path.join(dirStudyRoot, f'{study_id}-4DTEE')
    fnImage = os.path.join(dirStudy, 'i4.nii.gz')
    if os.path.exists(dirStudy):
      os.system(f'cp {image_map[study_id]} {fnImage}')
    else:
      print(f"Study folder does not exist for {study_id}. Skipping.")
  
  for study_id in auto_map.keys():
    dirStudy = os.path.join(dirStudyRoot, f'{study_id}-4DTEE')
    fnAuto = os.path.join(dirStudy, 'srs_a.nii.gz')
    if os.path.exists(dirStudy):
      os.system(f'cp {auto_map[study_id]} {fnAuto}')
    else:
      print(f"Study folder does not exist for {study_id}. Skipping.")

  for study_id in manual_map.keys():
    dirStudy = os.path.join(dirStudyRoot, f'{study_id}-4DTEE')
    fnManual = os.path.join(dirStudy, 'srs_m.nii.gz')
    if os.path.exists(dirStudy):
      os.system(f'cp {manual_map[study_id]} {fnManual}')
    else:
      print(f"Study folder does not exist for {study_id}. Skipping.")


if __name__ == '__main__':
  import_data()