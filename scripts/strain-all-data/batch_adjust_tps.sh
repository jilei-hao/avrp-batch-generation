#! /bin/bash

dir_study="/home/jileihao/data/strain/Strain_alldata/studies"

for study_dir in ${dir_study}/*
do
  # read config.sh
  source "$study_dir/config.sh"
  # extract study name
  study=$(basename "$study_dir")
  echo "----------------------------------------"
  echo "Running study: $study"
  echo "----------------------------------------"
  echo ""
  
  # list tp variables
  echo "TP variables:"
  echo CONFIG_TPR: $CONFIG_TPR
  echo CONFIG_TPT: $CONFIG_TPT
  echo CONFIG_TP_START: $CONFIG_TP_START
  echo CONFIG_TP_END: $CONFIG_TP_END
  echo CONFIG_TP_OPEN: $CONFIG_TP_OPEN
  echo CONFIG_TP_CLOSE: $CONFIG_TP_CLOSE

  # adjust tp_start, tp_end, tp_open, tp_close
  new_tp_start=1

  # check if tpr is part of tpt
  if echo ",$CONFIG_TPT," | grep -q ",$CONFIG_TPR,"; then
    # do nothing
    echo "TPR is part of TPT, no adjustment needed."
  else
    # add tpr to tpt
    CONFIG_TPT="$CONFIG_TPR,$CONFIG_TPT"
    echo "TPR is not part of TPT, adding TPR to TPT: $CONFIG_TPT"
  fi

  # sort the new tpt
  sorted_tpt=$(echo $CONFIG_TPT | tr ',' '\n' | sort -n | tr '\n' ',' | sed 's/,$//')
  echo "Sorted TPT: $sorted_tpt"

  # number of tps
  num_tps=$(echo $CONFIG_TPT | awk -F',' '{print NF}')

  # check if the tp_end equals to the number of tps
  if [ "$CONFIG_TP_END" -ne "$num_tps" ]; then
    echo -e "\033[1;33mnon-consecutive TPs detected, running adjustments\033[0m"
  else
    echo -e "\033[1;32mTP_END is equal to the number of TPs, no adjustment needed.\033[0m"
    # break the script
    continue
  fi

  new_tp_end=$num_tps

  # adjust tp_open and tp_close
  # find the 1-based index of the first occurrence of the CONFIG_TP_OPEN in the sorted TPT
  tp_open_index=$(echo $sorted_tpt | tr ',' '\n' | grep -n "$CONFIG_TP_OPEN" | cut -d: -f1 | head -n1)
  if [ -z "$tp_open_index" ]; then
    echo "TP_OPEN not found in TPT, setting to 1"
    new_tp_open=1
  else
    new_tp_open=$tp_open_index  # already 1-based index
  fi

  # find the 1-based index of the first occurrence of the CONFIG_TP_CLOSE in the sorted TPT
  tp_close_index=$(echo $sorted_tpt | tr ',' '\n' | grep -n "$CONFIG_TP_CLOSE" | cut -d: -f1 | head -n1)
  if [ -z "$tp_close_index" ]; then
    echo "TP_CLOSE not found in TPT, setting to last TP"
    new_tp_close=$num_tps
  else
    new_tp_close=$tp_close_index  # already 1-based index
  fi 


  # print the new tp variables
  echo "New TP variables:"
  echo "CONFIG_TPR: $CONFIG_TPR"
  echo "CONFIG_TPT: $sorted_tpt"
  echo "CONFIG_TP_START: $new_tp_start"
  echo "CONFIG_TP_END: $new_tp_end"
  echo "CONFIG_TP_OPEN: $new_tp_open"
  echo "CONFIG_TP_CLOSE: $new_tp_close"
  echo ""

  # write the new variables to config.sh
  echo "Updating config.sh in $study_dir"
  echo "CONFIG_TPR=$CONFIG_TPR" > "$study_dir/config.sh"
  echo "CONFIG_TPT=$sorted_tpt" >> "$study_dir/config.sh"
  echo "CONFIG_TP_START=$new_tp_start" >> "$study_dir/config.sh"
  echo "CONFIG_TP_END=$new_tp_end" >> "$study_dir/config.sh"
  echo "CONFIG_TP_OPEN=$new_tp_open" >> "$study_dir/config.sh"
  echo "CONFIG_TP_CLOSE=$new_tp_close" >> "$study_dir/config.sh"
  echo "Updated config.sh in $study_dir"
  echo ""
done

