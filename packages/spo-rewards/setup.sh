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
 |$(echo -e "${INFO}                      INSTANT REWARDS API                      ${NC}")|
 +---------------------------------------------------------------+

EOF

# Create a strategies directory to store reward strategy configuration files
mkdir -p ./strategies

echo -e "${BOLD}  Welcome to the DripDropz SPO Instant Rewards setup script!${NC}"
echo -e "
  These settings are only to help minimize your need for command
  line arguments when executing the script.\n
  You may override the settings specified here by changing the
  contents of ${BOLD}./.ddz.env${NC} file or specifying command
  line arguments to the script at run time.\n"

echo -e "  Have you already setup your token bucket and API key at
  ${LINK}https://dripdropz.io/account/instant-reward/api-keys${NC}? [Y/${BOLD}N${NC}]"
read -r api_is_setup
api_is_setup=${api_is_setup:-N}
if [[ "${api_is_setup^^}" != "Y" ]]; then
  echo -e "
  ${REKT}It is highly recommended that you configure your token bucket
  and API key before configuring these scripts!${NC}\n"
else
  echo -e "  Please enter your App ID found on your DripDropz API Keys
  dashboard: "
  read -r ddz_app_id
  echo -e "  Please enter your Access Token found on your DripDropz API
  Keys dashboard:"
  read -r ddz_access_token
fi

echo -e "  Would you like to configure a default stakepool? [Y/${BOLD}N${NC}]:"
read -r setup_default_pool
setup_default_pool=${setup_default_pool:-N}
if [[ "${setup_default_pool^^}" == "Y" ]]; then
  while [[ -z "${default_pool_id}" ]]; do
    echo -e "  Please enter the Pool ID you would like to configure as your
  default: (bech32 or hex ID or 'q' to skip)"
    read -r test_pool_id
    if [[ "${test_pool_id,,}" == "q" ]]; then
      break
    fi
    # Pool bech32 Identifier ^(pool1)[a-zA-HJ-NP-Z0-9]{51}$
    # pool1n84mel6x3e8sp0jjgmepme0zmv8gkw8chs98sqwxtruvkhhcsg8
    if [[ "${test_pool_id,,}" =~ ^(pool1)[a-zA-HJ-NP-Z0-9]{51}$ ]]; then
      default_pool_id="${test_pool_id}"
    # Pool Hex Identifier ^[a-f0-9]{56}$
    # 99ebbcff468e4f00be5246f21de5e2db0e8b38f8bc0a7801c658f8cb
    elif [[ "${test_pool_id,,}" =~ ^[a-f0-9]{56}$ ]]; then
      default_pool_id="${test_pool_id}"
    else
      echo -e "\n  ${REKT}INVALID POOL ID!${NC}\n"
      continue
    fi
  done
  echo -e "  Please provide a Pool Ticker for this stakepool:"
  read -r ticker
fi

while [[ "${default_network}" != 1 && "${default_network}" != 0 ]]; do
  echo -e "  What is the default network you will be issuing rewards on?
  [1 = Mainnet | ${BOLD}0 = Preproduction${NC}]"
  read -r default_network
  default_network="${default_network:-0}"
  if [[ "${default_network}" != 1 && "${default_network}" != 0 ]]; then
    echo -e "\n${REKT}  Invalid network selected${NC}\n"
  fi
done

echo -e "\n  Preparing to write your configuration to file...\n"
if [[ -n "${ddz_app_id}" ]]; then
  echo -e "  ${BOLD}App ID:${NC} ${ddz_app_id}"
fi
if [[ -n "${ddz_access_token}" ]]; then
  echo -e "  ${BOLD}Access Token:${NC} ${ddz_access_token}"
fi
if [[ -n "${default_pool_id}" ]]; then
  echo -e "  ${BOLD}Pool ID:${NC} ${default_pool_id}"
fi
if [[ -n "$default_network" ]]; then
  if [[ "${default_network}" == 1 ]]; then
    echo -e "  ${BOLD}Network:${NC} Mainnet"
  elif [[ "${default_network}" == 0 ]]; then
    echo -e "  ${BOLD}Network:${NC} Preproduction"
  fi
fi
echo -e "\n  Do these options look good? [Y/${BOLD}N${NC}]"
read -r approve_options
approve_options="${approve_options:-N}"
if [[ "${approve_options^^}" == "Y" ]]; then
  echo -e "\n  Writing configuration options to file..."
  echo "DDZ_BATCH_LIMIT=100" >./.ddz.env
  echo "DDZ_NETWORK_ID=${default_network}" >>./.ddz.env
  if [[ -n "${ddz_app_id}" ]]; then
    echo "DDZ_APP_ID=${ddz_app_id}" >>./.ddz.env
  fi
  if [[ -n "${ddz_access_token}" ]]; then
    echo "DDZ_ACCESS_TOKEN=${ddz_access_token}" >>./.ddz.env
  fi
  if [[ -n "${default_pool_id}" ]]; then
    echo "DDZ_POOL_ID=${default_pool_id}" >>./.ddz.env
    echo "DDZ_TICKER=${ticker}" >>./.ddz.env
  fi
  echo -e "\n  ${SUCCESS}Default configuration written to${NC} ${BOLD}./.ddz.env${NC}${SUCCESS}!${NC}\n"
  echo -e "  You can update these options at any time by manually modifying
  ${BOLD}./.ddz.env${NC} or running this script again. Options can also be
  overridden by command line arguments during script execution.\n"
else
  echo "\n  ${REKT}You've chosen to not write the options to file.\nPlease try again later!${NC}\n"
fi
