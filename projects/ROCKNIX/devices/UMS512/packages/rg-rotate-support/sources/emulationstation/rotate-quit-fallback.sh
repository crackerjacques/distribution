#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)
#
# EmulationStation's teardown can stall on the audio stream before it runs the
# shutdown command. Arm the same action as a fallback.
case "$(basename "$(dirname "$0")")" in
	reboot) action=reboot ;;
	*) action=poweroff ;;
esac

systemd-run --on-active=10 --timer-property=AccuracySec=1s systemctl "$action"
