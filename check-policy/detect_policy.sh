#!/bin/bash

# Enable debug mode
#set -x

# Retrieve all policy assignments
policy_assignments=$(az policy assignment list)

# Process each policy assignment
echo "$policy_assignments" | jq -c '.[]' | while read -r policy_assignment; do
    # Display the policy assignment name
    echo "Processing Policy Assignment: $(echo "$policy_assignment" | jq -r '.name')"

    # Get the policy definition ID
    policy_definition_id=$(echo "$policy_assignment" | jq -r '.policyDefinitionId')
    echo "Policy Definition ID: $policy_definition_id"

    # Check if policyDefinitionId is not empty
    if [ -z "$policy_definition_id" ]; then
        echo "Policy Definition ID is empty, skipping."
        continue
    fi

    # Extract the policy definition name
    policy_definition_name=$(basename "$policy_definition_id")
    echo "Policy Definition Name: $policy_definition_name"

    # Extract the subscription ID (if applicable)
    subscription_id=$(echo "$policy_definition_id" | awk -F'/' '/subscriptions/ {print $3}')

    # Retrieve the policy definition
    if [ -n "$subscription_id" ]; then
        # For subscription scope
        policy_definition=$(az policy definition show --name "$policy_definition_name" --subscription "$subscription_id" 2>/dev/null)
    else
        # For tenant scope
        policy_definition=$(az policy definition show --name "$policy_definition_name" 2>/dev/null)
    fi

    # Check if policy_definition was successfully retrieved
    if [ -z "$policy_definition" ]; then
        echo "Policy Definition could not be retrieved, skipping."
        continue
    fi

    # Display the policy definition details (for debugging)
    echo "Policy Definition Retrieved: $policy_definition"

    # Check if the policy definition applies to storage accounts
    if echo "$policy_definition" | jq -e '.policyRule' | grep -q 'Microsoft.Storage/storageAccounts'; then
        echo "Policy applies to Microsoft.Storage/storageAccounts"
        # Check if the policy uses allowBlobPublicAccess
        if echo "$policy_definition" | jq -e '.policyRule' | grep -q 'allowBlobPublicAccess'; then
            echo "Policy checks for allowBlobPublicAccess"
            # Check if the policy effect is 'Deny'
            effect=$(echo "$policy_definition" | jq -r '.policyRule.then.effect')
            echo "Policy effect: $effect"
            if [[ "$effect" == "Deny" ]]; then
                echo "A policy that denies public access to storage accounts has been found:"
                echo "Policy Assignment Name: $(echo "$policy_assignment" | jq -r '.name')"
                echo "Policy Definition Name: $(echo "$policy_definition" | jq -r '.name')"
                echo "Policy Display Name: $(echo "$policy_definition" | jq -r '.displayName')"
                echo "Scope: $(echo "$policy_assignment" | jq -r '.scope')"
            else
                echo "Policy effect is not 'Deny', skipping."
            fi
        else
            echo "Policy does not check for allowBlobPublicAccess, skipping."
        fi
    else
        echo "Policy does not apply to Microsoft.Storage/storageAccounts, skipping."
    fi
done
