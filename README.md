# 构建oos本地化模块

通过对应机型的coloros rom构建oos的本地化(kernelsu/magisk)模块。(本项目用bash编写仅在linux运行环境测试过，wsl自己解决)

模块模板参考自[酷安@天伞桜](https://www.coolapk.com/feed/61520805)

## 注意
# 目前本模块并不完善！
现在使用本模块后将会导致无法授予读取应用列表权限，需要使用xposed模块临时修复，模块仓库见后面。  
对于如定位这些原生有的但无法在本地化后的界面设置的权限，可以在开发者选项中打开`禁止权限监控`恢复为原生权限管理再进行设置

## 使用方法

- 1、[https://yun.daxiaamu.com/OnePlus_Roms/](https://yun.daxiaamu.com/OnePlus_Roms/)下载需要提取的cn版全量包

- 2、将文件名重命名为`${model}_${version}.zip`的格式 如 `PKG110_15.0.0.405.zip`，将其移动到项目根目录

- 3、安装所需依赖，以arch系发行版为例，其他发行版自行解决

```bash
yay -S payload-dumper-go-bin
sudo pacman -S erofs-utils 7zip
```

- 4、进入项目根目录打开shell进行提取

```bash
bash ./main.sh ./PKG110_15.0.0.405.zip
```

- 5、如使用的是kernelsu，需要先在设置中关闭`默认卸载模块`，也就是使用黑名单模式，当需要对某个应用隐藏时在应用列表中单独将应用设置为卸载模块。

- 6、使用kernelsu/magisk安装模块，安装完之后暂不立即重启，使用带有root权限的文件管理器删除/data/system/package_cache下的所有文件夹，注意不是删除/data/system/package_cache文件夹

- 7、(可选)安装辅助xposed模块[https://github.com/kooritea/oos2cosm](https://github.com/kooritea/oos2cosm)

- 8、重启

- 9、部分app(如google日历)如果被play商店更新了，则直接卸载即可使用回本地化后的日历
