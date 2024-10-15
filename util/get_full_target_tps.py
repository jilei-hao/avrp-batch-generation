# combining input target tps
# input: array of target tp list in comma separated string
# output: full_target_tp_list

import sys

def get_full_target_tps():
  full_target_tp_list = []
  target_tp_list = sys.argv[1:]

  for target_tp in target_tp_list:
    full_target_tp_list.extend(target_tp.split(','))

  # sort and remove duplicates
  full_target_tp_list = list(set(full_target_tp_list))
  full_target_tp_list = [int(tp) for tp in full_target_tp_list] # convert to int before sorting
  full_target_tp_list.sort()
  full_target_tp_list = [str(tp) for tp in full_target_tp_list] # convert back to string after sorting

  return full_target_tp_list

if __name__ == '__main__':
  full_target_tp_list = get_full_target_tps()
  print(','.join(full_target_tp_list))