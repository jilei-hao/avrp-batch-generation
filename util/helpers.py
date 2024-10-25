import SimpleITK as sitk

def get_non_background_volume(image):
  labels = sitk.GetArrayFromImage(image)
  volume = 0
  for label in labels.flatten():
    if label != 0:
      volume += 1
  return volume