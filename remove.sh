#!/usr/bin/bash
# 卸载Windows系统中的Alist服务

SRV_HTTPD_NAME="httpd"
ISADMIN=$(net session > /dev/null 2>&1 && echo 1 || echo 0)

# 检查是否使用git-bash运行该脚本
if [ "${MSYSTEM}" != MINGW64 ] || [ ! -x /cmd/git.exe ]; then
echo "Should run from git-bash !"
exit 1
fi

[ -d /cmd/Apache24/bin ] && {
export PATH=${PATH}:/cmd/Apache24/bin
}

which alist &>/dev/null || {
echo "No alist installed on your system."
exit 0
}

# 以管理员权限运行脚本
[ "${ISADMIN}" == 1 ] || {
which nircmd &>/dev/null || { unzip -o nircmd.zip nircmd.exe -d .; PATH=${PATH}:${PWD}; }
nircmd elevate /git-bash -c "${0}"
[ -x nircmd.exe ] && rm -vf nircmd.exe
exit 0
}

# 删除Apache服务
nssm stop ${SRV_HTTPD_NAME}
sleep 3
nssm remove ${SRV_HTTPD_NAME} confirm
sleep 1

# 删除Apache程序
rm -rf /cmd/Apache24


