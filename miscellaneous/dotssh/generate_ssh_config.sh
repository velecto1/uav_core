#!/bin/bash

key_name="~/.ssh/id_rsa_drone_login"

input=(
  'alfa' 'uav60' '192.168.69.160'
  'bravo' 'uav61' '192.168.69.161'
  'charlie' 'uav62' '192.168.69.162'
  'delta' 'uav63' '192.168.69.163'
  'echo' 'uav64' '192.168.69.164'
  'foxtrot' 'uav65' '192.168.69.165'
  'golf' 'uav66' '192.168.69.166'
  'hotel' 'uav67' '192.168.69.167'
  'india' 'uav68' '192.168.69.168'
  'juliett' 'uav90' '192.168.69.190'
  'kilo' 'uav69' '192.168.69.169'
  'lima' 'uav70' '192.168.69.170'
  'mike' 'uav71' '192.168.69.171'
  'papa' 'uav45' '192.168.69.145'
  'quebec' 'uav47' '192.168.69.147'
  'romeo' 'uav49' '192.168.69.149'
  'sierra' 'uav46' '192.168.69.146'
)

# get path to script
SCRIPT_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

if [ -x "$(whereis nvim | awk '{print $2}')" ]; then
 VIM_BIN="$(whereis nvim | awk '{print $2}')"
 HEADLESS="--headless"
elif [ -x "$(whereis vim | awk '{print $2}')" ]; then
 VIM_BIN="$(whereis vim | awk '{print $2}')"
 HEADLESS=""
fi

for ((i=0; i < ${#input[*]}; i++));
do
  ((i%3==0)) && nato[$i/3]="${input[$i]}"
  ((i%3==1)) && hostname[$i/3]="${input[$i]}"
  ((i%3==2)) && ip[$i/3]="${input[$i]}"
done

hostname=( "${hostname[@]}" "${nato[@]}" )
ip=( "${ip[@]}" "${ip[@]}" )

my_hostname=$( cat /etc/hostname )

for ((i=0; i < ${#hostname[*]}; i++)); do

  num=`cat ~/.ssh/config | grep "host ${hostname[i]}" | wc -l`
  if [ "$num" -lt "1" ]; then

    echo Creating new entry in .ssh/config for ${hostname[i]} ${ip[i]}

  else

    echo Updating entry in .ssh/config for ${hostname[i]} ${ip[i]}

    $VIM_BIN $HEADLESS -Ens -c "set ignorecase" -c "%g/.*host ${hostname[i]}.*/norm dap" -c "wqa" -- "$HOME/.ssh/config"

  fi

  echo "host ${hostname[i]}
	hostname ${ip[i]}
	user mrs
	identityfile $key_name
" >> ~/.ssh/config

  $VIM_BIN $HEADLESS -Ens -c "set ignorecase" -c "%g/${ip[i]}.*/norm dapGp" -c "wqa" -- "$HOME/.ssh/config"

  num=`cat /etc/hosts | grep ".* ${hostname[i]}" | wc -l`
  if [ "$num" -lt "1" ]; then

    echo Creating new entry in /etc/hosts for ${hostname[i]} ${ip[i]}

  else

    echo Updating entry in /etc/hosts for ${hostname[i]} ${ip[i]}

    sudo $VIM_BIN $HEADLESS -Ens -c "set ignorecase" -c "%g/.*${hostname[i]}/norm dd" -c "wqa" -- "/etc/hosts"

  fi

  # only do it if its another uav
  # this is neccessary for NimbroNetwork
  if [[ $my_hostname ~= $hostname ]]; then

    sudo bash -c "echo ${ip[i]} ${hostname[i]} >> /etc/hosts"

    sudo $VIM_BIN $HEADLESS -Ens -c "set ignorecase" -c "%g/${ip[i]}/norm ddGp" -c "wqa" -- "/etc/hosts"
    sudo $VIM_BIN $HEADLESS -Ens -c "set ignorecase" -c "normal Go" -c "wqa" -- "/etc/hosts"

  fi

done

sudo $VIM_BIN $HEADLESS -Ens -c "set ignorecase" -c "%g/^\\n$\\n$\\n/norm dd" -c "wqa" -- "/etc/hosts"
