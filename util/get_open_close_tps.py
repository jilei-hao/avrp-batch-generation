# get valve open and close tps
# input: systolic/diastolic reference and target tps in comma separated string
# output: open_tp close_tp

import sys

def get_open_close_tps():
  tp_ref_sys = sys.argv[1]
  tp_target_sys = sys.argv[2]
  tp_ref_dias = sys.argv[3]
  tp_target_dias = sys.argv[4]

  # insert tp_ref_sys and tp_target_sys to a new list and convert to int
  tp_list_sys = [int(tp_ref_sys)] if tp_ref_sys else []
  tp_list_sys.extend([int(tp) for tp in tp_target_sys.split(',')])
  tp_list_sys.sort()

  # insert tp_ref_dias and tp_target_dias to a new list and convert to int
  tp_list_dias = [int(tp_ref_dias)] if tp_ref_dias else []
  tp_list_dias.extend([int(tp) for tp in tp_target_dias.split(',')])
  tp_list_dias.sort()

  # open tp is always first tp of sys
  tp_open = tp_list_sys[0]

  # close tp is the first tp of dias that is greater than the last tp of sys
  tp_close = [tp for tp in tp_list_dias if tp > tp_list_sys[-1]][0]

  return tp_open, tp_close

if __name__ == '__main__':
  tp_open, tp_close = get_open_close_tps()
  print(f"{tp_open} {tp_close}")