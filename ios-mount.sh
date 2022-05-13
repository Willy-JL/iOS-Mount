#!/bin/bash

[[ $(tty) == "not a tty" ]] && gui=true || gui=false

if $gui ;
then
  zenity_status_file="$(mktemp)"
  zenity_pid_file="$(mktemp)"
fi
while true; do
  old_msg=""
  pair_status=""
  pair_cmd="idevicepair validate"
  while [ "$pair_status" != "0" ] ; do
    pair_output="$($pair_cmd 2>&1)"
    pair_status=$?
    pair_cmd="idevicepair validate"
    if [ "$pair_status" != "0" ] ; then
      case "$pair_output" in
        *"No device found"*)
          msg="Please connect an iOS device..."
          ;;
        *"Please enter the passcode on the device and retry"*)
          msg="Please unlock the device..."
          ;;
        *"Please accept the trust dialog on the screen of device"*)
          msg="Please accept the trust prompt on the device..."
          ;;
        *"the user denied the trust dialog"*)
          msg="The trust prompt was denied, please disconnect and reconnect the device..."
          ;;
        *"is not paired with this host"*)
          msg="$old_msg"
          if [ "$msg" = "" ] ; then
            msg="Pairing device..."
          fi
          pair_cmd="idevicepair pair"
          ;;
        *)
          msg="Something went wrong pairing the device...\\nError message:\\n$pair_output"
          ;;
      esac

      if $gui ; then
        zenity_pid="$(< "$zenity_pid_file")"
        if [ "$zenity_pid" != "" ] ; then
          ps -p $zenity_pid 2>&1 > /dev/null
          exists=$?
        else
          exists=0
        fi
      else
        exists=0
      fi
      
      if $gui ; then
        zenity_status="$(< "$zenity_status_file")"
        if [ "$zenity_status" != "" ] && [ "$zenity_status" != "0" ] ; then
          exit
        fi
      fi

      if [ "$old_msg" != "$msg" ] || [ "$exists" != "0" ] ; then
        old_msg="$msg"
        if $gui ; then
          if [ "$exists" = "0" ] && [ "$zenity_pid" != "" ] ; then
            kill $zenity_pid
          fi
          {
            zenity --error --no-wrap --text "$msg" &
            zenity_pid=$!
            echo $zenity_pid > "$zenity_pid_file"
            wait $zenity_pid
            echo $? > "$zenity_status_file"
          } &
        else
          echo -e "$msg"
        fi
      fi
      sleep 0.25
    fi
  done
  if $gui && [ "$zenity_pid" != "" ] ; then
    ps -p $zenity_pid 2>&1 > /dev/null
    exists=$?
    if [ "$exists" = "0" ] && [ "$zenity_pid" != "" ] ; then
      kill $zenity_pid
    fi
  fi

  unset apps
  declare -A apps
  while IFS=: read -r name identifier ; do
    apps["$name"]="$identifier"
  done <<< $(ifuse --list-apps | grep -v CFBundleIdentifier | awk -F '","' '{printf "%s:%s\n", substr($3, 1, length($3)-1), substr($1, 2)}' | sort)
  unset options
  declare -a options
  options[0]="Filesystem (Photos and Media)"
  while IFS='' read app ; do
    options+=("$app")
  done <<< $(for app in "${!apps[@]}" ; do echo "$app" ; done | sort)

  if $gui ; then
    choice=$(zenity --list --width 250 --height 300 --hide-header --text "What should be mounted?" --column "" "${options[@]}")
    if [ "$?" != "0" ] ; then
      exit
    fi
  else
    oldps3="$PS3"
    PS3="Select option number: "
    echo "Available apps:"
    select choice in "${options[@]}" ; do break ; done
    PS3="$oldps3"
  fi
  if [ "$choice" != "Filesystem (Photos and Media)" ] ; then
    if [[ ! -v apps["$choice"] ]] ; then
      echo "No option selected, exiting..."
      exit 0
    fi
  fi
  mountpoint="$HOME/iOS-Mount"
  mkdir -p "$mountpoint" 2>&1 > /dev/null
  ifuse_output="$(fusermount -u -z "$mountpoint" 2>&1)"
  ifuse_status=$?
  if [ "$ifuse_status" != "0" ] && [[ "$ifuse_output" != *"not found"* ]] ; then
    msg="Something went wrong while preparing $mountpoint...\\nError message:\\n$ifuse_output"
    if $gui ; then
      zenity --error --no-wrap --text "$msg"
      if [ "$?" != "0" ] ; then
        exit
      fi
    else
      echo -e "$msg"
    fi
    continue
  fi
  if [ "$choice" = "Filesystem (Photos and Media)" ] ; then
    ifuse_output="$(ifuse "$mountpoint" 2>&1)"
    ifuse_status=$?
    if [ "$ifuse_status" = "0" ] ; then
      msg="Successfully mounted device filesystem on $mountpoint!"
    else
      msg="Something went wrong while mounting device filesystem on $mountpoint..."
    fi
  else
    ifuse_output="$(ifuse --documents "${apps["$choice"]}" "$mountpoint" 2>&1)"
    ifuse_status=$?
    if [ "$ifuse_status" = "0" ] ; then
      msg="Successfully mounted $choice on $mountpoint!"
    else
      msg="Something went wrong while mounting $choice on $mountpoint..."
    fi
  fi
  if [ "$ifuse_status" = "0" ] ; then
    if $gui ; then
      xdg-open "$mountpoint"
      zenity --info --no-wrap --text "$msg\\nClose this window when you are done and want to unmount!"
    else
      echo -e "$msg\\nPress [ENTER] when you are done and want to unmount!"
      read
    fi
  else
    msg="$msg\\nError message:\\n$ifuse_output"
    if $gui ; then
      zenity --error --no-wrap --text "$msg"
      if [ "$?" != "0" ] ; then
        exit
      fi
    else
      echo -e "$msg"
    fi
    continue
  fi
  ifuse_output="$(fusermount -u -z "$mountpoint" 2>&1)"
  ifuse_status=$?
  if [ "$ifuse_status" = "0" ] ; then
    msg="Successfully unmounted $mountpoint!"
    if $gui ; then
      zenity --info --no-wrap --text "$msg"
    else
      echo -e "$msg"
    fi
  else
    msg="Something went wrong while unmounting $mountpoint...\\nError message:\\n$ifuse_output"
    if $gui ; then
      zenity --error --no-wrap --text "$msg"
      if [ "$?" != "0" ] ; then
        exit
      fi
    else
      echo -e "$msg"
    fi
    continue
  fi
done
