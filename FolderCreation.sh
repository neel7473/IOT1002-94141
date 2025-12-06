#!/bin/bash
# FolderCreation.sh
# Creates /EmployeeData folder structure and sets groups & permissions
# Usage: sudo ./FolderCreation.sh

if [[ $(id -u) -ne 0 ]]; then
  echo "This script must be run as root. Use: sudo ./FolderCreation.sh"
  exit 1
fi

BASE="/EmployeeData"
declare -a folders=("HR" "IT" "Finance" "Executive" "Administrative" "Call Centre")
declare -a groups=("hr" "it" "finance" "executive" "administrative" "callcentre")

# Create base dir
mkdir -p "$BASE" || { echo "Failed to create $BASE"; exit 1; }

count=0

# Ensure groups exist
for g in "${groups[@]}"; do
  if ! getent group "$g" >/dev/null; then
    groupadd "$g" && echo "Group '$g' created." || echo "Failed to create group '$g' (maybe exists or permission issue)."
  fi
done

# Create folders and set ownership/permissions
for i in "${!folders[@]}"; do
  fname="${folders[$i]}"
  gname="${groups[$i]}"
  target="$BASE/$fname"

  mkdir -p "$target" || { echo "Error: could not create $target"; continue; }

  # owner root, group = department group
  chown root:"$gname" "$target" || echo "Warning: chown failed for $target"

  # Sensitive folders: HR and Executive
  if [[ "$fname" == "HR" || "$fname" == "Executive" ]]; then
    chmod -R 760 "$target" || echo "Warning: chmod failed for $target"
  else
    chmod -R 764 "$target" || echo "Warning: chmod failed for $target"
  fi

  ((count++))
  echo "Created: $target  (group: $gname)"
done

echo ""
echo "$count folders were successfully created under $BASE"
exit 0
