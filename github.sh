#!/usr/bin/env bash
# Don't use PATHS!
GITHUBPATHS="
.config/
.local/
.mozilla/
.spacemacs.d/
.uim.d/
filter-file
github.sh
my.rclone
shortcut
.gitmodules
.gitignore
.vimrc_bak
.xmobarrc
"
for GITHUBPATH in ${GITHUBPATHS}; do
  git add ${GITHUBPATH} --verbose
done
  git commit -m "$(date '+%y.%d.%m %H:%M:%S')" --verbose
  git push origin master
