#!/usr/bin/env bash
#
# dochat.sh - Docker WeChat for Linux
#
#   Author: Huan (李卓桓) <zixia@zixia.net>
#   Copyright (c) 2020-now
#
#   License: Apache-2.0
#   GitHub: https://github.com/huan/docker-wechat
#
set -eo pipefail

function main () {

  DEVICE_ARG=()
  # change /dev/video* to /dev/nvidia* for Nvidia
  for DEVICE in /dev/video* /dev/snd; do
    DEVICE_ARG+=('--device' "$DEVICE")
  done
  if [[ $(lshw -C display | grep vendor) =~ NVIDIA ]]; then
    DEVICE_ARG+=('--gpus' 'all' '--env' 'NVIDIA_DRIVER_CAPABILITIES=all')
  fi

  # Issue #111 - https://github.com/huan/docker-wechat/issues/111
  rm -f "$HOME/WeChat/Applcation Data/Tencent/WeChat/All Users/config/configEx.ini"

  #
  # --privileged: enable sound (/dev/snd/)
  # --ipc=host:   enable MIT_SHM (XWindows)
  #
  docker run \
    "${DEVICE_ARG[@]}" \
    --name DoChat \
    --rm \
    -i \
    \
    -v "$HOME/WeChat/WeChat Files/":'/home/user/WeChat Files/' \
    -v "$HOME/WeChat/Applcation Data":'/home/user/.wine/drive_c/users/user/Application Data/' \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    \
    -e DISPLAY \
    -e DOCHAT_DEBUG \
    -e DOCHAT_DPI \
    \
    -e XMODIFIERS \
    -e GTK_IM_MODULE \
    -e QT_IM_MODULE \
    \
    -e AUDIO_GID="$(getent group audio | cut -d: -f3)" \
    -e VIDEO_GID="$(getent group video | cut -d: -f3)" \
    -e GID="$(id -g)" \
    -e UID="$(id -u)" \
    --ipc=host \
    `#--privileged` \
    \
    wechat

    echo "WeChat Exited with code $?"

  rm -rf "$HOME/WeChat/Applcation Data/Tencent/WeChat/xweb/crash/Crashpad/reports"
}

main
