import SimpleITK as sitk
import sys
import os
import io
from picsl_c3d import Convert3D, Convert4D
import helpers as h

def get_unique_labels(image):
  labels = sitk.GetArrayFromImage(image)
  unique_labels = set(labels.flatten())
  return unique_labels

def get_orientation_code_3d(image):
  c = Convert3D()
  c.push(image)
  outStream = io.StringIO()
  c.execute(f'-info ', out=outStream)
  result = outStream.getvalue()

  # Extract the orientation code from the result Image #1: dim = [384, 256, 208];  bb = {[0 0 0], [177.398 180.997 111.1]};  vox = [0.461973, 0.707021, 0.534135];  range = [0, 4];  orient = LAS
  orientationCode = result.split("orient = ")[1].strip()
  return orientationCode

def get_orientation_code_4d(image):
  c = Convert4D()
  c.push(image)
  outStream = io.StringIO()
  c.execute(f'-info ', out=outStream)
  result = outStream.getvalue()

  # Extract the orientation code from the result Image #1: dim = [384, 256, 208];  bb = {[0 0 0], [177.398 180.997 111.1]};  vox = [0.461973, 0.707021, 0.534135];  range = [0, 4];  orient = LAS
  orientationCode = result.split("orient = ")[1].strip()
  return orientationCode

def get_orientation_code(image):
  if image.GetDimension() == 3:
    return get_orientation_code_3d(image)
  elif image.GetDimension() == 4:
    return get_orientation_code_4d(image)
  else:
    return "Unknown"

if __name__ == "__main__":
  dirStudyRoot = sys.argv[1]

  # iterate through the study folders in the root directory
  for studyFolder in os.listdir(dirStudyRoot):
    studyPath = os.path.join(dirStudyRoot, studyFolder)

    imgManual = sitk.ReadImage(os.path.join(studyPath, "srs_m.nii.gz"))
    imgAuto = sitk.ReadImage(os.path.join(studyPath, "srs_a.nii.gz"))

    # manualLabels = get_unique_labels(imgManual)
    # autoLabels = get_unique_labels(imgAuto)
    #  # Filter out np.uint9(0) from the labels
    # manualLabels = [int(label) for label in manualLabels if label != 0]
    # autoLabels = [int(label) for label in autoLabels if label != 0]

    # orientManual = get_orientation_code(imgManual)
    # orientAuto = get_orientation_code(imgAuto)

    voxelCountManual = h.get_non_background_volume(imgManual)
    voxelCountAuto = h.get_non_background_volume(imgAuto)
    voxelCountDiff = voxelCountAuto - voxelCountManual
    voxelCountDiffPercent = voxelCountDiff / voxelCountManual * 100

    # print(f"-- {studyFolder} -- "
    #       f" Auto: {autoLabels} [{orientAuto}] voxel_count: {voxelCountAuto};"
    #       f" Manual: {manualLabels} [{orientManual}] voxel_count: {voxelCountManual};"
    #       f" Diff: voxel_count: {voxelCountAuto - voxelCountManual};")
    

    print(f"-- {studyFolder} -- "
          f" Auto: voxel_count: {voxelCountAuto};"
          f" Manual: voxel_count: {voxelCountManual};"
          f" Diff: {voxelCountAuto - voxelCountManual} {voxelCountDiffPercent:.2f}%")

  # unique_labels = get_unique_labels(image_path)
  # print(len(unique_labels))