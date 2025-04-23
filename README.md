# 构建oos本地化模块

通过对应机型的coloros rom构建oos的本地化(kernelsu/magisk)模块。(本项目用bash编写仅在linux运行环境测试过，wsl自己解决)

模块模板参考自[酷安@天伞桜](https://www.coolapk.com/feed/61520805)

## 注意
# 目前本模块并不完善！
- 1、现在使用本模块后将会导致无法授予读取应用列表权限，需要使用xposed模块临时修复，模块仓库见后面。  

- 2、使用kernelsu安装模块后，可能会出现解锁就重启的问题，临时的解决方法是在进入系统的第一屏(转圈那个)的时候，按三下`音量减键`(一下一下按，不要多，多了会进oos的安全模式)就可以解决，至于为什么会这样就不知道了，本项目基于bug运行。安装/更新任意ksu模块都有概率出现此问题，但是只有第一次变更模块会出现这个问题，按上面操作一次之后后面就不会了。

- 3、设置中的AI那栏点击无反应，可以通过设置的搜索进入

- 4、云服务相关功能无法使用

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
