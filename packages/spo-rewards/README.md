# DripDropz SPO Rewards

> Author: Adam Dean<br />
> Version: RC 1.0<br />
> Released On: 2023-12-08

This directory contains scripts and instructions for setting up and issuing rewards to stake pool delegators. Intended
to be run by SPOs to issue rewards to their delegators. However, any individual with a valid API key, token bucket, and
API credits from [DripDropz Instant Rewards API](https://dripdropz.io/account/instant-reward/) may issue rewards
to stake pool delegators of their choice using these scripts.

## Bring Your Own Snapshot

By default, these scripts were designed to utilize the DripDropz API services to fetch the latest epoch snapshot of 
stakepool delegates and issue rewards to them automatically based on the provided command line arguments. However, you
can bring your own rewards and pass in a file as an argument to [rewardStakers.sh](./rewardStakers.sh) if you'd
like. Simply make sure that your JSON file matches the format found in [stakers.sample.json](./stakers.sample.json) to
ensure smooth compatibility with these scripts.

## Scripts

### [common.sh](./common.sh)

This script simply contains some common variables and pieces of code such as terminal color codes and helper functions.

### [setup.sh](./setup.sh)

This is a simple wizard script that will help you to configure a local environment variable file containing information
about your API keys, network, and default stakepool. Simply follow the in-terminal prompts to quickly and easily get
set up for issuing rewards.

```shell
cd spo-rewards
mkdir -p ./strategies ./snapshots ./rewards
chmod +x setup.sh rewardStakers.sh manageStrategy.sh
./setup.sh
```

**Example Output**
```shell
 +---------------------------------------------------------------+
 |                                                               |
 |          ____       _       ____                              |
 |         |  _ \ _ __(_)_ __ |  _ \ _ __ ___  _ __ ____         |
 |         | | | | '__| | '_ \| | | | '__/ _ \| '_ \_  /         |
 |         | |_| | |  | | |_) | |_| | | | (_) | |_) / /          |
 |         |____/|_|  |_| .__/|____/|_|  \___/| .__/___|         |
 |                      |_|                   |_|                |
 |                                                               |
 |                      INSTANT REWARDS API                      |
 +---------------------------------------------------------------+

  Welcome to the DripDropz SPO Instant Rewards setup script!

  These settings are only to help minimize your need for command
  line arguments when executing the script.

  You may override the settings specified here by changing the
  contents of ./.ddz.env file or specifying command
  line arguments to the script at run time.

  Have you already setup your token bucket and API key at
  https://dripdropz.io/account/instant-reward/api-keys? [Y/N]
```
### [manageStrategy.sh](./manageStrategy.sh)

This is a simple wizard script to help you in creating .strategy files to be used when executing 
[rewardStakers.sh](#rewardstakerssh). Follow the in-terminal menus and prompts to test and configure delegator reward
strategies quickly and easily.

```shell
./manageStrategy.sh
```

**Example Output**
```shell
 +---------------------------------------------------------------+
 |                                                               |
 |          ____       _       ____                              |
 |         |  _ \ _ __(_)_ __ |  _ \ _ __ ___  _ __ ____         |
 |         | | | | '__| | '_ \| | | | '__/ _ \| '_ \_  /         |
 |         | |_| | |  | | |_) | |_| | | | (_) | |_) / /          |
 |         |____/|_|  |_| .__/|____/|_|  \___/| .__/___|         |
 |                      |_|                   |_|                |
 |                                                               |
 |                   REWARDS STRATEGY CREATOR                    |
 +---------------------------------------------------------------+


  This script is designed to help you create and test your
  rewards strategies. To get started, please choose one of
  the options below!

  Existing rewards strategies found!

  Please select an option:
  1) Create a new strategy
  2) Review existing strategy
  q) Quit
```

### [rewardStakers.sh](./rewardStakers.sh)

> **IMPORTANT**
> 
> This script, when properly configured, will send API requests to the DripDropz servers! For that reason this script
> should never be run from a block producing node to prevent potential exposure of your block producer IP address.

This script contains the logic for retrieving snapshots from the 
[DripDropz Instant Rewards API](https://dripdropz.io/account/instant-reward/) and issuing rewards to delegators via
the [DripDropz Instant Rewards API](https://dripdropz.io/account/instant-reward/). Most of the command line configuration
options exist for the purpose of testing or overriding as the majority of variables can be configured and set via the
use of the [setup.sh](#setupsh) and [manageStrategy.sh](#managestrategysh) scripts. See [commnand_line_arguments](#command-line-arguments)
for a detailed explanation of all arguments and their usage.

**Usage Examples**
```shell
./rewardStakers.sh --strategy default --dryrun 0
```

**Example Output**
```shell
 +---------------------------------------------------------------+
 |                                                               |
 |          ____       _       ____                              |
 |         |  _ \ _ __(_)_ __ |  _ \ _ __ ___  _ __ ____         |
 |         | | | | '__| | '_ \| | | | '__/ _ \| '_ \_  /         |
 |         | |_| | |  | | |_) | |_| | | | (_) | |_) / /          |
 |         |____/|_|  |_| .__/|____/|_|  \___/| .__/___|         |
 |                      |_|                   |_|                |
 |                                                               |
 |                     ISSUE INSTANT REWARDS                     |
 +---------------------------------------------------------------+


An existing snapshot file was found at
./snapshots/pool1n84mel6x3e8sp0jjgmepme0zmv8gkw8chs98sqwxtruvkhhcsg8/110.snapshot.json

Using existing snapshot...

App ID: 6224d5d4-6f7a-4562-96bc-f1e46ebda154
Access Token: l5LXBQxWRWB6wlwbxlQw8tp5jjLYcac6IyvMZEQvesci3T9eQSRe8KTQAozdEmYc
Network: Preprod
Epoch: 110
Minimum Lovelace is: 1000000
Minimum Loyalty is: 0
Per Epoch Loyalty Modifier: 1.0
Max Rewards are: 0
Min Rewards are: 0
Flat rate of: 10000000 tokens per wallet!


Preparing to send 2 API requests...

Sending API rewards for 100 addresses with a total of 1000000000 tokens!
Success
Sending API rewards for 94 addresses with a total of 940000000 tokens!
Success

Total Tokens Awarded: 1940000000
Total Addresses Rewarded: 194
```
#### Command Line Arguments

Most of the available command line arguments for `rewardStakers.sh` may be specified in either a global `./.ddz.env` file
or within a `.strategy` file to minimize the complexity of command line execution of this script. However, command line
arguments always override the values specified within a `.strategy` file which override the values specified in a global
`./.ddz.env` file.

**Variable Import Order**
> `cli` > `.strategy` > `.ddz.env`

* [--help](#--help)
* [--strategy \<name>](#--strategy-name)
* [--dryrun \<boolean>](#--dryrun-booleaninteger)
* [--poolid \<identifier>](#--poolid-identifier)
* [--savesnapshot \<dir_path>](#--savesnapshot-path)
* [--sourcefile \<file_path>](#--sourcefile-filepath)
* [--source \<json_string>](#--source-jsonstring)
* [--appid \<string>](#--appid-string)
* [--accesstoken \<string>](#--accesstoken-string)
* [--network \<integer>](#--network-integer)
* [--ticker \<string>](#--ticker-string)
* [--flatrate \<integer>](#--flatrate-integer)
* [--perada \<float>](#--perada-float)
* [--minlovelace \<integer>](#--minlovelace-integer)
* [--minloyalty \<integer>](#--minloyalty-integer)
* [--loyaltymod \<float>](#--loyaltymod-float)
* [--maxreward \<integer>](#--maxreward-integer)
* [--minreward \<integer>](#--minreward-integer)

##### --help

> Required: false
> 
> Purpose: Display script context and usage help in the terminal window

Use the `--help` command line argument to display script context and usage text within the terminal window

**Example**
```shell
##################################################################################
#  ____       _       ____                                                       #
# |  _ \ _ __(_)_ __ |  _ \ _ __ ___  _ __ ____                                  #
# | | | | '__| | '_ \| | | | '__/ _ \| '_ \_  /                                  #
# | |_| | |  | | |_) | |_| | | | (_) | |_) / /                                   #
# |____/|_|  |_| .__/|____/|_|  \___/| .__/___|                                  #
#              |_|                   |_|                                         #
#                                                                                #
# Script Name: rewardStakers.sh                                                  #
#                                                                                #
# Description: Issue rewards to your pool delegators automatically utilizing the #
# DripDropz Instant Rewards API!                                                 #
#                                                                                #
# Note that you must have an account on DripDropz, have created a Token Bucket   #
# and API Key on the Instant Rewards page and must have sufficient API Credits   #
# Balance to account for all of your eligible delegators.                        #
#                                                                                #
# Visit (mainnet): https://dripdropz.io/account/instant-reward/                  #
# Visit (preprod): https://dripdropz-dev.com/account/instant-reward/             #
#                                                                                #
# Note that this script will attempt to send rewards in the most ideal method    #
# possible, up to 100 addresses per API request to minimize server load and      #
# maximize your API Credits.                                                     #
#                                                                                #
# **IMPORTANT** THIS SCRIPT SHOULD ONLY BE RUN FROM A RELAY NODE AND NEVER       #
# DIRECTLY FROM YOUR BLOCK PRODUCER IN ORDER TO AVOID EXPOSING YOUR BLOCK        #
# PRODUCER'S PRIVATE IP ADDRESS!                                                 #
#                                                                                #
# **IMPORTANT NOTE** Most of the command line arguments specified can be         #
# specified in a local environment variable included in either the file:         #
# ./.ddz.env or in the specified strategy file. You may use our helper scripts   #
# ./setup.sh and ./ddzStrategy.sh to configure these variables.                  #
#                                                                                #
# **NOTE** Token quantities must always be specified in the base amount of the   #
# token as the system has no knowledge of decimal places used for formatting the #
# display of the token.                                                          #
#                                                                                #
# Example: 1 $DRIP must be passed as 1000000 (6 decimals)                        #
#                                                                                #
##################################################################################

  USAGE

  rewardStakers.sh \
    [--strategy <name>]
    [--dryrun <boolean>]

    # Source Parameters
    {[
      [
        --poolid <hex|bech32>
        [--savesnapshot <path>]

      ]
      | --sourcefile <path>
      | --source <json_string>
    ]}

    # Network Parameters
    --appid <appId>
    --accesstoken <accessToken>
    [--network <network_id>]
    [--ticker <pool_ticker>]

    # Reward Strategy Parameters
    [--flatrate <amount> | --perada <amount>]
    [--minlovelace <amount>]
    [--minloyalty <amount>]
    [--loyaltymod <amount>]
    [--maxreward <amount>]
    [--minreward <amount>]
```

##### --strategy \<name>

> Required: false
> 
> Purpose: Pass the name of the .strategy file to be used to provide rewards context to the script

After creating one or more strategies using the [manageStrategy.sh](#managestrategysh) script, you can quickly and easily
reward delegators in a repeatable fashion by calling [rewardStakers.sh](#rewardstakerssh) with the `--strategy` argument.
The name should be passed in as the string value of the name of the file you wish to use without the `.strategy` suffix.

**Example**
```shell
> ls ./strategies
default.strategy  mystrat.strategy
> ./rewardStakers.sh --strategy mystrat
```

##### --dryrun \<boolean_integer>

> Required: false
> 
> Purpose: Indicate whether a rewards "dry run" should be executed or whether live rewards should be issued.
> 
> Possible Values: [0, 1]
> 
> Default: `1` (true)

By default, the script will execute in a "dry run" mode that will analyze the delegator snapshot provided and calculate
all eligible rewards and save the results to a file found at: `./rewards/<pool_id>/<epoch_no>.dryrun.json`. You may
analyze this file to determine if your strategy is being applied as intended prior to submitting live rewards via the
API.

**Example (Do Dry Run)**
```shell
> ./rewardStakers.sh --strategy mystrat --dryrun 1
```

**Example (Do Live Rewards)**
```shell
> ./rewardStakers.sh --strategy mystrat --dryrun 0
```

##### --poolid \<identifier>

> Required: false
> 
> Purpose: Indicate the pool ID that will be used to fetch a delegator snapshot
> 
> Possible Values: The Pool ID in either hex or bech32 format
> 
> Environment Variable: DDZ_POOL_ID
> 
> Default: `null`

Normally the Pool ID will be specified in either the global `./.ddz.env` file or in a `.strategy` file. This command
line argument exists for the purposes of testing and "overloading" the value specified in an environment variable.

The Pool ID may be declared globally in the `./.ddz.env` file using the variable name `DDZ_POOL_ID`. It may also be
overridden in a specific `.strategy` file using the same `DDZ_POOL_ID` variable name to allow you to have strategies
for individual stake pools.

**Example (Hex Pool ID):**
```shell
> ./rewardStakers.sh --strategy mystrat --poolid 99ebbcff468e4f00be5246f21de5e2db0e8b38f8bc0a7801c658f8cb
```

**Example (bech32 Pool ID):**
```shell
> ./rewardStakers.sh --strategy mystrat --poolid pool1n84mel6x3e8sp0jjgmepme0zmv8gkw8chs98sqwxtruvkhhcsg8
```

##### --savesnapshot \<path>

> Required: false
> 
> Purpose: Indicate the file path that you would like to use to store the JSON output of the DripDropz API Epoch Snapshot
> for the specified `--poolid`
> 
> Default: `./snapshots/<pool_id>/<epoch_no>.snapshot.json`

The `--savesnapshot` argument is only used when a `--poolid` is specified and the DripDropz API is queried for a stake
snapshot. If not specified the default path for snapshots will be saved at `./snapshots/<pool_id>/<epoch_no>.snapshot.json`
which should work well for the majority of cases.

Note that because utilizing the DripDrop API to retrieve delegator snapshots consumes API Credits, this script always
attempts to locate an existing snapshot at the path provided by `--savesnapshot` to minimize the number of API calls
required.

**Example**
```shell
> ./rewardStakers.sh --strategy mystrat \
  --poolid pool1n84mel6x3e8sp0jjgmepme0zmv8gkw8chs98sqwxtruvkhhcsg8 \
  --savesnapshot ./snapshots/blade.snapshot.json
```

##### --sourcefile \<file_path>

> Required: false
> 
> Purpose: This argument may be used to refer to an existing snapshot file rather than querying the DripDropz API
> 
> Default: `null`

If provided, this must be a valid path to a JSON document matching the format found in 
[stakers.sample.json](./stakers.sample.json).

**Example**
```shell
> ./rewardStakers.sh --strategy mystrat \
  --sourcefile ./snapshots/blade.snapshot.json
```

##### --source \<json_string>

> Required: false
> 
> Purpose: Use if you have a JSON string that you would like to pass to the script instead of a file
> 
> Default: `null`

If provided, this must be a valid JSON string matching the format found in [stakers.sample.json](./stakers.sample.json)

**Example**
```shell
> myjson=$(jq . ./snapshots/blade.snapshot.json)
> ./rewardStakers.sh --strategy mystrat \
  --source "${myjson}"
```

##### --appid \<string>

> Required: false
> 
> Purpose: Provide or override the App ID specified in `./.ddz.env` or the `.strategy` file
> 
> Environment Variable: DDZ_APP_ID
> 
> Default: `null`

Normally the App ID and [Access Token](#--accesstoken-string) will be specified in either the global `./.ddz.env` file
or in a `.strategy` file. These variables are used to provide API Key access to the DripDropz API requests. These
command line variables exist for the purposes of testing and "overloading" the value specified globally.

The App ID may be declared globally in the `./.ddz.env` file using the variable name `DDZ_APP_ID`. It may also be
overridden in a specific `.strategy` file using the same `DDZ_APP_ID` variable name to allow you to have strategies
for different token buckets and API Keys.

**MUST ALWAYS BE USED IN CONJUNCTION WITH A MATCHING ACCESS TOKEN**

**Example**
```shell
> ./rewardStakers.sh --strategy mystrat \
  --appid ABC123 \
  --accesstoken XYZ789
```

##### --accesstoken \<string>

> Required: false
>
> Purpose: Provide or override the Access Token specified in `./.ddz.env` or the `.strategy` file
>
> Environment Variable: DDZ_ACCESS_TOKEN
>
> Default: `null`

Normally the [App ID](#--appid-string) and Access Token will be specified in either the global `./.ddz.env` file
or in a `.strategy` file. These variables are used to provide API Key access to the DripDropz API requests. These 
command line variables exist for the purposes of testing and "overloading" the value specified globally.

The Access Token may be declared globally in the `./.ddz.env` file using the variable name `DDZ_ACCESS_TOKEN`. It may
also be overridden in a specific `.strategy` file using the same `DDZ_ACCESS_TOKEN` variable name to allow you to have
strategies for different token buckets and API Keys.

**MUST ALWAYS BE USED IN CONJUNCTION WITH A MATCHING APP ID**

**Example**
```shell
> ./rewardStakers.sh --strategy mystrat \
  --appid ABC123 \
  --accesstoken XYZ789
```

##### --network \<integer>

> Required: false
> 
> Purpose: Specify the Cardano network
> 
> Environment Variable: DDZ_NETWORK_ID
> 
> Possible Values:
> * 1: Cardano Mainnet
> * 0: Cardano Preproduction Testnet
> 
> Default: `1` Mainnet

Specify which Cardano Network the provided App ID and Access Token belong to and which network should be queried for
stake snapshot data. Normally this will be specified in the global `./.ddz.env` file or in a `.strategy` file.

The Network ID may be declared globally in the `./.ddz.env` file using the variable name `DDZ_NETWORK_ID`. It may
also be overridden in a specific `.strategy` file using the same `DDZ_NETWORK_ID` variable name.

**MUST ALWAYS MATCH THE NETWORK OF THE SPECIFIED APP ID AND ACCESS TOKEN**

**Example**
```shell
> ./rewardStakers.sh --strategy mystrat \
  --appid BCD345
  --accesstoken HIJ642
  --network 0
```

##### --ticker \<string>

> Required: false
> 
> Purpose: Add a user-friendly Pool "Ticker" to the instant rewards message displayed on DripDropz
> 
> Environment Variable: DDZ_TICKER
> 
> Default: `null`

This script will include a message for all issued rewards in the following format:
```
Instant pool rewards [from <ticker>] (Epoch #<epoch_no>)
```
Providing the pool ticker via either environment variable or command line argument will include the ticker in the
rewards message.

The Pool Ticker may be declared globally in the `./.ddz.env` file using the variable name `DDZ_TICKER`. It may
also be overridden in a specific `.strategy` file using the same `DDZ_TICKER` variable name.

```shell
> ./rewardStakers.sh --strategy mystrat \
  --poolid pool1n84mel6x3e8sp0jjgmepme0zmv8gkw8chs98sqwxtruvkhhcsg8 \
  --ticker BLADE
```

##### --flatrate \<integer>

> Required: false
> 
> Purpose: Specify a flat rate amount of tokens that should be issued to all eligible wallets found in the provided
> snapshot.
> 
> Environment Variable: DDZ_FLAT_RATE
> 
> Default: `null`

> **NOTE:** YOU MUST CHOOSE EITHER FLAT RATE OR PER ADA REWARD STRATEGY. A VALUE SPECIFIED FOR PER ADA WILL OVERRIDE A
> VALUE SET FOR FLAT RATE.

> **NOTE:** TOKEN VALUES MUST BE SPECIFIED IN THEIR BASE AMOUNTS!
> 
> EXAMPLE: 1 $ADA = 1,000,000 Lovelace
> 
> EXAMPLE: 1 $DRIP = 1,000,000 Dropz
> 
> In order to issue 1 $DRIP to each delegated wallet we would specify `--flatrate 1000000`

Specifies a fixed (flat) rate of tokens that will be issued to each eligible address in the snapshot. Can be modified
by [--loyaltymod](#--loyaltymod-float), [--minreward](#--minreward-integer), and [--maxreward](#--maxreward-integer)
arguments.

Normally this value will be included as part of your `.strategy` file via the `DDZ_FLAT_RATE` variable.

**Example**
```shell
Delegator A: 100A
Delegator B: 1,000,000A

> ./rewardStakers.sh \
  --poolid pool1n84mel6x3e8sp0jjgmepme0zmv8gkw8chs98sqwxtruvkhhcsg8 \
  --ticker BLADE \
  --flatrate 10
  
> Delegator A Rewards: 10 Tokens
> Delegator B Rewards: 10 Tokens
```

##### --perada \<float>

> Required: false
>
> Purpose: Specify an amount of tokens that should be issued to all eligible wallets multiplied by the amount of $ADA
> delegated as found in the provided snapshot.
>
> Environment Variable: DDZ_FLAT_RATE
>
> Default: `null`

> **NOTE:** YOU MUST CHOOSE EITHER FLAT RATE OR PER ADA REWARD STRATEGY. A VALUE SPECIFIED FOR PER ADA WILL OVERRIDE A
> VALUE SET FOR FLAT RATE. 
> 
> ISSUED TOKENS ARE ALWAYS ROUNDED DOWN TO THE CLOSEST INTEGER VALUE SO 1.9 TOKENS WILL BECOME
> 1 TOKEN REWARDED.

> **NOTE:** TOKEN VALUES MUST BE SPECIFIED IN THEIR BASE AMOUNTS!
>
> EXAMPLE: 1 $ADA = 1,000,000 Lovelace
>
> EXAMPLE: 1 $DRIP = 1,000,000 Dropz
>
> In order to issue 1 $DRIP per 1 $ADA delegated we would specify `--perada 1000000`

Specifies an amount of tokens that should be issued to each eligible wallet for each 1 $ADA delegated. Can be modified
by [--loyaltymod](#--loyaltymod-float), [--minreward](#--minreward-integer), and [--maxreward](#--maxreward-integer)
arguments.

Normally this value will be included as part of your `.strategy` file via the `DDZ_PER_ADA` variable.

**Example (1 Token per ADA delegated)**
```shell
Delegator A: 100A
Delegator B: 1,000,000A

> ./rewardStakers.sh \
  --poolid pool1n84mel6x3e8sp0jjgmepme0zmv8gkw8chs98sqwxtruvkhhcsg8 \
  --ticker BLADE \
  --perada 1
  
> Delegator A Rewards: 100 Tokens
> Delegator B Rewards: 1000000 Tokens
```

**Example (2.5 Tokens per ADA delegated)**
```shell
Delegator A: 10A
Delegator B: 233A

> ./rewardStakers.sh \
  --poolid pool1n84mel6x3e8sp0jjgmepme0zmv8gkw8chs98sqwxtruvkhhcsg8 \
  --ticker BLADE \
  --perada 2.5
  
> Delegator A Rewards: 25 Tokens
> Delegator B Rewards: 582 Tokens # (2.5 * 233) = 582.5 [rounds down to 582] 
```

##### --minlovelace \<integer>

> Required: false
>
> Purpose: Specify a minimum amount of Lovelace that a wallet must delegate in order to qualify for rewards.
>
> Environment Variable: DDZ_MIN_LOVELACE
>
> Default: `1`

> **NOTE:** The script will always require that delegators must have at least 1 Lovelace delegated to the pool. It is
> possible for an "empty" wallet to be delegated to a pool and these are automatically ignored by the logic of the script.

Specify a minimum amount of Lovelace that a delegator must have delegated to the pool during the snapshot in order to
qualify for rewards.

Normally this value will be included as part of your `.strategy` file via the `DDZ_MIN_LOVELACE` variable.

**Example (Minimum of 100 ada)**
```shell
Delegator A: 10A
Delegator B: 1,000A

> ./rewardStakers.sh \
  --poolid pool1n84mel6x3e8sp0jjgmepme0zmv8gkw8chs98sqwxtruvkhhcsg8 \
  --ticker BLADE \
  --perada 1 \
  --minlovelace 100000000 # 100 ADA in Lovelace notation 100 * 10e6
  
> Delegator A Rewards: [NOT ELIGIBLE]
> Delegator B Rewards: 1000 Tokens
```

##### --minloyalty \<integer>

> Required: false
>
> Purpose: Specify a minimum number of epochs a wallet must be delegated for in order to qualify for rewards.
>
> Environment Variable: DDZ_MIN_LOYALTY
>
> Default: `0`

> **NOTE:** The DripDropz API uses the most recent snapshot that occurred at the beginning of the current epoch to
> determine delegated amounts. For this reason, it is possible for newly delegated wallets to appear in the snapshot as
> having 0 epoch loyalty because the most recent snapshot is the first epoch they have been an active delegator to the
> pool.

Specify a minimum number (inclusive) of epochs that a delegator must have delegated to the pool before becoming eligible
to earn rewards. The value is inclusive so when using the default of `0` epochs of loyalty even newly delegated wallets
will be ruled eligible.

Normally this value will be included as part of your `.strategy` file via the `DDZ_MIN_LOYALTY` variable.

**Example (Minimum of 10 epochs loyalty)**
```shell
Delegator A: 10A, 5 epochs
Delegator B: 1,000A, 25 epochs

> ./rewardStakers.sh \
  --poolid pool1n84mel6x3e8sp0jjgmepme0zmv8gkw8chs98sqwxtruvkhhcsg8 \
  --ticker BLADE \
  --perada 1 \
  --minloyalty 10
  
> Delegator A Rewards: [NOT ELIGIBLE]
> Delegator B Rewards: 1000 Tokens
```

##### --loyaltymod \<float>

> Required: false
> 
> Purpose: Apply a bonus modifier to each wallet's rewards based on the number of epochs delegated.
> 
> Environment Variable: DDZ_LOYALTY_MOD
> 
> Possible Values: [1.0 .. n]
> 
> Default: 1.0

The Loyalty Mod argument allows you to specify a compounding multiplier that will be applied to each eligible address 
for each additional epoch they have been delegated. This is applied via the formula:

``` 
Total Rewards: tr
Base Rewards: br
Loyalty Modifier: lm
Epoch Loyalty: el

tr = br * (lm ^ el)
```

Normally this value will be included as part of your `.strategy` file via the `DDZ_LOYALTY_MOD` variable.

**Example (Increase rewards by 1% per epoch delegated)**
```shell
Delegator A: 10A, 5 epochs
Delegator B: 1,000A, 25 epochs

> ./rewardStakers.sh \
  --poolid pool1n84mel6x3e8sp0jjgmepme0zmv8gkw8chs98sqwxtruvkhhcsg8 \
  --ticker BLADE \
  --perada 1 \
  --loyaltymod 1.01
  
> Delegator A Rewards:
  Base Reward: 10 tokens
  Loyalty Modifier: 1.01
  Epoch Loyalty: 5
  Total Rewards: 10 * (1.01 ^ 5) = 10.51 tokens
  Reward: 10 Tokens # Rounds down to 10 tokens
  
> Delegator B Rewards:
  Base Reward: 1000 tokens
  Loyalty Modifier: 1.01
  Epoch Loyalty: 25
  Total Rewards: 1000 * (1.01 ^ 25) = 1282.43 Tokens
  Reward: 1282 Tokens # Rounds down to 1282
```

**Example (Increase rewards by 10% per epoch delegated)**
```shell
Delegator A: 10A, 5 epochs
Delegator B: 1,000A, 25 epochs

> ./rewardStakers.sh \
  --poolid pool1n84mel6x3e8sp0jjgmepme0zmv8gkw8chs98sqwxtruvkhhcsg8 \
  --ticker BLADE \
  --perada 1 \
  --loyaltymod 1.1
  
> Delegator A Rewards:
  Base Reward: 10 tokens
  Loyalty Modifier: 1.1
  Epoch Loyalty: 5
  Total Rewards: 10 * (1.1 ^ 5) = 16.1051 tokens
  Reward: 16 Tokens # Rounds down to 16 tokens
  
> Delegator B Rewards:
  Base Reward: 1000 tokens
  Loyalty Modifier: 1.1
  Epoch Loyalty: 25
  Total Rewards: 1000 * (1.1 ^ 25) = 10834.7059 Tokens
  Reward: 10834 Tokens # Rounds down to 10834
```

##### --maxreward \<integer>

> Required: false
>
> Purpose: Specify a maximum amount of tokens that any individual wallet will be able to receive in a given epoch.
>
> Environment Variable: DDZ_MAX_REWARD
>
> Possible Values: [0..n]
>
> Default: 0

If specified, this argument limits the theoretical maximum amount of tokens that any individual delegator may receive.
Maximum rewards are applied after base rewards and any qualifying modifiers are applied. This can be particularly useful
when used in conjunction with `--perada` or `--loyaltymod` to prevent astronomically high amounts of rewards from being
generated.

Normally this value will be included as part of your `.strategy` file via the `DDZ_MAX_REWARD` variable.

**Example (Increase rewards by 10% per epoch delegated up to a maximum of 500 tokens)**
```shell
Delegator A: 10A, 5 epochs
Delegator B: 1,000A, 25 epochs

> ./rewardStakers.sh \
  --poolid pool1n84mel6x3e8sp0jjgmepme0zmv8gkw8chs98sqwxtruvkhhcsg8 \
  --ticker BLADE \
  --perada 1 \
  --loyaltymod 1.1 \
  --maxreward 500
  
> Delegator A Rewards:
  Base Reward: 10 tokens
  Loyalty Modifier: 1.1
  Epoch Loyalty: 5
  Total Rewards: 10 * (1.1 ^ 5) = 16.1051 tokens
  Max Rewards: 500
  Reward: 16 Tokens # Rounds down to 16 tokens
  
> Delegator B Rewards:
  Base Reward: 1000 tokens
  Loyalty Modifier: 1.1
  Epoch Loyalty: 25
  Total Rewards: 1000 * (1.1 ^ 25) = 10834.7059 Tokens # Rounds down to 10834
  Max Rewards: 500
  Reward: 500 Tokens 
```

##### --minreward \<integer>

> Required: false
>
> Purpose: Specify a minimum amount of tokens that any individual, eligible wallet will receive in a given epoch.
>
> Environment Variable: DDZ_MIN_REWARD
>
> Possible Values: [0..n]
>
> Default: 0

If specified, this argument specifies a minimum amount of tokens that any individual delegator will receive. Minimum
rewards are applied after base rewards  and any qualifying modifiers are applied (but before maximum rewards). This can
be particularly useful when used in conjunction with `--perada` or `--loyaltymod` to provide a minimum amount of rewards
for every delegator.

Normally this value will be included as part of your `.strategy` file via the `DDZ_MIN_REWARD` variable.

**Example (Increase rewards by 10% per epoch delegated up to a maximum of 500 tokens, minimum 20 tokens)**
```shell
Delegator A: 10A, 5 epochs
Delegator B: 1,000A, 25 epochs

> ./rewardStakers.sh \
  --poolid pool1n84mel6x3e8sp0jjgmepme0zmv8gkw8chs98sqwxtruvkhhcsg8 \
  --ticker BLADE \
  --perada 1 \
  --loyaltymod 1.1 \
  --maxreward 500 \
  --minreward 20
  
> Delegator A Rewards:
  Base Reward: 10 tokens
  Loyalty Modifier: 1.1
  Epoch Loyalty: 5
  Total Rewards: 10 * (1.1 ^ 5) = 16.1051 tokens # Rounds down to 16 tokens
  Min Rewards: 20
  Max Rewards: 500
  Reward: 20 Tokens 
  
> Delegator B Rewards:
  Base Reward: 1000 tokens
  Loyalty Modifier: 1.1
  Epoch Loyalty: 25
  Total Rewards: 1000 * (1.1 ^ 25) = 10834.7059 Tokens # Rounds down to 10834
  Min Rewards: 20
  Max Rewards: 500
  Reward: 500 Tokens 
```