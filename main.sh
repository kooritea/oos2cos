#!/bin/bash

file=$1
filename=$(basename "$1")
work_dir=`pwd`/tmp
module_dir=`pwd`/tmp/module
dependencies="payload-dumper-go 7z fsck.erofs"

if [ ! -e "$file" ]; then
  echo "未找到文件: $file"
  exit 1
fi

for c in $dependencies; do
  type $c >/dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "缺少依赖: $c"
    exit 1
  fi
done

model=$(echo "$filename" | awk -F'_' '{print $1}')
version=$(echo "$filename" | awk -F'_' '{print $2}' | awk -F'.zip' '{print $1}')
read -p "自定义小版本号 (0-99): " local_version
if [[ "$local_version" =~ ^[0-9]{1,2}$ ]]; then
  version="$version.$local_version"
else
  version="$version.0"
fi
IFS='.' read -r -a parts <<< "$version"
version_code=$((parts[0] * 10000000000 + parts[1] * 100000000 + parts[2] * 1000000 + parts[3] * 100 + parts[4]))
REMOVEPATH=""

while true
do
  RED="\033[31m"
  RESET="\033[0m"
  echo -e -n "确认设备型号${RED}(重要)${RESET}model: ${RED}($model)${RESET} [Y/n(退出)/r(重新输入)]: "
  read -r version_confirm
  case $version_confirm in
    [yY][eE][sS]|[yY])
      break
      ;;
    [nN][oO]|[nN])
      exit 0
      ;;
    [rR])
      echo -e -n "输入自定义设备型号(如PKG110): "
      read -r model
      ;;
    *)
      echo "Invalid input..."
      exit 1
      ;;
  esac
done

if [ -d "$work_dir" ]; then
  rm -rf $work_dir
fi

7z x "$file" "payload.bin" -o$work_dir
# payload-dumper-go -output "$work_dir/extracted"  "$work_dir/payload.bin"
payload-dumper-go -partitions my_region,my_stock,system_ext,my_product,system -output "$work_dir/extracted"  "$work_dir/payload.bin"
fsck.erofs "$work_dir/extracted/my_region.img" --extract=$work_dir/extracted/my_region
fsck.erofs "$work_dir/extracted/my_stock.img" --extract=$work_dir/extracted/my_stock
fsck.erofs "$work_dir/extracted/system_ext.img" --extract=$work_dir/extracted/system_ext
fsck.erofs "$work_dir/extracted/my_product.img" --extract=$work_dir/extracted/my_product
fsck.erofs "$work_dir/extracted/system.img" --extract=$work_dir/extracted/system

cp -r module_template $module_dir

sed -i s/VERSION_MATCH/$version/g $work_dir/module/module.prop
sed -i s/VERSIONCODE_MATCH/$version_code/g $work_dir/module/module.prop
sed -i s/MODEL_MATCH/$model/g $work_dir/module/system.prop

mkdir -p $work_dir/module/my_region
cp $work_dir/extracted/my_region/build.prop $work_dir/module/my_region/build.prop

mkdir -p $work_dir/module/my_region/etc/battery
cp $work_dir/extracted/my_region/etc/battery/sys_deviceidle_whitelist.xml $work_dir/module/my_region/etc/battery/sys_deviceidle_whitelist.xml
mkdir -p $work_dir/module/my_region/etc/extension
cp $work_dir/extracted/my_region/etc/extension/com.oplus.app-features.xml $work_dir/module/my_region/etc/extension/com.oplus.app-features.xml
sed -i '/<app_feature name="com.oplus.securitypermission.shortcut_enable" args="boolean:true"\/>/d' $work_dir/module/my_region/etc/extension/com.oplus.app-features.xml

cp $work_dir/extracted/my_region/etc/extension/com.oplus.oplus-feature.xml $work_dir/module/my_region/etc/extension/com.oplus.oplus-feature.xml
cp -r $work_dir/extracted/my_region/etc/startup/ $work_dir/module/my_region/etc/startup/

mkdir -p $work_dir/module/system/product/app/
cp -r $work_dir/extracted/my_stock/app/AIUnit/ $work_dir/module/system/product/app/
cp -r $work_dir/extracted/my_product/app/AONService/ $work_dir/module/system/product/app/
cp -r $work_dir/extracted/my_product/app/OplusCamera/ $work_dir/module/system/product/app/
cp -r $work_dir/extracted/my_stock/app/AssistantScreen/ $work_dir/module/system/product/app/
cp -r $work_dir/extracted/my_stock/app/BeaconLink/ $work_dir/module/system/product/app/
cp -r $work_dir/extracted/my_stock/app/ColorAccessibilityAssistant/ $work_dir/module/system/product/app/
cp -r $work_dir/extracted/my_stock/app/ColorDirectService/ $work_dir/module/system/product/app/
cp -r $work_dir/extracted/my_stock/app/ColorDirectUI/ $work_dir/module/system/product/app/
cp -r $work_dir/extracted/my_stock/app/COSA/ $work_dir/module/system/product/app/
cp -r $work_dir/extracted/my_stock/del-app/FileManager/ $work_dir/module/system/product/app/
cp -r $work_dir/extracted/my_stock/del-app/OppoWeather2/ $work_dir/module/system/product/app/
cp -r $work_dir/extracted/my_stock/app/SmartSideBar/ $work_dir/module/system/product/app/
cp -r $work_dir/extracted/my_stock/del-app/Calendar/ $work_dir/module/system/product/app/
REMOVEPATH="$REMOVEPATH\n/system/product/app/CalendarGoogle"

mkdir -p $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/app/AIWidgets/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/app/CloudService/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/priv-app/CTAutoRegist/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/priv-app/DCS/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/priv-app/DeviceIntegrationService/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/priv-app/dmp/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/app/Ether/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/priv-app/FindMyPhone/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/del-app/FinShellWallet/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/priv-app/HeyTapSpeechAssist/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/app/Instant/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/app/InstantService/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/priv-app/KeKeMarket/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/app/KeKePay/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/priv-app/KeKeUserCenter/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/priv-app/KeKeUserCenterAccount/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/del-app/KeKeUserCenterMember/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/priv-app/MediaTurbo/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/priv-app/Metis/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/del-app/OplusDocumentsReader/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/priv-app/OplusThirdKit/ $work_dir/module/system/product/priv-app/
# OPMemberShip
cp -r $work_dir/extracted/my_stock/del-app/OppoTranslation/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/priv-app/OppoTranslationService/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/priv-app/OPSynergy/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/priv-app/OShare/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/app/OWork/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/priv-app/SceneService/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/del-app/Shortcuts/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/app/StdSP/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/app/TasWallet/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/priv-app/TravelEngine/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/priv-app/UMS/ $work_dir/module/system/product/priv-app/
cp -r $work_dir/extracted/my_stock/del-app/UPTsmService/ $work_dir/module/system/product/priv-app/

mkdir -p $work_dir/module/system/system_ext/priv-app/
cp -r $work_dir/extracted/system_ext/priv-app/BlurService/ $work_dir/module/system/system_ext/priv-app/
cp -r $work_dir/extracted/system_ext/priv-app/DeepThinker/ $work_dir/module/system/system_ext/priv-app/

mkdir -p $work_dir/module/system/system_ext/app/
cp -r $work_dir/extracted/system_ext/app/SecurityPermission/ $work_dir/module/system/system_ext/app/

mkdir -p $work_dir/module/system/system_ext/overlay/
cp -r $work_dir/extracted/system_ext/overlay/OplusPermissionControllerOverlay/ $work_dir/module/system/system_ext/overlay/

sed -i "s|REMOVE_MATCH|$REMOVEPATH\n|g" $work_dir/module/customize.sh

7z a -tzip oos2cos-$model-$version_code.zip $work_dir/module/*
