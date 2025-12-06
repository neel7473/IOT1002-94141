#!/bin/bash
# InternetBlocker.sh
# Script to block all users from accessing the internet except IT department employees

# Path to employee CSV file
CSV_FILE="EmployeeNames.csv"

# Variable to keep count of IT users
it_user_count=0

# Read the CSV file line by line, skipping header (NR>1)
while IFS=, read -r FirstName LastName Department; do

    # Skip header line
    if [[ "$FirstName" == "FirstName" ]]; then
        continue
    fi
    
    # If department is IT, then allow HTTPS for that user
    if [[ "$Department" == "IT" ]]; then
        username="${FirstName,,}${LastName,,}"   # Convert to lowercase and combine as username
        echo "Allowing internet access for user: $username"

        # Create allow rule for IT user's HTTPS traffic
        sudo iptables -A OUTPUT -p tcp --dport 443 -m owner --uid-owner "$username" -j ACCEPT

        ((it_user_count++))
    fi

done < "$CSV_FILE"

# Allow access to local web server for all users
sudo iptables -A OUTPUT -p tcp --dport 443 -d 192.168.2.3 -j ACCEPT

# Block special access ports for everyone
sudo iptables -t filter -A OUTPUT -p tcp --dport 8003 -j DROP
sudo iptables -t filter -A OUTPUT -p tcp --dport 1979 -j DROP

# Final message to show how many IT users got access
echo "Internet access granted to $it_user_count users from the IT department."

exit 0
