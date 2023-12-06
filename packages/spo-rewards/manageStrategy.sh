#!/bin/bash

source ./common.sh

cat <<EOF

 +---------------------------------------------------------------+
 |                                                               |
 |$(echo -e "${BOLD}          ____       _       ____                              ${NC}")|
 |$(echo -e "${BOLD}         |  _ \ _ __(_)_ __ |  _ \ _ __ ___  _ __ ____         ${NC}")|
 |$(echo -e "${BOLD}         | | | | '__| | '_ \| | | | '__/ _ \| '_ \_  /         ${NC}")|
 |$(echo -e "${BOLD}         | |_| | |  | | |_) | |_| | | | (_) | |_) / /          ${NC}")|
 |$(echo -e "${BOLD}         |____/|_|  |_| .__/|____/|_|  \___/| .__/___|         ${NC}")|
 |$(echo -e "${BOLD}                      |_|                   |_|                ${NC}")|
 |                                                               |
 |$(echo -e "${INFO}                   REWARDS STRATEGY CREATOR                    ${NC}")|
 +---------------------------------------------------------------+

EOF

# Create a strategies directory (if it doesn't exist) to store reward strategy configuration files
mkdir -p ./strategies

echo -e "
  This script is designed to help you create and test your
  rewards strategies. To get started, please choose one of
  the options below!"

# Check if there are existing strategy files!
if [ -z "$(ls -A ./strategies/)" ]; then
   echo -e "\n  ${REKT}No existing rewards strategies found!${NC}\n"
   has_strategies=0
else
   echo -e "\n  ${SUCCESS}Existing rewards strategies found!${NC}\n"
   has_strategies=1
fi

while [[ "${user_option,,}" != "q" ]]
do
  echo "  Please select an option:"
  echo -e "  ${BOLD}1${NC}) Create a new strategy"
  if [[ "${has_strategies}" == 1 ]]; then
    echo -e "  ${BOLD}2${NC}) Review existing strategy"
  fi
  echo -e "  ${BOLD}q${NC}) Quit"
  read -r user_option
  if [[ "${user_option,,}" == "q" ]]; then
    echo -e "  ${BOLD}GOODBYE!${NC}"
  fi

  if [[ "${user_option,,}" == 1 ]]; then

    while [[ "${strategy_saved}" != 1 ]]
    do
      # Do create new strategy here
      echo -e "\n  ${INFO}${BOLD}Let's create a new strategy!${NC}"
      echo -e "
  How would you like to reward delegators?
  ${BOLD}1${NC}) A flat rate for all eligible addresses
  ${BOLD}2${NC}) An amount of tokens per ada delegated
  ${BOLD}q${NC}) Quit
  Please enter your choice:"
      read -r reward_strategy
      if [[ "${reward_strategy,,}" == "q" ]]; then
        break
      elif [[ "${reward_strategy}" == 1 ]]; then
        # Flat Rate Strategy here
        echo -e "
  How many tokens should we issue to each address? [1..n]"
        read -r flat_rate_amount
        flat_rate_amount="${flat_rate_amount:-1}"
        strategy="${flat_rate_amount} tokens per address"
      elif [[ "${reward_strategy}" == 2 ]]; then
        # Per ada Strategy here
        echo -e "
  How many tokens should we issue to each address per
  1 ada delegated? [1..n]"
        read -r per_ada_amount
        per_ada_amount="${per_ada_amount:-1}"
        strategy="${per_ada_amount} tokens per ada delegated"
      fi

      echo -e "
  What is the minimum amount of tokens each address
  should receive? Set to zero to disable [0..n]"
      read -r min_reward
      min_reward="${min_reward:-0}"

      echo -e "
  What is the maximum amount of tokens any address
  should receive? Set to zero to disable [0..n]"
      read -r max_reward
      max_reward="${max_reward:-0}"

      echo -e "
  What is the minimum amount of Lovelace an address
  must delegate in order to receive rewards?
  Minimum of 1 Lovelace [1..n]"
      read -r min_lovelace
      min_lovelace="${min_lovelace:-1}"

      echo -e "
  What is the minimum number of epochs an address
  must delegate in order to receive rewards? Set to
  zero to disable [0..n]"
      read -r min_loyalty
      min_loyalty="${min_loyalty:-0}"

      echo -e "
  What bonus modifier should we give to each eligible
  address for each epoch they have been delegated?
  This should be specified as a floating point number
  between 1.000000 - 2.000000. Default: [1.0, no bonus]"
      read -r loyalty_mod
      loyalty_mod="${loyalty_mod:-1}"

      echo -e "\n+----------------------------------------------------------------+"
      echo -e "|                    ${BOLD}REWARD STRATEGY SUMMARY${NC}                     |"
      echo -e "+----------------------------------------------------------------+"

      echo -e "
  ${BOLD}Reward:${NC} ${strategy}
  ${BOLD}Minimum Rewards:${NC} ${min_reward} Tokens
  ${BOLD}Maximum Rewards:${NC} ${max_reward} Tokens
  ${BOLD}Rewards Modifier:${NC} ${loyalty_mod}
  ${BOLD}Minimum Lovelace:${NC} ${min_lovelace} Lovelace
  ${BOLD}Minimum Loyalty:${NC} ${min_loyalty} Epochs\n"

      echo -e "+----------------------------------------------------------------+"
      echo -e "| ${INFO}Example Delegator A:${NC} ${BOLD}100A Delegator, 10 Epochs Loyalty${NC}         |"
      echo -e "+----------------------------------------------------------------+"
      if [[ "${min_lovelace}" -gt 100000000 ]]; then
        echo -e "  ${REKT}Delegator does not have the minimum amount of Lovelace required (${min_lovelace}).${NC}\n"
      elif [[ "${min_loyalty}" -gt 10 ]]; then
        echo -e "  ${REKT}Delegator has not been delegating long enough!${NC}\n"
      else
        rewards_a=$((reward_strategy == 1 ? flat_rate_amount : 100 * per_ada_amount))
        echo -e "  ${BOLD}Base Rewards:${NC} ${rewards_a}"
        modifier=$( echo "$loyalty_mod ^ 10"|bc )
        echo -e "  ${BOLD}Modifier:${NC} ${modifier}"
        rewards_a=$(printf "%.0f" "$(echo "${rewards_a} * ${modifier}"|bc)")
        echo -e "  ${BOLD}Modified Rewards:${NC} ${rewards_a}"
        if [[ "${max_reward}" -gt 0 ]]; then
          echo -e "  ${BOLD}Max Rewards:${NC} ${max_reward} Tokens Max"
          rewards_a=$(min "${max_reward}" "${rewards_a}")
        fi
        if [[ "${min_reward}" -gt 0 ]]; then
          echo -e "  ${BOLD}Min Reward:${NC} ${min_reward} Tokens Min"
          rewards_a=$(max "${min_reward}" "${rewards_a}")
        fi
        echo -e "  ${BOLD}Delegator A Final Rewards: ${rewards_a} Tokens\n"
      fi

      echo -e "+----------------------------------------------------------------+"
      echo -e "| ${INFO}Example Delegator B:${NC} ${BOLD}1000A Delegator, 32 Epochs Loyalty${NC}        |"
      echo -e "+----------------------------------------------------------------+"
      if [[ "${min_lovelace}" -gt 1000000000 ]]; then
        echo -e "  ${REKT}Delegator does not have the minimum amount of Lovelace required (${min_lovelace}).${NC}\n"
      elif [[ "${min_loyalty}" -gt 32 ]]; then
        echo -e "  ${REKT}Delegator has not been delegating long enough!${NC}\n"
      else
        rewards_a=$((reward_strategy == 1 ? flat_rate_amount : 1000 * per_ada_amount))
        echo -e "  ${BOLD}Base Rewards:${NC} ${rewards_a}"
        modifier=$( echo "$loyalty_mod ^ 32"|bc )
        echo -e "  ${BOLD}Modifier:${NC} ${modifier}"
        rewards_a=$(printf "%.0f" "$(echo "${rewards_a} * ${modifier}"|bc)")
        echo -e "  ${BOLD}Modified Rewards:${NC} ${rewards_a}"
        if [[ "${max_reward}" -gt 0 ]]; then
          echo -e "  ${BOLD}Max Rewards:${NC} ${max_reward} Tokens Max"
          rewards_a=$(min "${max_reward}" "${rewards_a}")
        fi
        if [[ "${min_reward}" -gt 0 ]]; then
          echo -e "  ${BOLD}Min Reward:${NC} ${min_reward} Tokens Min"
          rewards_a=$(max "${min_reward}" "${rewards_a}")
        fi
        echo -e "  ${BOLD}Delegator B Final Rewards: ${rewards_a} Tokens\n"
      fi

      echo -e "+----------------------------------------------------------------+"
      echo -e "| ${INFO}Example Delegator C:${NC} ${BOLD}123456A Delegator, 99 Epochs Loyalty${NC}      |"
      echo -e "+----------------------------------------------------------------+"
      if [[ "${min_lovelace}" -gt 123456000000 ]]; then
        echo -e "  ${REKT}Delegator does not have the minimum amount of Lovelace required (${min_lovelace}).${NC}\n"
      elif [[ "${min_loyalty}" -gt 99 ]]; then
        echo -e "  ${REKT}Delegator has not been delegating long enough!${NC}\n"
      else
        rewards_a=$((reward_strategy == 1 ? flat_rate_amount : 123456 * per_ada_amount))
        echo -e "  ${BOLD}Base Rewards:${NC} ${rewards_a}"
        modifier=$( echo "$loyalty_mod ^ 99"|bc )
        echo -e "  ${BOLD}Modifier:${NC} ${modifier}"
        rewards_a=$(printf "%.0f" "$(echo "${rewards_a} * ${modifier}"|bc)")
        echo -e "  ${BOLD}Modified Rewards:${NC} ${rewards_a}"
        if [[ "${max_reward}" -gt 0 ]]; then
          echo -e "  ${BOLD}Max Rewards:${NC} ${max_reward} Tokens Max"
          rewards_a=$(min "${max_reward}" "${rewards_a}")
        fi
        if [[ "${min_reward}" -gt 0 ]]; then
          echo -e "  ${BOLD}Min Reward:${NC} ${min_reward} Tokens Min"
          rewards_a=$(max "${min_reward}" "${rewards_a}")
        fi
        echo -e "  ${BOLD}Delegator B Final Rewards: ${rewards_a} Tokens\n"
      fi

      echo -e "
  How would you like to proceed?
  ${BOLD}S${NC}) Save this strategy
  ${BOLD}C${NC}) Change the strategy
  ${BOLD}Q${NC}) Quit
  Please enter your choice:"
  read -r next_step
      if [[ "${next_step^^}" == "Q" ]]; then
        break
      elif [[ "${next_step^^}" == "C" ]]; then
        continue
      else
        # We should save the strategy here...
        while [[ "${strategy_saved}" != 1 ]];
        do
          echo -e "
  Please input a name for your strategy (Letters, numbers,
  underscores and dashes only. NO SPACES):"
          read -r tmp_strategy_name
          # Remove any space characters!
          tmp_strategy_name="${tmp_strategy_name//[^A-Za-z0-9_-]/}"
          if [[ -f "./strategies/${tmp_strategy_name}.strategy" ]]; then
            echo -e "  ${REKT}THIS STRATEGY NAME HAS ALREADY BEEN USED!
  PLEASE CHOOSE A DIFFERENT NAME!${NC}\n"
            continue
          else
            cat << EOF > "./strategies/${tmp_strategy_name}.strategy"
DDZ_FLAT_RATE=$flat_rate_amount
DDZ_PER_ADA=$per_ada_amount
DDZ_MIN_REWARD=$min_reward
DDZ_MAX_REWARD=$max_reward
DDZ_MODIFIER=$loyalty_mod
DDZ_MIN_LOVELACE=$min_lovelace
DDZ_MIN_LOYALTY=$min_loyalty
EOF
            echo -e "  ${SUCCESS}Saved to ./strategies/${tmp_strategy_name}.strategy${NC}\n"
            strategy_saved=1
            # Check if there are existing strategy files!
            if [ -z "$(ls -A ./strategies/)" ]; then
               has_strategies=0
            else
               has_strategies=1
            fi
          fi
        done
      fi
    done
  elif [[ "${user_option,,}" == 2 ]]; then
    echo "Show the saved strategies here!"
  fi
done