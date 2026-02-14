#!/bin/bash
#
# Enhanced compile script for Xiaomi_kernel_odin
# This script is based on Ubuntu 22.04.5 LTS
# Author: ruoqing <18201329@qq.com>
# Copyright (C) 2022-2026
#

# 字体颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 脚本说明
echo -e "${YELLOW}==================================================${NC}"
echo -e "${YELLOW}                  脚本说明                                                        ${NC}"
echo -e "${YELLOW}                                                  ${NC}"
echo -e "${YELLOW}               作者: 情若相惜 ღ                             ${NC}"
echo -e "${YELLOW}               QQ群：290495721                    ${NC}"
echo -e "${YELLOW}             Ubuntu 22.04.5 LTS                   ${NC}"
echo -e "${YELLOW}==================================================${NC}"

# 文件路径
cd
CURRENT_DIR=$(pwd)
KERNEL_DIR="${CURRENT_DIR}/xiaomi_kernel_odin"
CLANG_DIR="${KERNEL_DIR}/scripts/tools/clang-r383902b1"
GCC64_DIR="${KERNEL_DIR}/scripts/tools/aarch64-linux-android-4.9"
GCC_DIR="${KERNEL_DIR}/scripts/tools/arm-linux-androideabi-4.9"
ANYKERNEL_DIR="${KERNEL_DIR}/scripts/tools/AnyKernel3"
IMAGE_DIR="${KERNEL_DIR}/out/arch/arm64/boot/Image"
MODULES_DIR="${ANYKERNEL_DIR}/modules/vendor/lib/modules"
KPM_DIR="${KERNEL_DIR}/scripts/tools/SukiSU-Ultra"

# 内核目录
cd "${KERNEL_DIR}"

# 机型代号
device="odin"

# 内核配置
DEFCONFIG="odin_defconfig"
MISSING=0
KO=1
KPM=1

# 文件名称
if [ -d ".git" ]; then
GIT_COMMIT_HASH=$(git rev-parse --short=7 HEAD)
ZIP_NAME="MIX4-5.4.281-g${GIT_COMMIT_HASH}.zip"
else
CURRENT_TIME=$(date '+%Y%m%d%H%M')
ZIP_NAME="MIX4-5.4.281-${CURRENT_TIME}.zip"
fi

# 安装依赖
install() {
   dependencies=(git ccache automake flex lzop bison gperf build-essential zip curl zlib1g-dev zlib1g-dev:i386 g++-multilib libxml2-utils bzip2 libbz2-dev libbz2-1.0 libghc-bzlib-dev squashfs-tools pngcrush schedtool dpkg-dev liblz4-tool make optipng maven libssl-dev pwgen libswitch-perl policycoreutils minicom libxml-sax-base-perl libxml-simple-perl bc libc6-dev-i386 lib32ncurses-dev x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev xsltproc unzip openjdk-17-jdk python-is-python3)
   for pkg in "${dependencies[@]}"; do
   if ! dpkg -s "$pkg" >/dev/null 2>&1; then
   MISSING=1
   fi
   done
   if [ "$MISSING" = '1' ]; then
   sudo apt-get update
   sudo apt-get install -y "${dependencies[@]}"
   fi
}

# 用户邮箱
email() {
   git config --global user.name "ruoqing501"
   git config --global user.email "liangxiaobo501@gmail.com"
}

# 环境变量
path() {
   export KBUILD_BUILD_USER="builder"
   export KBUILD_BUILD_HOST="builder-vendor-48059-417397120388620288"
   export KBUILD_BUILD_TIMESTAMP="Fri Jul 26 11:35:31 UTC 2023"
   export PATH="${CLANG_DIR}/bin:${GCC64_DIR}/bin:${GCC_DIR}/bin:$PATH"
   args="-j$(nproc) O=out CC=clang ARCH=arm64 SUBARCH=arm64 LD=ld.lld AR=llvm-ar NM=llvm-nm STRIP=llvm-strip OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump READELF=llvm-readelf HOSTCC=clang HOSTCXX=clang++ HOSTAR=llvm-ar HOSTLD=ld.lld CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_COMPAT=arm-linux-gnueabi- LLVM=1 LLVM_IAS=1"
#  args="-j$(nproc) O=out CC=clang ARCH=arm64 HOSTCC=gcc LD=ld.lld CLANG_TRIPLE=aarch64-linux-gnu- CROSS_COMPILE=aarch64-linux-android-"

}


# 编译内核
build() {
   make ${args} $DEFCONFIG
   make ${args} menuconfig
   make ${args} savedefconfig
   cp out/.config arch/arm64/configs/"$device"_defconfig
   START_TIME=$(date +%s)
   make ${args} 2>&1 | tee "${CURRENT_DIR}/kernel.log"
   if [ ! -f "$IMAGE_DIR" ]; then
   echo -e "${YELLOW}--------------------------------------------------${NC}"
   echo -e "${RED}编译失败，请检查代码后重试...${NC}"
   echo -e "${YELLOW}--------------------------------------------------${NC}"
   exit 1
   fi
}

# 打包内核
package() {
   if [ "$KO" = '1' ]; then
   make ${args} INSTALL_MOD_PATH=modules INSTALL_MOD_STRIP=1 modules_install
   cd "${ANYKERNEL_DIR}"
   COMMIT_HASH=$(git rev-parse --short=12 HEAD)
   cp $(find "${KERNEL_DIR}/out/modules/lib/modules/5.4.281-qgki-g${COMMIT_HASH}" -name '*.ko') "${MODULES_DIR}"
#  cp "${KERNEL_DIR}/out/modules/lib/modules/5.4.281-qgki-g${COMMIT_HASH}"/modules.{alias,dep,softdep} "${MODULES_DIR}"
#  cp "${KERNEL_DIR}/out/modules/lib/modules/5.4.281-qgki-g${COMMIT_HASH}"/modules.order "${MODULES_DIR}/modules.load"
#  sed -i -E 's|kernel/[^[:space:]]+/([^/[:space:]]+\.ko)|/vendor/lib/modules/\1|g' "${MODULES_DIR}/modules.dep"
#  sed -i 's/.*\///g' "${MODULES_DIR}/modules.load"
   sed -i 's/do.modules=0/do.modules=1/g' anykernel.sh
   cd "${KERNEL_DIR}"
   fi
   cd "${ANYKERNEL_DIR}"
   if [ "$KO" = '0' ]; then
   sed -i 's/do.modules=1/do.modules=0/g' anykernel.sh
   fi
   cp "${IMAGE_DIR}" "${ANYKERNEL_DIR}/Image"
   if [ "$KPM" = '1' ]; then
   cp "${KPM_DIR}/patch_linux" "${ANYKERNEL_DIR}/patch_linux"
   ./patch_linux
   mv -f oImage Image
   rm -rf "${ANYKERNEL_DIR}"/patch_linux
   fi
   zip -r9 "${ZIP_NAME}" * -x "placeholder" -x "*/placeholder"
   mv "${ZIP_NAME}" "${CURRENT_DIR}"
   END_TIME=$(date +%s)
   COST_TIME=$((END_TIME - START_TIME))
   echo -e "${YELLOW}--------------------------------------------------${NC}"
   echo -e "${GREEN}编译完成...${NC}"
   echo -e "${YELLOW}--------------------------------------------------${NC}"
   echo -e "${GREEN}总共用时： $((COST_TIME / 60))分$((COST_TIME % 60))秒${NC}"
   echo -e "${YELLOW}--------------------------------------------------${NC}"
   echo -e "${YELLOW}内核文件: ${CURRENT_DIR}/${ZIP_NAME}${NC}"
   echo -e "${YELLOW}--------------------------------------------------${NC}"
}

# 清理环境
clean() {
   rm -rf "${ANYKERNEL_DIR}"/Image
   rm -rf "${IMAGE_DIR}"
   rm -rf "${MODULES_DIR}"/*.ko
#  rm -rf "${KERNEL_DIR}"/out
}

# 主程序
main() {
   install
   email
   path
   build
   package
   clean
}

main
