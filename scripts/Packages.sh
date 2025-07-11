#!/bin/bash

#安装和更新软件包
UPDATE_PACKAGE() {
	local PKG_NAME=$1
	local PKG_REPO=$2
	local PKG_BRANCH=$3
	local PKG_SPECIAL=$4
	local REPO_NAME=$(echo $PKG_REPO | cut -d '/' -f 2)

	rm -rf $(find ../feeds/luci/ ../feeds/packages/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune)

	git clone --depth=1 --single-branch --branch $PKG_BRANCH "https://github.com/$PKG_REPO.git"

	if [[ $PKG_SPECIAL == "pkg" ]]; then
		cp -rf $(find ./$REPO_NAME/*/ -maxdepth 3 -type d -iname "*$PKG_NAME*" -prune) ./
		rm -rf ./$REPO_NAME/
	elif [[ $PKG_SPECIAL == "name" ]]; then
		mv -f $REPO_NAME $PKG_NAME
	fi
}

#UPDATE_PACKAGE "包名" "项目地址" "项目分支" "pkg/name，可选，pkg为从大杂烩中单独提取包名插件；name为重命名为包名"
UPDATE_PACKAGE "argon" "jerrykuku/luci-theme-argon" "master"
UPDATE_PACKAGE "argon-config" "jerrykuku/luci-app-argon-config" "master"
UPDATE_PACKAGE "design" "kenzok78/luci-theme-design" "js"
UPDATE_PACKAGE "kucat" "sirpdboy/luci-theme-kucat" "js"
UPDATE_PACKAGE "alpha" "derisamedia/luci-theme-alpha" "master"
UPDATE_PACKAGE "alpha-config" "animegasan/luci-app-alpha-config" "master"

#UPDATE_PACKAGE "homeproxy" "VIKINGYFY/homeproxy" "main"
##UPDATE_PACKAGE "mihomo" "morytyann/OpenWrt-mihomo" "main"
##UPDATE_PACKAGE "nekoclash" "Thaolga/luci-app-nekoclash" "main"
#UPDATE_PACKAGE "openclash" "vernesong/OpenClash" "dev" "pkg"
#UPDATE_PACKAGE "passwall-packages" "xiaorouji/openwrt-passwall-packages" "main"
#UPDATE_PACKAGE "passwall" "xiaorouji/openwrt-passwall" "main" "pkg"
#UPDATE_PACKAGE "passwall2" "xiaorouji/openwrt-passwall2" "main" "pkg"
##UPDATE_PACKAGE "ssr-plus" "fw876/helloworld" "master"

#UPDATE_PACKAGE "luci-app-advancedplus" "VIKINGYFY/luci-app-advancedplus" "main"
UPDATE_PACKAGE "luci-app-gecoosac" "lwb1978/openwrt-gecoosac" "main"
#UPDATE_PACKAGE "luci-app-tailscale" "asvow/luci-app-tailscale" "main"
#UPDATE_PACKAGE "luci-app-wolplus" "VIKINGYFY/luci-app-wolplus" "main"

UPDATE_PACKAGE "luci-app-adguardhome" "xiaoxiao29/luci-app-adguardhome" "master"
#UPDATE_PACKAGE "adguardhome" "haiibo/openwrt-packages" "master" "pkg"
UPDATE_PACKAGE "easymesh" "kenzok8/openwrt-packages" "master" "pkg"
#linkease app
UPDATE_PACKAGE "ddnsto" "linkease/nas-packages" "master" "pkg"
UPDATE_PACKAGE "luci-app-ddnsto" "linkease/nas-packages-luci" "main" "pkg"
#iStorex && dependency
UPDATE_PACKAGE "istorex" "linkease/nas-packages-luci" "main" "pkg"
UPDATE_PACKAGE "quickstart" "linkease/nas-packages" "master" "pkg"
UPDATE_PACKAGE "luci-app-quickstart" "linkease/nas-packages-luci" "main" "pkg"
#UPDATE_PACKAGE "istoreenhance" "linkease/nas-packages" "master" "pkg"
#UPDATE_PACKAGE "luci-app-istoreenhance" "linkease/nas-packages-luci" "main" "pkg"

#luci-app-turboacc
#UPDATE_PACKAGE "luci-app-turboacc" "coolsnowwolf/luci" "master" "pkg"

if [[ $WRT_REPO == *"openwrt-6.x"* ]]; then
	UPDATE_PACKAGE "qmi-wwan" "immortalwrt/wwan-packages" "master" "pkg"
fi

#更新软件包版本
UPDATE_VERSION() {
	local PKG_NAME=$1
	local PKG_MARK=${2:-not}
	local PKG_FILES=$(find ./ ../feeds/packages/ -maxdepth 3 -type f -wholename "*/$PKG_NAME/Makefile")

	echo " "

	if [ -z "$PKG_FILES" ]; then
		echo "$PKG_NAME not found!"
		return
	fi

	echo "$PKG_NAME version update has started!"

	for PKG_FILE in $PKG_FILES; do
		local PKG_REPO=$(grep -Pho 'PKG_SOURCE_URL:=https://.*github.com/\K[^/]+/[^/]+(?=.*)' $PKG_FILE | head -n 1)
		local PKG_VER=$(curl -sL "https://api.github.com/repos/$PKG_REPO/releases" | jq -r "map(select(.prerelease|$PKG_MARK)) | first | .tag_name")
		local NEW_VER=$(echo $PKG_VER | sed "s/.*v//g; s/_/./g")
		local NEW_HASH=$(curl -sL "https://codeload.github.com/$PKG_REPO/tar.gz/$PKG_VER" | sha256sum | cut -b -64)

		local OLD_VER=$(grep -Po "PKG_VERSION:=\K.*" "$PKG_FILE")

		echo "$OLD_VER $PKG_VER $NEW_VER $NEW_HASH"

		if [[ $NEW_VER =~ ^[0-9].* ]] && dpkg --compare-versions "$OLD_VER" lt "$NEW_VER"; then
			sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=$NEW_VER/g" "$PKG_FILE"
			sed -i "s/PKG_HASH:=.*/PKG_HASH:=$NEW_HASH/g" "$PKG_FILE"
			echo "$PKG_FILE version has been updated!"
		else
			echo "$PKG_FILE version is already the latest!"
		fi
	done
}

#UPDATE_VERSION "软件包名" "测试版，true，可选，默认为否"
#UPDATE_VERSION "sing-box" "true"
#UPDATE_VERSION "tailscale"
