#!/usr/bin/env bash

# Select a running Docker container and exec a shell into it
container=$(docker ps --format '{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}' | \
  fzf --no-tmux --header 'Select container to exec into' \
      --preview 'docker logs --tail 30 {1}' \
      --exit-0 | \
  awk '{print $1}')

if [[ -n "$container" ]]; then
  docker exec -it "$container" /bin/sh
fi
