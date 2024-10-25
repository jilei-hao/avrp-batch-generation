import SimpleITK as sitk
import sys

def check_number_of_labels(image_path):
  image = sitk.ReadImage(image_path)
  labels = sitk.GetArrayFromImage(image)
  unique_labels = set(labels.flatten())
  return len(unique_labels)

if __name__ == "__main__":
  image_path = sys.argv[1]
  print(check_number_of_labels(image_path))