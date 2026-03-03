#!/usr/bin/env bash

# If command is "dpkg -i ..." or "dpkg --install ...", inject -E
case "$1" in
  -i|--install)
    # dpkg -i  or  dpkg --install  → add -E right after
    exec dpkg.real "$1" -E "${@:2}"
    ;;
  *)
    # everything else → pass through unchanged
    exec dpkg.real "$@"
    ;;
esac