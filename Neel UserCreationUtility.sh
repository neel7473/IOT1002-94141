#!/bin/bash
# =========================================================
# UserCreationUtility.sh
# Author: Neel Patel
# =========================================================

INPUT_FILE="EmployeeNames.csv" 
new_users=0
new_groups=0

# --- Verify file existence ---
if [[ ! -f "$INPUT_FILE" ]]; then
  echo "Error: Input file '$INPUT_FILE' not found!"
  exit 1
fi

echo "Processing employee file: $INPUT_FILE"
echo "--------------------------------------------------------"

# --- Clean Windows CRLF line endings if any ---
if file "$INPUT_FILE" | grep -q CRLF; then
  echo "Converting Windows line endings..."
  sed -i 's/\r$//' "$INPUT_FILE"
fi

# --- Skip header automatically and process file ---
{
  read -r header
  while IFS=',' read -r firstname lastname department; do
    # Trim spaces
    firstname=$(echo "$firstname" | xargs)
    lastname=$(echo "$lastname" | xargs)
    department=$(echo "$department" | xargs)

    # Skip blanks
    [[ -z "$firstname" || -z "$lastname" || -z "$department" ]] && continue

    # Generate username: first letter of first name + first 7 of last name
    username=$(echo "${firstname:0:1}${lastname:0:7}" | tr '[:upper:]' '[:lower:]')

    # Check if user exists
    if id "$username" &>/dev/null; then
      echo "Error: User '$username' already exists. Skipping..."
      continue
    fi

    # --- Create user ---
    if useradd -m "$username" &>/dev/null; then
      echo "User '$username' created successfully."
      ((new_users++))
    else
      echo "Error: Failed to create user '$username'."
      continue
    fi

    # --- Check or create group ---
    if getent group "$department" >/dev/null; then
      echo "Note: Group '$department' already exists."
    else
      if groupadd "$department" &>/dev/null; then
        echo "Group '$department' created successfully."
        ((new_groups++))
      else
        echo "Error: Failed to create group '$department'."
        continue
      fi
    fi

    # --- Assign primary group ---
    if usermod -g "$department" "$username" &>/dev/null; then
      echo "User '$username' assigned to group '$department'."
    else
      echo "Error: Failed to assign '$username' to '$department'."
    fi

    echo "--------------------------------------------------------"
  done
} < <(tail -n +2 "$INPUT_FILE")

# --- Final summary ---
echo "========================================================"
echo "User & Group Creation Summary"
echo "--------------------------------------------------------"
echo "New users added: $new_users"
echo "New groups created: $new_groups"
echo "========================================================"
