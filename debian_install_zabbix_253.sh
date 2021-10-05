#!/bin/bash
set -e
# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command filed with exit code $?."' ERR

RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'

if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo -e "${GREEN}OK!   ${NC} /etc/os-release found."
    OS=$NAME
    VER=$VERSION_ID
else
    echo -e "${RED}ERROR!${NC} Cannot get Debian version!"
    exit 1
fi

if [[ $OS = *"Debian"* ]]; then
    echo -e "${GREEN}OK!   ${NC} This is Debian."
else
    echo -e "${RED}ERROR!${NC} This is not Debian!"
    exit 1
fi

if [ $VER = "9" ]; then
    echo -e "${GREEN}OK!   ${NC} Debian version is 9."
elif [ $VER = "10" ]; then
    echo -e "${GREEN}OK!   ${NC} Debian version is 10."
else
    echo -e "${RED}ERROR!${NC} Wrong Debian version!"
    exit 1
fi

echo -e "${BLUE}INFO!  ${NC}Zabbix version to install is 5.4"

if [ ! -x /usr/bin/wget ]; then
    echo -e "${RED}ERROR!${NC} wget is not installed!"
    echo -e "${BLUE}INFO!  ${NC}Installing wget..."
    apt update &>/dev/null
    apt install wget -y &>/dev/null
    echo -e "${GREEN}OK!   ${NC} wget installed."
fi

if [ $VER = "9" ]; then
    cd /tmp/
    echo -e "${BLUE}INFO!  ${NC}Downloading zabbix repository..."
    wget --no-check-certificate https://repo.zabbix.com/zabbix/5.4/debian/pool/main/z/zabbix-release/zabbix-release_5.4-1+debian9_all.deb &>/dev/null
    echo -e "${GREEN}OK!   ${NC} Zabbix repository downloaded."
    echo -e "${BLUE}INFO!  ${NC}Installing zabbix repository..."
    dpkg -i zabbix-release_5.4-1+debian9_all.deb &>/dev/null
    echo -e "${GREEN}OK!   ${NC} Zabbix repository installed."
    rm /tmp/zabbix-release_5.4-1+debian9_all.deb || true
    echo -e "${BLUE}INFO!  ${NC}Installing zabbix-agent..."
    apt update &>/dev/null
    apt install zabbix-agent -y &>/dev/null
    echo -e "${GREEN}OK!   ${NC} Zabbix-agent installed."
    echo -e "${BLUE}INFO!  ${NC}Setting up zabbix-agent..."
    rm /etc/zabbix/zabbix_agentd.conf || true
    echo "PidFile=/var/run/zabbix/zabbix_agentd.pid" >>/etc/zabbix/zabbix_agentd.conf
    echo "Server=zabbix-proxy-exea-dmz.systell.pl" >>/etc/zabbix/zabbix_agentd.conf
    echo "ServerActive=zabbix-proxy-exea-dmz.systell.pl" >>/etc/zabbix/zabbix_agentd.conf
    echo "HostnameItem=system.hostname" >>/etc/zabbix/zabbix_agentd.conf
    echo "LogFile=/var/log/zabbix/zabbix_agentd.log" >>/etc/zabbix/zabbix_agentd.conf
    echo -e "${GREEN}OK!   ${NC} config file is set up now."
    echo -e "${BLUE}INFO!  ${NC}restarting zabbix-agent..."
    systemctl restart zabbix-agent
    echo -e "${GREEN}OK!   ${NC} zabbix-agent restarted."
elif [ $VER = "10" ]; then
    cd /tmp/
    echo -e "${BLUE}INFO!  ${NC}Downloading zabbix repository..."
    wget --no-check-certificate https://repo.zabbix.com/zabbix/5.4/debian/pool/main/z/zabbix-release/zabbix-release_5.4-1+debian10_all.deb &>/dev/null
    echo -e "${GREEN}OK!   ${NC} Zabbix repository downloaded."
    echo -e "${BLUE}INFO!  ${NC}Installing zabbix repository..."
    dpkg -i zabbix-release_5.4-1+debian10_all.deb &>/dev/null
    echo -e "${GREEN}OK!   ${NC} Zabbix repository installed."
    rm /tmp/zabbix-release_5.4-1+debian10_all.deb || true
    echo -e "${BLUE}INFO!  ${NC}Installing zabbix-agent..."
    apt update &>/dev/null
    apt install zabbix-agent -y &>/dev/null
    echo -e "${GREEN}OK!   ${NC} Zabbix-agent installed."
    echo -e "${BLUE}INFO!  ${NC}Setting up zabbix-agent..."
    rm /etc/zabbix/zabbix_agentd.conf || true
    echo "PidFile=/var/run/zabbix/zabbix_agentd.pid" >>/etc/zabbix/zabbix_agentd.conf
    echo "Server=zabbix-proxy-exea-dmz.systell.pl" >>/etc/zabbix/zabbix_agentd.conf
    echo "ServerActive=zabbix-proxy-exea-dmz.systell.pl" >>/etc/zabbix/zabbix_agentd.conf
    echo "HostnameItem=system.hostname" >>/etc/zabbix/zabbix_agentd.conf
    echo "LogFile=/var/log/zabbix/zabbix_agentd.log" >>/etc/zabbix/zabbix_agentd.conf
    echo -e "${GREEN}OK!   ${NC} config file is set up now."
    echo -e "${BLUE}INFO!  ${NC}restarting zabbix-agent..."
    systemctl restart zabbix-agent
    echo -e "${GREEN}OK!   ${NC} zabbix-agent restarted."
else
    echo -e "${RED}ERROR!${NC} Wrong Debian version!"
    exit 1
fi

echo -e "${YELLOW}REMEMBER TO SET UP FIREWALL!${NC}"
echo -e "${YELLOW}iptables -A INPUT -s 10.200.253.90 -p tcp -m multiport --dports 10050:10051${NC}"
echo -e "${GREEN}OK!   ${NC} All done."
