#!/usr/bin/bash
# 在Windows系统中安装Alist服务

SRV_HTTPD_NAME="httpd"
SRV_HTTPD_DISPNAME="Apache Web Server"
SRV_HTTPD_DESC="A file list program that supports multiple storage"

ISADMIN=$(net session > /dev/null 2>&1 && echo 1 || echo 0)

# 检查是否使用git-bash运行该脚本
if [ "${MSYSTEM}" != MINGW64 ] || [ ! -x /cmd/git.exe ]; then
echo "Should run from git-bash !"
exit 1
fi

# 以管理员权限运行脚本
[ "${ISADMIN}" == 1 ] || {
which nircmd &>/dev/null || { unzip -o nircmd.zip nircmd.exe -d .; PATH=${PATH}:${PWD}; }
nircmd elevate /git-bash -c "${0}"
[ -x nircmd.exe ] && rm -vf nircmd.exe
exit 0
}

# 安装nircmd命令程序
which nircmd &>/dev/null || unzip nircmd.zip nircmd.exe -d /cmd
# 安装nssm命令程序
which nssm &>/dev/null || unzip -j nssm-*.zip */win64/nssm.exe -d /cmd
# 安装expect脚本
which expect &>/dev/null || unzip -j expect-*.zip -d /cmd
# 安装apache程序
ls /cmd/Apache24/bin/httpd &>/dev/null || unzip httpd-*.zip Apache24/** -d /cmd
export PATH=${PATH}:/cmd/Apache24/bin
# 配置apache
SRVROOT=$(cygpath -m /cmd/Apache24)
sed -i -r "s|^(\s*Define SRVROOT \")[^\"]+(\")|\1${SRVROOT}\2|" /cmd/Apache24/conf/httpd.conf
sed -i -r "s|^#?\s*(ServerName\s+)\S+\s*$|\1localhost:80|" /cmd/Apache24/conf/httpd.conf

# 检查Alist服务
SRV_HTTPD_STAT=$(nssm status ${SRV_HTTPD_NAME} 2>/dev/null)
[ -n "${SRV_HTTPD_STAT}" ] || {
nssm install ${SRV_HTTPD_NAME} "$(cygpath -w $(which httpd))"
# nssm set ${SRV_HTTPD_NAME} AppParameters ""
nssm set ${SRV_HTTPD_NAME} DisplayName "${SRV_HTTPD_DISPNAME}"
nssm set ${SRV_HTTPD_NAME} Description "${SRV_HTTPD_DESC}"
nssm start ${SRV_HTTPD_NAME}
}

while [ "${SRV_HTTPD_STAT}" != SERVICE_RUNNING ]; do
echo -e "Starting service ${SRV_HTTPD_NAME}.\033[1A"
nssm start ${SRV_HTTPD_NAME}
sleep 1
SRV_HTTPD_STAT=$(nssm status ${SRV_HTTPD_NAME} 2>/dev/null)
done


