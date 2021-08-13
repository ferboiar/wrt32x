#!/bin/bash

# Enter your commands here, e.g.
# echo "Start build!"
cd openwrt

#reset this commit: https://github.com/openwrt/openwrt/commit/29a3967e61334d0c6a1a7d391f0e751272d77b1d
# generic: fix kernel panic on existing mac-address node
# probar, si compila dejarlo, si no quitarlo
git reset --hard 29a3967e61334d0c6a1a7d391f0e751272d77b1d

exit 0
