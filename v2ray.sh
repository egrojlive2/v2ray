#!/bin/bash
mi_dominio=''
v_ser=$(netstat -tunlp | grep 443 | awk '{print $4}' | cut -d ":" -f2)
if [ "$v_ser" == "443" ]; then
echo "Primero Deten El Servicio Que Estes Utilizando En El Puerto 443 Y Vuelve A Ejecutar El Script"
exit 0
fi

if [ $1 ]; then
mi_dominio=$1
echo "$mi_dominio" > /etc/dominio.txt
else
touch /etc/dominio.txt
fi

BEIJING_UPDATE_TIME=3

#
BEGIN_PATH=$(pwd)

# 0: ipv4, 1: ipv6
NETWORK=0

#
INSTALL_WAY=0

#
HELP=0

REMOVE=0

CHINESE=0

#BASE_SOURCE_PATH="https://multi.netlify.app"
BASE_SOURCE_PATH="https://raw.githubusercontent.com/egrojlive/v2ray/main"

UTIL_PATH="/etc/v2ray_util/util.cfg"

UTIL_CFG="$BASE_SOURCE_PATH/v2ray_util/util_core/util.cfg"

BASH_COMPLETION_SHELL="$BASE_SOURCE_PATH/v2ray"

CLEAN_IPTABLES_SHELL="$BASE_SOURCE_PATH/v2ray_util/global_setting/clean_iptables.sh"

#Centos
[[ -f /etc/redhat-release && -z $(echo $SHELL|grep zsh) ]] && unalias -a

[[ -z $(echo $SHELL|grep zsh) ]] && ENV_FILE=".bashrc" || ENV_FILE=".zshrc"

#######color code########
#RED="31m"
#GREEN="32m"
#YELLOW="33m"
#BLUE="36m"
#FUCHSIA="35m"
RED=""
GREEN=""
YELLOW=""
BLUE=""
FUCHSIA=""
colorEcho(){
    COLOR=$1
    #echo -e "\033[${COLOR}${@:2}\033[0m"
    echo "${COLOR}${@:2}"
}

#######get params#########
while [[ $# > 0 ]];do
    key="$1"
    case $key in
        --remove)
        REMOVE=1
        ;;
        -h|--help)
        HELP=1
        ;;
        -k|--keep)
        INSTALL_WAY=1
        colorEcho ${BLUE} "keep v2ray profile to update\n"
        ;;
        --zh)
        CHINESE=1
        colorEcho ${BLUE} "安装中文版..\n"
        ;;
        *)
                # unknown option
        ;;
    esac
    shift # past argument or value
done
#############################

help(){
    echo "bash v2ray.sh [-h|--help] [-k|--keep] [--remove]"
    echo "  -h, --help           Mosttrar ayuda"
    echo "  -k, --keep           selecciona el v2ray config.json a actualizar"
    echo "      --remove         remover v2ray && multi-v2ray"
    echo "                       no params to new install"
    return 0
}

removeV2Ray() {
    #V2ray
    colorEcho $GREEN "Desinstalando V2ray"
    echo
    bash <(curl -L -s https://raw.githubusercontent.com/egrojlive/v2ray/main/go.sh) --remove >/dev/null 2>&1
    rm -rf /etc/v2ray >/dev/null 2>&1
    rm -rf /var/log/v2ray >/dev/null 2>&1

    #v2ray iptable
    bash <(curl -L -s $CLEAN_IPTABLES_SHELL)

    #multi-v2ray
    pip uninstall v2ray_util -y >/dev/null 2>&1
    rm -rf /usr/share/bash-completion/completions/v2ray.bash >/dev/null 2>&1
    rm -rf /usr/share/bash-completion/completions/v2ray >/dev/null 2>&1
    rm -rf /etc/bash_completion.d/v2ray.bash >/dev/null 2>&1
    rm -rf /usr/local/bin/v2ray >/dev/null 2>&1
    rm -rf /etc/v2ray_util >/dev/null 2>&1

    #v2ray
    crontab -l|sed '/SHELL=/d;/v2ray/d' > crontab.txt
    crontab crontab.txt >/dev/null 2>&1
    rm -f crontab.txt >/dev/null 2>&1

    if [[ ${PACKAGE_MANAGER} == 'dnf' || ${PACKAGE_MANAGER} == 'yum' ]];then
        systemctl restart crond >/dev/null 2>&1
    else
        systemctl restart cron >/dev/null 2>&1
    fi

    #multi-v2ray
    sed -i '/v2ray/d' ~/$ENV_FILE
    source ~/$ENV_FILE

    colorEcho ${GREEN} "Desinstalacion completa!"
}

closeSELinux() {
    #SELinux
    if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
        setenforce 0
    fi
}

judgeNetwork() {
    curl http://api.ipify.org &>/dev/null
    if [[ $? != 0 ]];then
        [[ `curl -s icanhazip.com` =~ ":" ]] && NETWORK=1
    fi
    export NETWORK=$NETWORK
}

checkSys() {
    #Root
    [ $(id -u) != "0" ] && { colorEcho ${RED} "Error: No Tienes Los Permisos root Para Ejecutar Este Script"; exit 1; }

    if [[ `command -v apt-get` ]];then
        PACKAGE_MANAGER='apt-get'
    elif [[ `command -v dnf` ]];then
        PACKAGE_MANAGER='dnf'
    elif [[ `command -v yum` ]];then
        PACKAGE_MANAGER='yum'
    else
        colorEcho $RED "Tu Sistema Operativo No Es Compatible Con Este Script!"
        exit 1
    fi
}

#
installDependent(){
    if [[ ${PACKAGE_MANAGER} == 'dnf' || ${PACKAGE_MANAGER} == 'yum' ]];then
        ${PACKAGE_MANAGER} install socat crontabs bash-completion which -y >/dev/null 2>&1
    else
        ${PACKAGE_MANAGER} update >/dev/null 2>&1
        ${PACKAGE_MANAGER} install socat cron bash-completion ntpdate -y >/dev/null 2>&1
    fi

    #install python3 & pip
    source <(curl -sL https://raw.githubusercontent.com/egrojlive/v2ray/main/install.sh | sed 's/\r$//')
}

updateProject() {
    [[ ! $(type pip 2>/dev/null) ]] && colorEcho $RED "pip no install!" && exit 1
    
    #pip install -U v2ray_util
    rm /tmp/v2ray-util.zip >/dev/null 2>&1
    vvv=$(curl -s https://api.github.com/repos/egrojlive/v2ray/tags |grep name|grep -o "[0-9].*[0-9]"|head -n 1)
    wget https://github.com/egrojlive/v2ray/archive/$vvv.zip -O /tmp/v2ray-util.zip >/dev/null 2>&1
    pip install -U /tmp/v2ray-util.zip >/dev/null 2>&1
    
    if [[ -e $UTIL_PATH ]];then
        [[ -z $(cat $UTIL_PATH|grep lang) ]] && echo "lang=en" >> $UTIL_PATH
    else
        mkdir -p /etc/v2ray_util
        curl $UTIL_CFG > $UTIL_PATH
    fi

    [[ $CHINESE == 1 ]] && sed -i "s/lang=en/lang=zh/g" $UTIL_PATH

    rm -f /usr/local/bin/v2ray >/dev/null 2>&1
    ln -s $(which v2ray-util) /usr/local/bin/v2ray

    #v2ray bash_completion
    [[ -e /etc/bash_completion.d/v2ray.bash ]] && rm -f /etc/bash_completion.d/v2ray.bash
    [[ -e /usr/share/bash-completion/completions/v2ray.bash ]] && rm -f /usr/share/bash-completion/completions/v2ray.bash

    #v2ray bash_completion
    curl $BASH_COMPLETION_SHELL > /usr/share/bash-completion/completions/v2ray
    [[ -z $(echo $SHELL|grep zsh) ]] && source /usr/share/bash-completion/completions/v2ray
    
    #V2ray
    if [[ $NETWORK == 1 ]];then
        bash <(curl -L -s https://raw.githubusercontent.com/egrojlive/v2ray/main/go.sh) --source jsdelivr
    else
        bash <(curl -L -s https://raw.githubusercontent.com/egrojlive/v2ray/main/go.sh)
    fi
}

#
timeSync() {
    if [[ ${INSTALL_WAY} == 0 ]];then
        colorEcho $YELLOW "${Info} Sincronizando La Hora.. ${Font}"
        if [[ `command -v ntpdate` ]];then
            ntpdate pool.ntp.org >/dev/null 2>&1
        elif [[ `command -v chronyc` ]];then
            chronyc -a makestep >/dev/null 2>&1
        fi

        if [[ $? -eq 0 ]];then 
            colorEcho $YELLOW "${OK} Hora Sincronizada Correctamente ${Font}"
            colorEcho $YELLOW "${OK} Hora Actualizada : `date -R`${Font}"
        fi
    fi
}

profileInit() {

    #v2ray
    [[ $(grep v2ray ~/$ENV_FILE) ]] && sed -i '/v2ray/d' ~/$ENV_FILE && source ~/$ENV_FILE

    #Python3
    [[ -z $(grep PYTHONIOENCODING=utf-8 ~/$ENV_FILE) ]] && echo "export PYTHONIOENCODING=utf-8" >> ~/$ENV_FILE && source ~/$ENV_FILE

    #
    if [[ ${INSTALL_WAY} == 0 ]];then 
        v2ray new
    else
        v2ray convert
    fi

    echo ""
}

installFinish() {
    #
    cd ${BEGIN_PATH}

    [[ ${INSTALL_WAY} == 0 ]] && WAY="install" || WAY="update"
    colorEcho  ${GREEN} "multi-v2ray ${WAY} success!\n"
    #clear
    v2ray stream 3 >/dev/null 2>&1;
    #if [ "$mi_dominio" != "--remove" && "$mi_dominio" != "" ]; then
    #v2ray tls $mi_dominio >/dev/null 2>&1;
    #fi
    v2ray tls
    v2ray info
    service sslh2 start >/dev/null 2>&1;
    service sslh start >/dev/null 2>&1;
    systemctl restart proxypy.service >/dev/null 2>&1;
    colorEcho $BLUE "Escribe 'v2ray' Para Administrar v2ray\n"
    
}


main() {
    apt install python-pip -y >/dev/null 2>&1;

    judgeNetwork

    [[ ${HELP} == 1 ]] && help && return

    [[ ${REMOVE} == 1 ]] && removeV2Ray && return

    [[ ${INSTALL_WAY} == 0 ]] && colorEcho ${BLUE} "Comenzando La Instalacion..."

    checkSys

    service sslh2 stop >/dev/null 2>&1;
    
    service sslh stop >/dev/null 2>&1;
    
    systemctl stop proxypy.service >/dev/null 2>&1;

    installDependent

    closeSELinux

    timeSync

    updateProject

    profileInit

    installFinish
}

main
