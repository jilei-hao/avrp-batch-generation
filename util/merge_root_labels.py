import sys
import SimpleITK as sitk

def merge_root_labels():
    fnSegRef = sys.argv[1]
    rootComponents = sys.argv[2]
    rootLabel = int(sys.argv[3])
    fnOut = sys.argv[4]

    # parse root components into a list of integers
    rootComponents = list(map(int, rootComponents.split(',')))

    # read seg ref
    segRef = sitk.ReadImage(fnSegRef, sitk.sitkUInt32)

    # create an empty image with the same size and type as segRef
    root_comp_bimg_sum = sitk.Image(segRef.GetSize(), sitk.sitkUInt32)
    root_comp_bimg_sum.CopyInformation(segRef)

    # threshold the image for each root component and add to the sum image
    for comp in rootComponents:
        bimg = sitk.BinaryThreshold(segRef, lowerThreshold=comp, upperThreshold=comp, insideValue=1, outsideValue=0)
        bimg = sitk.Cast(bimg, sitk.sitkUInt32)  # Cast to the same type as segRef
        root_comp_bimg_sum = sitk.Add(root_comp_bimg_sum, bimg)

    # threshold the sum image to get the root label
    root_comp_bimg_sum = sitk.BinaryThreshold(root_comp_bimg_sum, lowerThreshold=1, upperThreshold=len(rootComponents), insideValue=rootLabel, outsideValue=0)

    # write the modified seg ref
    sitk.WriteImage(root_comp_bimg_sum, fnOut)

if __name__ == '__main__':
    merge_root_labels()