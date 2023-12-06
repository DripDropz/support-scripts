#!/bin/bash

###################################################################
#Script Name  : ddzInstantRewards.sh
#Description  : Send DripDropz Instant Rewards to Delegators
#Args         : See --help for usage instructions
#Author       : Adam Dean & Latheesan K
#Email        : support@dripdropz.io
###################################################################

source ./.ddz.env
source ./common.sh

# Show usage help (credit to Martin Lang [ATADA] <https://github.com/gitmachtl/scripts/tree/master/cardano/mainnet>
showUsage() {
  echo -e "
##################################################################################
# $(printf '%-90s' "${BOLD} ____       _       ____                      ${NC}") #
# $(printf '%-90s' "${BOLD}|  _ \ _ __(_)_ __ |  _ \ _ __ ___  _ __ ____ ${NC}") #
# $(printf '%-90s' "${BOLD}| | | | '__| | '_ \| | | | '__/ _ \| '_ \_  / ${NC}") #
# $(printf '%-90s' "${BOLD}| |_| | |  | | |_) | |_| | | | (_) | |_) / /  ${NC}") #
# $(printf '%-90s' "${BOLD}|____/|_|  |_| .__/|____/|_|  \___/| .__/___| ${NC}") #
# $(printf '%-90s' "${BOLD}             |_|                   |_|        ${NC}") #
# $(printf '%-78s' "") #
# $(printf '%-90s' "Script Name: ${BOLD}$(basename "$0")${NC}") #
# $(printf '%-78s' "") #
# Description: Issue rewards to your pool delegators automatically utilizing the #
# DripDropz Instant Rewards API!                                                 #
# $(printf '%-78s' "") #
# Note that you must have an account on DripDropz, have created a Token Bucket   #
# and API Key on the Instant Rewards page and must have sufficient API Credits   #
# Balance to account for all of your eligible delegators.                        #
# $(printf '%-78s' "") #
# $(printf '%-95s' "Visit (mainnet): ${LINK}https://dripdropz.io/account/instant-reward/${NC}") #
# $(printf '%-95s' "Visit (preprod): ${LINK}https://dripdropz-dev.com/account/instant-reward/${NC}") #
# $(printf '%-78s' "") #
# Note that this script will attempt to send rewards in the most ideal method    #
# possible, up to 100 addresses per API request to minimize server load and      #
# maximize your API Credits.                                                     #
# $(printf '%-78s' "") #
# $(printf '%-95s' "${REKT}**IMPORTANT** THIS SCRIPT SHOULD ONLY BE RUN FROM A RELAY NODE AND NEVER${NC}") #
# $(printf '%-95s' "${REKT}DIRECTLY FROM YOUR BLOCK PRODUCER IN ORDER TO AVOID EXPOSING YOUR BLOCK${NC}") #
# $(printf '%-95s' "${REKT}PRODUCER'S PRIVATE IP ADDRESS!${NC}") #
# $(printf '%-78s' "") #
# $(printf '%-95s' "${REKT}**IMPORTANT NOTE**${NC} Most of the command line arguments specified can be") #
# $(printf '%-78s' "specified in a local environment variable included in either the file:") #
# $(printf '%-90s' "${BOLD}./.ddz.env${NC} or in the specified strategy file. You may use our helper scripts") #
# $(printf '%-102s' "${BOLD}./setup.sh${NC} and ${BOLD}./ddzStrategy.sh${NC} to configure these variables.") #
# $(printf '%-78s' "") #
# $(printf '%-95s' "${REKT}**NOTE**${NC} Token quantities must always be specified in the base amount of the") #
# $(printf '%-78s' "token as the system has no knowledge of decimal places used for formatting the") #
# $(printf '%-78s' "display of the token.") #
# $(printf '%-78s' "") #
# $(printf '%-90s' "${BOLD}Example:${NC} 1 \$DRIP must be passed as 1000000 (6 decimals)") #
# $(printf '%-78s' "") #
##################################################################################

  ${BOLD}USAGE${NC}

  ${BOLD}$(basename "$0")${NC} \\
    [${BOLD}--strategy ${HELP}<name>${NC}]
    [${BOLD}--dryrun ${HELP}<boolean>${NC}]

    # Source Parameters
    {[
      [
        ${BOLD}--poolid ${HELP}<hex|bech32>${NC}
        [${BOLD}--savesnapshot ${HELP}<path>${NC}]

      ]
      | ${BOLD}--sourcefile ${HELP}<path>${NC}
      | ${BOLD}--source ${HELP}<json_string>${NC}
    ]}

    # Network Parameters
    ${BOLD}--appid ${HELP}<appId>${NC}
    ${BOLD}--accesstoken ${HELP}<accessToken>${NC}
    [${BOLD}--network ${HELP}<network_id>${NC}]
    [${BOLD}--ticker ${HELP}<pool_ticker>${NC}]

    # Reward Strategy Parameters
    [${BOLD}--flatrate ${HELP}<amount>${NC} | ${BOLD}--perada ${HELP}<amount>${NC}]
    [${BOLD}--minlovelace ${HELP}<amount>${NC}]
    [${BOLD}--minloyalty ${HELP}<amount>${NC}]
    [${BOLD}--loyaltymod ${HELP}<amount>${NC}]
    [${BOLD}--maxreward ${HELP}<amount>${NC}]
    [${BOLD}--minreward ${HELP}<amount>${NC}]

  Example: Use the strategy specified in ${BOLD}./strategies/default.strategy${NC}
  ${BOLD}$(basename "$0") \\
    ${BOLD}--strategy default \\ ${NC}
    ${BOLD}--dryrun 0${NC}

  Example: Issue 10 tokens to each wallet delegated to the specified pool
  ${BOLD}$(basename "$0") \\
    ${BOLD}--flatrate 10 \\ ${NC}
    ${BOLD}--poolid pool1n84mel6x3e8sp0jjgmepme0zmv8gkw8chs98sqwxtruvkhhcsg8 \\ ${NC}
    ${BOLD}--dryrun 0${NC}

  Example: Issue 5 tokens per 1 ADA delegated to the specified pool
  ${BOLD}$(basename "$0") \\
    ${BOLD}--perada 5 \\ ${NC}
    ${BOLD}--poolid pool1n84mel6x3e8sp0jjgmepme0zmv8gkw8chs98sqwxtruvkhhcsg8 \\ ${NC}
    ${BOLD}--dryrun 0${NC}

  Example:
  ${BOLD}$(basename "$0") \\
    ${BOLD}--perada 5 \\              ${NC}# Issue 5 tokens per 1 ADA delegated
    ${BOLD}--minlovelace 100000000 \\ ${NC}# 100A minimum delegation required
    ${BOLD}--loyaltymod 1.001 \\      ${NC}# Increase by 0.1% per epoch delegated
    ${BOLD}--maxreward 5000 \\        ${NC}# Users may receive at most 5000 tokens
    ${BOLD}--poolid pool1n84mel6x3e8sp0jjgmepme0zmv8gkw8chs98sqwxtruvkhhcsg8 \\ ${NC}
    ${BOLD}--dryrun 0${NC}

  ${HELP}PARAMETERS${NC}

    ${BOLD}--strategy ${HELP}<name>${NC}:

      Use the variables defined in the strategy file found at ${BOLD}./strategies/<name>.strategy${NC}
      You can create and manage your own token reward strategies by running ${BOLD}./ddzStrategy.sh${NC}

    ${BOLD}--dryrun ${HELP}<1|0>${NC}:

      Whether we should perform a dry run and write the calculated rewards out to
      a file rather than sending them to DripDropz via the API connection.

      [${BOLD}Default: 1 (true)${NC} | Write results to terminal and file, do not send
       to DripDropz via API connection]

  ${HELP}SOURCE PARAMETERS${NC}

    ${BOLD}One of...${NC}

      ${REKT}**Note**${NC} When using the ${BOLD}--poolid${NC} parameter a request will be made to DripDropz
      servers to request snapshot information. This will consume ${BOLD}1${NC} API Credit
      from your account each time it is called. The results will be cached at the
      location specified by the ${BOLD}--savesnapshot${NC} argument in the event that you
      would like to review the source or run this script again later (dry run vs.
      live run).

    ${BOLD}--poolid ${HELP}<pool_hex_id>${NC}:

      The hex ID of the stake pool you'd like to query the snapshot for. This
      will perform an API call to DripDropz servers to fetch the snapshot. This
      will consume 1 API credit from your account.

      May be specified in ${BOLD}.ddz.env${NC} or ${HELP}<strategy>${NC} file as ${HELP}DDZ_POOL_ID${NC}

      ${BOLD}--savesnapshot ${HELP}<path>${NC}:

        The file path where you would like to save the snapshot data. Only used in
        conjunction with the ${BOLD}--poolid${NC} parameter.

        [${BOLD}Default: ./snapshots/<pool_id>/<epoch_no>.snapshot.json${NC}]

    ${BOLD}--sourcefile ${HELP}<file_path>${NC}:

      Load snapshot state from a locally saved JSON file stored at the specified path.

    ${BOLD}--source ${HELP}<json_string>${NC}:

      You can pass a valid JSON string using this argument.

  ${HELP}REWARD STRATEGY PARAMETERS${NC}

    ${REKT}**NOTE**${NC} You must choose either ${BOLD}flatrate${NC} or ${BOLD}perada${NC} when specifying reward
    strategy parameters via command line argument. These two are mutually
    exclusive. All ${HELP}REWARD STRATEGY PARAMETERS${NC} can be used to override the
    values imported from a saved strategy file.

    ${BOLD}--flatrate ${HELP}<amount>${NC}:

      A fixed amount of tokens that will be sent to all delegators regardless of
      the delegated Lovelace amount. This should be entered as an integer value
      in the token's base amount.

      May be specified in ${BOLD}.ddz.env${NC} or ${HELP}<strategy>${NC} file as ${HELP}DDZ_FLAT_RATE${NC}

      Example: 1 000 000 == 1 \$DRIP

    ${BOLD}--perada ${HELP}<amount>${NC}:

      An amount of tokens that the user will receive per ada delegated. This may
      be specified in a floating point (decimal) number to create some interesting
      scenarios.

      May be specified in ${BOLD}.ddz.env${NC} or ${HELP}<strategy>${NC} file as ${HELP}DDZ_PER_ADA${NC}

      Example:
        1 \$DRIP = 1 000 000 base units
        --perada 1 000 == 1 \$DRIP per 1 000 \$ADA delegated. (1 000 * 1 000 = 1 000 000)
        --perada 0.1 == 1 \$DRIP per 10 000 000 \$ADA delegated. (0.1 * 10 000 000 = 1 000 000)

    ${BOLD}--minlovelace ${HELP}<amount>${NC}:

      The minimum amount of Lovelace that must be delegated by a wallet in order
      to qualify for rewards. Delegators must stake at least 1 MORE than this
      amount of Lovelace in order to qualify.

      May be specified in ${BOLD}.ddz.env${NC} or ${HELP}<strategy>${NC} file as ${HELP}DDZ_MIN_LOVELACE${NC}

      [${BOLD}Default: 0, user must delegate 1 Lovelace or more${NC}]

    ${BOLD}--minloyalty ${HELP}<amount>${NC}:

      The minimum number of epochs a wallet must be delegated to the stakepool
      in order to qualify for rewards.

      May be specified in ${BOLD}.ddz.env${NC} or ${HELP}<strategy>${NC} file as ${HELP}DDZ_MIN_LOYALTY${NC}

      [${BOLD}Default: 0, first-epoch delegators are also eligible for rewards${NC}]

    ${BOLD}--loyaltymod ${HELP}<amount>${NC}:

      Specify a multiplier based on the number of epochs the wallet has been
      delegated to this stakepool. This must be a floating point number greater
      than 1 such as: 1.1 === 10% bonus per epoch. Note that fractional amounts
      are always rounded down to the lowest whole integer value.

      May be specified in ${BOLD}.ddz.env${NC} or ${HELP}<strategy>${NC} file as ${HELP}DDZ_MODIFIER${NC}

      Calculation: (${HELP}<loyalty_modifier>${NC} ^ ${HELP}<epoch_loyalty>${NC}) * ${HELP}<base_rewards>${NC} = ${HELP}<rewards_with_bonus>${NC}

      Example:
        Modifier: 1.1
        Epoch Loyalty: 72
        Base Rewards: 10
        Rewards Modifier: (1.1 ^ 72) =  955.59
        Rewards with Bonus: (10 * 955.59) = 9 555

      Example:
        Modifier: 1.01
        Epoch Loyalty: 72
        Base Rewards: 10
        Rewards Modifier: (1.01 ^ 72) = 2.04
        Rewards with Bonus: (10 * 2.04) = 20

      [${BOLD}Default: 1.0, no epoch loyalty bonus${NC}]

    ${BOLD}--maxreward ${HELP}<amount>${NC}:

      Specify a maximum amount of rewards that any address may receive. If the
      wallet would receive more than this amount due to loyalty modifiers or per
      \$ADA rewards, the total amount issued will be capped at this number. Must
      be specified as an integer.

      May be specified in ${BOLD}.ddz.env${NC} or ${HELP}<strategy>${NC} file as ${HELP}DDZ_MAX_REWARD${NC}

      [${BOLD}Default: 0, no maximum${NC}]

    ${BOLD}--minreward ${HELP}<amount>${NC}:

      Specify a minimum amount of rewards that any eligible address will receive.
      If the wallet in question would receive less than this amount the total
      amount issued will be increased to this number. Must be specified as an
      integer.

      May be specified in ${BOLD}.ddz.env${NC} or ${HELP}<strategy>${NC} file as ${HELP}DDZ_MIN_REWARD${NC}

      [${BOLD}Default: 0, no minimum${NC}]

  ${HELP}NETWORK PARAMETERS${NC}

    ${BOLD}--appid ${HELP}<appId>${NC}:

      The App ID for your API Key that you wish to use

      May be specified in ${BOLD}.ddz.env${NC} or ${HELP}<strategy>${NC} file as ${HELP}DDZ_APP_ID${NC}

    ${BOLD}--accesstoken ${HELP}<accessToken>${NC}:

      The secret Access Token for the API Key that you wish to use

      May be specified in ${BOLD}.ddz.env${NC} or ${HELP}<strategy>${NC} file as ${HELP}DDZ_ACCESS_TOKEN${NC}

    ${BOLD}--network ${HELP}<network_id>${NC}:

      Which Cardano network to use

      1 = Mainnet
      0 = Preprod

      May be specified in ${BOLD}.ddz.env${NC} or ${HELP}<strategy>${NC} file as ${HELP}DDZ_NETWORK_ID${NC}

      [${BOLD}Default: 1, Mainnet${NC}]

    ${BOLD}--ticker ${HELP}<pool_ticker>${NC}:

      The pool ticker issuing the rewards Will be shown to users in the rewards
      message on DripDropz.

      May be specified in ${BOLD}.ddz.env${NC} or ${HELP}<strategy>${NC} file as ${HELP}DDZ_TICKER${NC}
"
}

while [ $# -gt 0 ]; do

  if [[ $1 == *"--"* ]]; then
    v="${1/--/}"
    if [[ $v == "help" ]]; then
      showUsage
      exit
    fi
    declare "$v"="$2"
  fi

  shift
done

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
 |$(echo -e "${INFO}                     ISSUE INSTANT REWARDS                     ${NC}")|
 +---------------------------------------------------------------+

EOF

if [ -n "${strategy}" ]; then
  if [ -f "./strategies/${strategy}.strategy" ]; then
    # shellcheck source=strategies/default.strategy
    source "./strategies/${strategy}.strategy"
  else
    echo -e "${REKT}THE PROVIDED STRATEGY FILE DOES NOT EXIST!${NC}\n"
    exit 1
  fi
fi

# Set defaults if not set
DDZ_MIN_LOVELACE="${DDZ_MIN_LOVELACE:-0}"
DDZ_MIN_LOYALTY="${DDZ_MIN_LOYALTY:-0}"
DDZ_MODIFIER="${DDZ_MODIFIER:-0}"
DDZ_MIN_REWARD="${DDZ_MIN_REWARD:-0}"
DDZ_MAX_REWARD="${DDZ_MAX_REWARD:-0}"
DDZ_NETWORK_ID="${DDZ_NETWORK_ID:-1}"

BATCH_LIMIT="${DDZ_BATCH_LIMIT:-100}"

appid="${appid:-${DDZ_APP_ID}}"
accesstoken="${accesstoken:-${DDZ_ACCESS_TOKEN}}"
networkid="${networkid:-${DDZ_NETWORK_ID}}"
ticker="${ticker:-${DDZ_TICKER}}"
poolid="${poolid:-${DDZ_POOL_ID}}"

perada="${perada:-${DDZ_PER_ADA}}"
flatrate="${flatrate:-${DDZ_FLAT_RATE}}"
minlovelace="${minlovelace:-${DDZ_MIN_LOVELACE}}"
minloyalty="${minloyalty:-${DDZ_MIN_LOYALTY}}"
loyaltymod="${loyaltymod:-${DDZ_MODIFIER}}"
minreward="${minreward:-${DDZ_MIN_REWARD}}"
maxreward="${maxreward:-${DDZ_MAX_REWARD}}"


if [[ "$networkid" == 1 ]]; then
  networkname="Mainnet"
  DDZ_API_BASE_URI="https://dripdropz.io/api/integration/v1/instant-reward"
else
  networkname="Preprod"
  DDZ_API_BASE_URI="https://dripdropz-dev.com/api/integration/v1/instant-reward"
fi

dryrun="${dryrun:-1}"
epoch=$(getEpoch "$networkid")

if [ -z ${appid+x} ]; then
  echo ""
  echo -e "${REKT}ERROR: App ID is not set!${NC}"
  echo ""
  showUsage
  exit
fi

if [ -z ${accesstoken+x} ]; then
  echo ""
  echo -e "${REKT}ERROR: Access Token is not set!${NC}"
  echo ""
  showUsage
  exit
fi

if [ -n "${sourcefile}" ]; then
  file_ext=${sourcefile##*.}
  if [[ ! -f "${sourcefile}" && "${file_ext^^}" == "JSON" ]]; then # it's not a JSON file!
    echo -e "${REKT}The provided ${HELP}sourcefile${REKT} is not a valid JSON file!"
    exit 1
  fi
  source=$(jq -c . "$sourcefile")
fi

if [ -n "${poolid}" ]; then
  OUTPUT_FILE_PATH="${savesnapshot:-./snapshots/${poolid}/${epoch}.snapshot.json}"

  if [ -f "${OUTPUT_FILE_PATH}" ]; then
    echo ""
    echo "An existing snapshot file was found at
${OUTPUT_FILE_PATH}

Using existing snapshot..."
    #    echo "jq -c . $OUTPUT_FILE_PATH"
    source=$(jq -c . "${OUTPUT_FILE_PATH}")
  else
    base_uri=$(echo "${DDZ_API_BASE_URI}" | tr -d '\r')
    url="${base_uri}/pool-delegations/${poolid}/${epoch}"
    curl_response=$(curl -s --http1.1 --header "X-App-Id: ${appid}" --header "X-Access-Token: ${accesstoken}" --location "${url}")

    error=$(jq -r '.error' <<<"$curl_response")
    if [ "${error}" != "null" ]; then
      echo -e "${REKT}${error}${NC}"
      echo ""
      exit 1
    fi

    epochno=$(jq -r '.data.epoch' <<<"$curl_response")

    if [ "${epoch}" != "${epochno}" ]; then
      echo -e "${REKT}Calculated epoch number (${epoch}) does not match the snapshot epoch (${epochno})${NC}"
      echo ""
      exit 1
    fi

    source=$(jq -c '.data.delegateSummaries' <<<"$curl_response")
    count=$(jq -r '. | length' <<<"$source")

    OUTPUT_DIR="$(dirname "${OUTPUT_FILE_PATH}")"
    mkdir -p "$OUTPUT_DIR"

    echo ""
    echo "Fetched ${count} delegators for epoch #${epochno}!"
    echo "Saving output to $OUTPUT_FILE_PATH"
    echo "$source" >"$OUTPUT_FILE_PATH"
  fi

fi

if [[ -z "${source}" ]]; then
  echo "Source is not defined! Using default sample set!"
  source=$(jq -c . "./stakers.sample.json")
fi

valid_json=$(jq -e . >/dev/null 2>&1 <<<"$source")

if [ "$valid_json" ]; then
  echo -e "${REKT}The provided source is not a valid JSON!${NC}"
  exit 1
fi

echo ""
echo -e "${BOLD}App ID:${NC} ${appid}"
echo -e "${BOLD}Access Token:${NC} ${accesstoken}"
echo -e "${BOLD}Network:${NC} ${networkname}"
echo -e "${BOLD}Epoch:${NC} ${epoch}"
echo -e "${BOLD}Minimum Lovelace is:${NC} ${minlovelace}"
echo -e "${BOLD}Minimum Loyalty is:${NC} ${minloyalty}"
echo -e "${BOLD}Per Epoch Loyalty Modifier:${NC} ${loyaltymod}"
echo -e "${BOLD}Max Rewards are:${NC} ${maxreward}"
echo -e "${BOLD}Min Rewards are:${NC} ${minreward}"

message="Instant pool rewards"

if [ -n "${ticker}" ]; then
  message="${message} from ${ticker}"
fi

if [ -n "${epoch}" ]; then

  message="${message} (Epoch #${epoch})"

fi

if [ ! -z "${perada}" ]; then

  echo -e "${BOLD}Tokens per ADA is:${NC} ${perada} tokens"

  amt_arg='(.delegatedLovelace|tonumber / 1000000 * ($perADA|tonumber))'
  flatrate=0

elif [ ! -z "${flatrate}" ]; then

  echo -e "${BOLD}Flat rate of:${NC} ${flatrate} tokens per wallet!"

  amt_arg='($flatRate|tonumber)'
  perada=0

else

  echo -e "${BOLD}Default Rate:${NC} 1 token per wallet!"

  amt_arg='1'
  flatrate=0
  perada=0

fi

echo ""

jq_arg='
  def minVal(min): if (min|tonumber) == 0 then . else if (.|tonumber) < (min|tonumber) then min else . end end;
  def maxVal(max): if (max|tonumber) == 0 then . else if (.|tonumber) > (max|tonumber) then max else . end end;
  def doBonus(n): . * n;
  sort_by((.delegatedLovelace|tonumber),.poolLoyaltyEpochs|tonumber) |
  reverse |
  map(
   select(.delegatedLovelace|tonumber - 1 >= ($minLovelace|tonumber)) |
   select(.poolLoyaltyEpochs|tonumber >= ($minLoyalty|tonumber)) |
   .poolLoyaltyEpochs as $loyaltyEpochs |
   pow($loyaltyMod|tonumber;$loyaltyEpochs|tonumber) as $loyaltyBonus |
   {
     address: .stakeAddress,
     amount: '"${amt_arg}"'|doBonus($loyaltyBonus)|minVal($minReward|tonumber)|maxVal($maxReward|tonumber)|floor|tonumber,
     reason: $reason
   }
  ) |
  map(select(.amount|tonumber > 0)) |
  _nwise(.;($batchLimit|tonumber)) |
  {rewards: .}'

groups=$(jq -c \
  --arg minLovelace "$minlovelace" \
  --arg minLoyalty "$minloyalty" \
  --arg reason "$message" \
  --arg perADA $perada \
  --arg flatRate $flatrate \
  --arg loyaltyMod "$loyaltymod" \
  --arg minReward "$minreward" \
  --arg maxReward "$maxreward" \
  --arg batchLimit "$BATCH_LIMIT" \
  "${jq_arg}" <<<"$source")

total_requests_needed=$(jq -s '. | length' <<<"$groups")

echo ""
echo -e "Preparing to send ${SUCCESS}${total_requests_needed}${NC} API requests..."
echo ""

echo "$groups" >./test.output.json

total_rewards=$(jq -s -r '[.[].rewards[].amount]|add' <<<"$groups")
total_addresses=$(jq -s -r '[.[].rewards[]]|length' <<<"$groups")

if [[ "${dryrun}" == 1 ]]; then
  poolid="${poolid:-delegates}"
  RESULTS_OUTPUT_PATH="./rewards/${poolid}/${epoch}.dryrun.json"
  OUTPUT_DIR="$(dirname "${RESULTS_OUTPUT_PATH}")"
  mkdir -p "$OUTPUT_DIR"
  echo -e "${SUCCESS}PERFORMING REWARDS 'DRY RUN' TO ANALYZE BEFORE SUBMITTING VIA API!${NC}"
  echo -e "Results can be found at ${RESULTS_OUTPUT_PATH}"
  jq -s '.' <<<"$groups" >"$RESULTS_OUTPUT_PATH"

else
  jq -c -s '.[]' <<<"$groups" | while read -r i; do
    batch_rewards_count=$(jq -r '.rewards|length' <<< "$i")
    batch_rewards_total=$(jq -r '[.rewards[].amount]|add' <<< "$i")
    echo -e "${BOLD}Sending API rewards for ${batch_rewards_count} addresses with a total of ${batch_rewards_total} tokens!${NC}"
    base_uri=$(echo "${DDZ_API_BASE_URI}" | tr -d '\r')
    url="${base_uri}/create"
    curl_response=$(curl -s --http1.1 \
      --header "X-App-Id: ${appid}" \
      --header "X-Access-Token: ${accesstoken}" \
      --header 'Content-Type: application/json' \
      --data "$i" \
      --location "${url}")
    message=$(jq -r '.data' <<< "$curl_response")
    if [[ "$message" == "Success" ]]; then
      echo -e "${SUCCESS}${message}${NC}"
    else
      echo -e "${REKT}${message}${NC}"
    fi
  done
fi

echo ""
echo -e "Total Tokens Awarded: ${BOLD}${total_rewards}${NC}"
echo -e "Total Addresses Rewarded: ${BOLD}${total_addresses}${NC}"
