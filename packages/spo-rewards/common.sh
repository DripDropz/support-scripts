#Define some colors for the command line
BOLD="\e[1m"
WARN='\033[1;31m'
REKT='\033[1;31m'
SUCCESS='\033[0;32m'
INFO='\033[1;34m'
HELP='\033[1;36m'
LINK='\e[4;1;34m'
NC='\033[0m'

getSlot() {
  currentTime=$(date +%s)
  if [ "$1" == 1 ]; then
    #mainnet
    zeroTime=1596059091
    zeroSlot=4492800
    slotLength=1
  else
    #preprod
    zeroTime=1655769600
    zeroSlot=86400
    slotLength=1
  fi

  timePassed=$((currentTime - zeroTime))
  slotsPassed=$((timePassed / slotLength))
  currentSlot=$((slotsPassed + zeroSlot))

  echo $currentSlot
}

getEpoch() {
  if [ "$1" == 1 ]; then
    startEpochOffset=197
  else
    startEpochOffset=4
  fi

  currentSlot=$(getSlot "$1")
  relativeEpoch=$((currentSlot / 432000))
  currentEpoch=$((relativeEpoch + startEpochOffset))

  echo $currentEpoch
}

max() {
  echo $(($1 > $2 ? $1 : $2))
}

min() {
  echo $(($1 < $2 ? $1 : $2))
}
