![OpenWRT](images/openwrt_logo.png)

# GitHub Action Script Custom Modded By [Eliminater74](https://github.com/DevOpenWRT-Router/Action_OpenWRT_AutoBuild_Linksys_Devices)
## Original from [P3TERX](https://github.com/P3TERX/Actions-OpenWrt)
### Created to make building OpenWRT easier using github actions.

<p align="center">
  <img width="300" height="auto" src="images/wrt32x.jpg">
</p>

> Snapshot changelog: https://git.openwrt.org/?p=openwrt/openwrt.git;a=shortlog

## Notes:
- Patches directory are taken from: [Divested-WRT: UNOFFICIAL OpenWrt builds](https://divested.dev/unofficial-openwrt-builds/mvebu-linksys/patches/)
- mwlwifi is taken from: [Lean's Openwrt source code repository](https://github.com/coolsnowwolf/lede/tree/master/package/kernel/mwlwifi)
- modifications to action script By Eliminater74
- NetData SQM char from: https://github.com/Fail-Safe/netdata-chart-sqm (edit "wrt32x/configs/files/etc/netdata/charts.d/sqm.conf" to modify your WAN interface)
- OpenWRTScripts from: https://github.com/richb-hanover/OpenWrtScripts
- autoSQM script from: https://github.com/baguswahyu/autoSQM-damasus.bagus More info here: https://forum.openwrt.org/t/help-to-make-sh-script-for-adjust-sqm-automaticaly/58754 (edit your scheluded tasks to set "0 6,14,22 * * * /usr/lib/OpenWrtScripts/autoSQM.sh")
- Network interfaces ports status from: https://github.com/tano-systems/luci-app-tn-netports (edit "wrt32x/configs/files/etc/config/luci_netports" file to set your interfaces)
_______________________________________________________________________
![GitHub Downloads](https://img.shields.io/github/release-date/ferboiar/wrt32x?style=flat-square&logo=openwrt)

### Latest Release Downloads:
![GitHub Downloads](https://img.shields.io/github/downloads/ferboiar/wrt32x/latest/total?style=for-the-badge&logo=openwrt)

### Total Downloads:
![GitHub Downloads](https://img.shields.io/github/downloads/ferboiar/wrt32x/total?style=for-the-badge&logo=openwrt)

# Actions-OpenWrt
[![Visits Badge](https://badges.pufler.dev/visits/ferboiar/wrt32x)](https://badges.pufler.dev)

[![Cleaning](https://github.com/ferboiar/wrt32x/actions/workflows/cleanup.yml/badge.svg)](https://github.com/ferboiar/wrt32x/actions/workflows/cleanup.yml)

[![Build OpenWrt Snapshot (TESTING)](https://github.com/ferboiar/wrt32x/actions/workflows/build-openwrt-snapshot.yml/badge.svg)](https://github.com/ferboiar/wrt32x/actions/workflows/build-openwrt-snapshot.yml)

[![Build OpenWrt Snapshot (TESTING)](https://github.com/ferboiar/wrt32x/actions/workflows/build-openwrt-snapshot.yml/badge.svg?branch=linksys&event=workflow_run)](https://github.com/ferboiar/wrt32x/actions/workflows/build-openwrt-snapshot.yml)

### Repo Updated:
[![Updated Badge](https://badges.pufler.dev/updated/ferboiar/wrt32x)](https://badges.pufler.dev)

![Your Repository’s Stats](https://github-readme-stats.vercel.app/api?username=ferboiar&show_icons=true)

_______________________________________________________________________
## INSTRUCTIONS:
1. Click the `Use this template` button from my repo to create your new repo (or fork it)
2. in the home folder of your linux machine clone the openwrt github repo and yours:
```
git clone https://github.com/openwrt/openwrt.git
git clone https://github.com/ferboiar/wrt32x.git *change it for your brand new recently created repo 
```
3. Copy in the new folder "openwrt/" the scripts and the configuration files from your repo:
```
cp wrt32x/scripts/*.sh openwrt/
mkdir openwrt/patches/
cp -r wrt32x/configs/patches/ openwrt/
cp wrt32x/configs/feeds.conf.default openwrt/
cp wrt32x/configs/wrt32x.config openwrt/
```
4. run, from "openwrt/" the commands contained in "manual_generate.sh" script:
```
./diy-part1.sh
./luci_themes.sh
./DevOpenWRT-Router.sh
./lean_packages.sh
./sirpdboy-package.sh
./scripts/feeds update -a
./scripts/feeds install -a
./scripts/feeds uninstall bluld
cp wrt32x.config .config
git am patches / *. patch
./diy-part2.sh
```
5. then `make menuconfig`, load your .config file and choose the packages you want.
6. upload your .config file to your repo "/configs" as wrt32x.config
7. launch "**Actions**" > "**Build OpenWrt Snapshot (TESTING)**"> "**Run workflow**" and choose from your repo:
```
2 (as wrt32x)
0 (as snapshot)
0 (as snapshot luci feeds location)
0 (as none ngrok / ssh after build)
```
after 4 or 5h of compilation you will see two new files into "Artifacs":

### Flashing process
If you are not sure about your kernel partition size do a sysupgrade from command line [Increasing mamba and venom kernel partition to 6MB](https://forum.openwrt.org/t/increasing-mamba-and-venom-kernel-partition-to-6mb)

1. Verify compatibility
```
 - $ fw_printenv | grep "pri_kern_size"; #mamba MUST equal 0x400000
 - $ fw_printenv | grep "priKernSize"; #venom MUST equal 0x0600000
```
Do not try to change them!

2. Flashing process:
You must always use a factory image when flashing to or away from a resized build.
- Create a backup tar
- Flash the image via sysupgrade: `sysupgrade -F squashfs-factory.img`
- Restore the backup

Two times, to do the change from both boot partitions. Once, you will be capable of install updates without do this again

_______________________________________________________________________

### TIPS
- Note that your repo needs to be public, otherwise you have a strict monthly limit on how many minutes you can use.
- Your session can run for up to six hours. Don't forget to close it after finishing your work, otherwise you will continue to occupy this virtual machine, making it impossible for others to use it normally.
- Please check the [GitHub Actions Terms of Service](https://docs.github.com/en/github/site-policy/github-additional-product-terms#5-actions-and-packages). According to the TOS the repo that contains these files needs to be the same one where you're developing the project that you're using it for, and specifically that you are using it for the "_production, testing, deployment, or publication of [that] software project_".

Build OpenWrt using GitHub Actions: [Instructions (Use translator)](https://p3terx.com/archives/build-openwrt-with-github-actions.html)

## Advanced
### SSH by using [ngrok](https://ngrok.com/)
Click the `Settings` tab on your own repository, and then click the `Secrets` button to add the following encrypted environment variables:

- `NGROK_TOKEN`: Sign up on the <https://ngrok.com> , find this token [here](https://dashboard.ngrok.com/auth/your-authtoken).
- `SSH_PASSWORD`: This password you will use when authorizing via SSH.

### Send connection info to [Telegram](https://telegram.org/)
Click the `Settings` tab on your own repository, and then click the `Secrets` button to add the following encrypted environment variables:

- `TELEGRAM_BOT_TOKEN`: Get your bot token by talking to [@BotFather](https://t.me/botfather).
- `TELEGRAM_CHAT_ID`: Get your chat ID by talking to [@GetMyID_bot](https://t.me/getmyid_bot) or other similar bots.

You can find Telegram Bot related documents [here](https://core.telegram.org/bots).


## Acknowledgments
- [P3TERX](https://github.com/P3TERX/Actions-OpenWrt)
- [Microsoft Azure](https://azure.microsoft.com)
- [GitHub Actions](https://github.com/features/actions)
- [OpenWrt](https://github.com/openwrt/openwrt)
- [Lean's OpenWrt](https://github.com/coolsnowwolf/lede)
- [tmate](https://github.com/tmate-io/tmate)
- [mxschmitt/action-tmate](https://github.com/mxschmitt/action-tmate)
- [csexton/debugger-action](https://github.com/csexton/debugger-action)
- [Cowtransfer](https://cowtransfer.com)
- [WeTransfer](https://wetransfer.com/)
- [Mikubill/transfer](https://github.com/Mikubill/transfer)
- [softprops/action-gh-release](https://github.com/softprops/action-gh-release)
- [c-hive/gha-remove-artifacts](https://github.com/c-hive/gha-remove-artifacts)
- [dev-drprasad/delete-older-releases](https://github.com/dev-drprasad/delete-older-releases)

[![LICENSE](https://img.shields.io/github/license/mashape/apistatus.svg?style=flat-square&label=License)](https://github.com/ferboiar/wrt32x/blob/master/LICENSE) ![GitHub Stars](https://img.shields.io/github/stars/ferboiar/wrt32x.svg?style=flat-square&label=Stars&logo=github) ![GitHub Forks](https://img.shields.io/github/forks/ferboiar/wrt32x.svg?style=flat-square&label=Forks&logo=github)
