import sys
import SimpleITK as sitk


# read a segmentation image, remove lumen label as specified by the argument, and write the modified image
def remove_lumen():
  fnSeg = sys.argv[1]
  fnOut = sys.argv[2]
  lumen = int(sys.argv[3])

  # read the segmentation image
  seg = sitk.ReadImage(fnSeg, sitk.sitkUInt16)

  # create a binary image of the lumen label
  bimg = sitk.BinaryThreshold(seg, lowerThreshold=lumen, upperThreshold=lumen, insideValue=1, outsideValue=0)

  # invert the binary image
  bimg = sitk.Not(bimg)

  # set the lumen label to 0
  seg = sitk.Mask(seg, bimg, 0)

  # write the modified segmentation image
  sitk.WriteImage(seg, fnOut)

if __name__ == '__main__':
  remove_lumen()