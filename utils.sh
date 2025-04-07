#!/bin/bash

add_apex() {
  local work_dir=$1
  local pack_name=$2
  mkdir -p $work_dir/module/system/apex/
  cp -r $work_dir/extracted/system/system/apex/$pack_name.apex $work_dir/module/system/apex/

  mkdir -p $work_dir/extracted/apex/$pack_name
  7z x -y $work_dir/extracted/system/system/apex/$pack_name.apex -o$work_dir/extracted/apex/$pack_name
  mkdir -p $work_dir/module/apex/$pack_name
  7z x -y $work_dir/extracted/apex/$pack_name/apex_payload.img -o$work_dir/module/apex/$pack_name
  rm -rf $work_dir/module/apex/$pack_name/lost+found
}