#!/bin/bash

bl(){
  while getopts 'rgbpfias:h' opt; do
    case "${opt}" in
      r)var3="\e[0;31m";;g)var3="\e[0;32m";;
      b)var3="\e[0;34m";;p)var3="\e[0;2m";;
      f)var3+="\e[1m";;i)var3+="\e[3m";;
      a)var3="\e[0;31m\e[1m[∆] ";;
      s)var3="\e[0;32m\e[1m[√] ";;
      ?|h)
        echo -e "\e[1mUsage: \e[0;m";
        echo -e " -r  red\n -g  green\n -b  blue\n -p  pearly<Grey>
 -f  fearless<Bold>\n -i  italic\n -a  alert\n -s  success";return 1;;
    esac
  done
  if [[ -z "${2}" ]]; then echo -e "\e[0;32m\e[3m\e[1m[√] Hello World\e[0;m";return 1;
  else echo -e "${var3}${2}\e[0;m";return 0;fi
}

Spin(){
  echo;_PID=${!};i=1;_spins=('█■■■■' '■█■■■' '■■█■■' '■■■█■' '■■■■█');echo -n ' ';
  while [ -d /proc/${_PID} ];do
  for _snip in ${_spins[@]} ; do echo -ne "\r\e[0;2mLoading...[${_snip}]\e[0;m ";sleep 0.2;done;done;echo;echo;return;
}

pkg_build(){
  pkg_info=${1};
  if [[ -z "${pkg_info}" ]]; then echo;bl -a "Package parameter is Empty...";echo;return 1;fi
  (ping -c 3 google.com) &> /dev/null 2>&1;
  if [[ "${?}" != 0 ]]; then echo;bl -a "Internet Connection Error...";echo;return 1;fi
  _pkg_var2=$(eval "apt search ${pkg_info} 2> /dev/null");
  if [[ "${_pkg_var2}" != *"stable"* ]]; then echo;bl -a "Package does not Exist...";echo;return 1;fi
  count=0;total=34;pstr="[======================================]";echo;bl -s "Installing ${pkg_info}...";echo -e "\e[0;2m";
  while [ $count -lt $total ]; do
    eval "apt-get install ${pkg_info} -y &> /dev/null || sudo apt-get install ${pkg_info} -y &> /dev/null";
    count=$(( $count + 1 ));pd=$(( $count * 73 / $total ));
    printf "\r%3d.%1d%% %.${pd}s" $(( $count * 100 / $total )) $(( ($count * 1000 / $total) % 10 )) $pstr;done;echo -e "\e[0;m";echo;return 0;
}

dnload(){
  _file_link=${1};prova="curl -OL "; # prova = process variable
  if [[ -z "${_file_link}" ]]; then echo;bl -a "Link parameter is Empty...";echo;return 1;fi
  (ping -c 3 google.com) &> /dev/null 2>&1;
  if [[ "${?}" != 0 ]]; then echo;bl -a "Internet Connection Error...";echo;return 1;fi
  prova+="${_file_link} &> /dev/null";echo;bl -s "Downloading File...";
  (eval "${prova}" & Spin) || (echo;bl -a "Unknown Error..."echo;return 1;)
}

dnrepo(){
  _repo_link=${1};_file_link="${2}";prova="git clone https://github.com/"; # prova = process variable
  if [[ -z "${_repo_link}" ]]; then echo;bl -a "Repository parameter is Empty...";echo;return 1;fi
  if [[ -z "${_file_link}" ]]; then echo;bl -a "File parameter is Empty...";echo;return 1;fi
  (ping -c 3 google.com) &> /dev/null 2>&1;
  if [[ "${?}" != 0 ]]; then echo;bl -a "Internet Connection Error...";echo;return 1;fi
  prova+="${_repo_link}.git ${_file_link} --depth 1 &> /dev/null";
  count=0;total=34;pstr="[======================================]";echo;bl -s "Cloning ${_repo_link}...";echo -e "\e[0;2m";
  while [ $count -lt $total ]; do
    eval "${prova}";count=$(( $count + 1 ));pd=$(( $count * 73 / $total ));
    printf "\r%3d.%1d%% %.${pd}s" $(( $count * 100 / $total )) $(( ($count * 1000 / $total) % 10 )) $pstr;done;echo -e "\e[0;m";echo;return 0;
}

phase2(){
  if [[ -f "${HOME}/.ui/p2.dl" ]]; then return 0;
  else
    {
      dnrepo "ohmyzsh/ohmyzsh" "${HOME}/.oh-my-zsh";
      dnrepo "zsh-users/zsh-syntax-highlighting" "${HOME}/.zsh-syntax-highlighting";
    } && {
      if [[ -e "${HOME}/.zshrc" ]]; then
        mv "${HOME}/.zshrc" "${HOME}/.zshrc.bak.$(date +%Y.%m.%d-%H:%M:%S)"
      fi
      cp "${HOME}/.oh-my-zsh/templates/zshrc.zsh-template" "${HOME}/.zshrc"
      sed -i '/^ZSH_THEME/d' "${HOME}/.zshrc"
      sed -i '1iZSH_THEME="agnoster"' "${HOME}/.zshrc"
      echo "alias chcolor='${HOME}/.termux/colors.sh'" >> "${HOME}/.zshrc"
      echo "alias chfont='${HOME}/.termux/fonts.sh'" >> "${HOME}/.zshrc"
    } && {
      echo "source ${HOME}/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> "${HOME}/.zshrc"
    } && {
      chsh -s zsh
    } && {
      chmod +x ${HOME}/.termux/colors.sh
      chmod +x ${HOME}/.termux/fonts.sh
      echo -e "\e[0;m"
      ${HOME}/.termux/colors.sh
      ${HOME}/.termux/fonts.sh
      echo
      echo "1" >> "${HOME}/.ui/p2.dl"
      bl -s "Please restart Termux app..."
      rm -rf ${HOME}/../usr/etc/motd* &> /dev/null
      echo
      return 0
    }
  fi
}

phase1(){
  if [[ -f "${HOME}/.ui/p1.dl" ]]; then phase2;return 0;
  else
    if [[ -d "${HOME}/.termux" ]]; then mv "${HOME}/.termux" "${HOME}/.termux.bak.$(date +%Y.%m.%d-%H:%M:%S)";fi
    dnload "https://github.com/strangecode4u/TermUi/raw/main/TermUi.zip";
    bl -s "Unpacking Files...";(unzip -d ${HOME} TermUi.zip &> /dev/null) & Spin
    rm TermUi.zip;echo "1" > ${HOME}/.ui/p1.dl;phase2;return 0;fi
}

starts(){
  clear;echo;
  if [[ ! -d "${HOME}/storage/shared" ]]; then bl -s "Please Allow Storage Permission...";eval "termux-setup-storage";fi
  mkdir -p "${HOME}/.ui";pkg_build git;pkg_build zsh;phase1;return 0;
}

starts