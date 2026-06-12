#!/usr/bin/env bash
      read -p "Quante volte vuoi eseguire il ping pong? " n
      for ((i=1; i<=n; i++)); do
          podman start ping >/dev/null
          echo "Container ping eseguito"
          sleep 60
          podman stop ping >/dev/null
          ssh vagrant@192.168.56.12 "podman start pong >/dev/null"
          echo "Container pong eseguito"
          sleep 60 
          ssh vagrant@192.168.56.12 "podman stop pong >/dev/null"
      done