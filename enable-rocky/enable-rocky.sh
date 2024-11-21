#!/bin/bash

# Get the list of subscriptions
subscriptions=$(az account list --query "[].{Name:name, ID:id}" -o json)

# Check if there are any subscriptions
if [ "$(echo $subscriptions | jq length)" -eq 0 ]; then
    echo "No subscriptions found."
    exit 1
fi

# Display the list of subscriptions
echo "Available subscriptions:"
echo ""

count=$(echo $subscriptions | jq length)

for ((i=0; i<$count; i++)); do
    name=$(echo $subscriptions | jq -r ".[$i].Name")
    id=$(echo $subscriptions | jq -r ".[$i].ID")
    echo "$(($i+1)). $name ($id)"
done

echo ""

# Prompt the user to select a subscription
read -p "Please select a subscription by entering its number (1-$count): " selection

# Validate user input
if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt $count ]; then
    echo "Invalid selection."
    exit 1
fi

# Get the selected subscription ID
index=$(($selection - 1))
selected_subscription_id=$(echo $subscriptions | jq -r ".[$index].ID")

echo ""
echo "Selected subscription ID: $selected_subscription_id"

# Execute the command
echo ""
echo "Executing the command..."
echo ""

output=$(az vm image terms accept --publisher ciq --offer rocky-8-hpc-ai --plan rocky-linux-hpc-8-10-nvidia --subscription "$selected_subscription_id" -o json)

# Check if "accepted": true in the output JSON
if echo "$output" | jq -e '.accepted == true' > /dev/null; then
    echo -e "\e[32mRockyOS activation successful.\e[0m"
else
    echo "RockyOS activation failed."
fi

echo ""
echo "Command Output:"
echo "$output"
