#!/usr/bin/bash

# Define some variables:
DontStart=0 # either the -h or -v argument was passed
Start=0 # if it's equal to 2 the program will start
NumOfArgs=0
Height=3 # the height of the tower
Dir=~/os/tower # the directory for the game
H=0 # '-h' passed?
V=0 # '-v' passed?
END=0 # flag to control the loop

cleanup() {
  rm -rf "$T1" "$T2" "$T3"
  echo "Cleanup complete"
}

# Register the cleanup function to be called on script exit
trap cleanup EXIT

# Handle the arguments:
for arg in "$@"; do
  NumOfArgs=$((NumOfArgs + 1))

  # Check if the number of arguments is correct
  if [ $NumOfArgs -gt 2 ]; then
    echo 'Error: Too many arguments'
    exit 1
  fi

  # Check if the argument is equal to "-h"
  if [ "$arg" = "-h" ]; then
    H=1
    DontStart=1
  fi

  # Check if the argument is equal to "-v"
  if [ "$arg" = "-v" ]; then
    V=1
    DontStart=1
  fi

  # Check if the argument is a number
  if [[ "$arg" =~ ^[0-9]+$ ]]; then
    Height="$arg"
    ((Start++))
    echo "Height set correctly"
  fi

  # Check if the argument is a valid directory
  if [ -d "$arg" ]; then
    Dir="$arg"
    ((Start++))
    echo "Directory set correctly!"
  fi
done


if [ "$H" -eq 1 ]; then
  echo "Welcome to the Tower of Hanoi game!"
  echo "The Tower of Hanoi is a classic puzzle where the goal is to move all the disks from first tower to the third one."
  echo "The game consists of three towers, labeled as tower1, tower2, and tower3."
  echo "The disks are represented by levels with numbers, with smaller numbers being smaller disks."
  echo "Your task is to move the entire stack of disks from tower1 to another tower, following these rules:"
  echo "To start the game, provide arguments: directory path, height of tower"
  echo "Maximum provided height equals 9"
  echo "To see current verison of the game, provide argument -v"
  echo "Rules:"
  echo "1. Only one disk can be moved at a time."
  echo "2. Each move consists of taking the top disk from one tower and placing it on top of another tower."
  echo "3. Bigger disk cannot be placed on top of a smaller disk."
  echo "To play, you can use the tower numbers (1, 2, 3) to select the source (FROM) and destination (TO) towers."
  echo "The game is won when all the disks are moved to the third tower, in a correct order - biggest disk at the bottom and smallest on the top."
  echo "Good luck and enjoy the Tower of Hanoi game!"
fi

if [ "$V" -eq 1 ]; then
  echo 'VERSION: 1.0'
fi

if [ "$DontStart" -eq 1 ]; then
  exit 0
fi

if [ $Start -ne 2 ]; then
  echo "Error: Incorrect arguments!"
  exit 1
fi

if [ $Height -gt 9 ]; then
  echo "Tower too tall, sorry!"
  exit 1
fi

# $1-Height $2-source $3-aux $4-destination
automatic() {
  if [ "$1" -le 0 ]; then
   continue
  fi
  if [ "$1" -eq 1 ]; then
  
    if [ -z "$(ls -A "$2")" ]; then
    return
  else
    echo "moving: $(find_smallest_disc $2) into: "$4""
    mv $(find_smallest_disc $2) "$4"
    fi
    print
    # move1 "$2" "$4" # Move the disk from the source tower to the destination tower
  else
    automatic "$(($1 - 1))" "$2" "$4" "$3" # Move the top $1-1 disks from the source tower to the auxiliary tower
    
    if [ -z "$(ls -A "$2")" ]; then
    return
  else
    echo "moving: $(find_smallest_disc $2) into: "$4""
    mv $(find_smallest_disc $2) "$4"
    fi
    # move1 "$2" "$4" # Move the bottom disk from the source tower to the destination tower
    print
    automatic "$(($1 - 1))" "$3" "$2" "$4" # Move the $1-1 disks from the auxiliary tower to the destination tower
  fi
  
}

# $1-path to the directory
find_smallest_disc() {
local DC="level9"
if [ -z "$(ls -A "$1")" ]; then
    return
  fi
for file in "$1"/level*; do
    if [[ "${file: -1}" -le "${DC: -1}" ]]; then
      DC="$file"
    fi
  done
  echo "$DC"
}

print() {
  echo "Towers:"
  for i in {1..3}; do   #A loop is initiated using for i in {1..3}; do. This loop iterates over the values 1, 2, and 3.
    local TW="T$i"  #creates a variable named TW with a value of "T1", "T2", or "T3" depending on the current iteration of the loop.
    if [ -d "${!TW}" ]; then  #The line if [ -d "${!TW}" ]; then checks if the directory whose name is stored in the variable ${!TW} exists. The ${!TW} syntax is used to access 											the value of the variable whose name is stored in TW.
      local levels=$(ls -A "${!TW}") #lists all files and directories in the directory whose name is stored in ${!TW} and stores the output in the levels variable.
      local tower=""
      local levelString=""
      for level in $levels; do #The code enters a loop using for level in $levels; do. This loop iterates over each entry in the levels variable.
        local disk=$(printf "%0.s#" $(seq 1 ${level: -1})) #creates a variable named disk with a string of hash symbols (#) equal to the last character of the current level entry.
        tower="$tower$disk\n" #creates a variable named disk with a string of hash symbols (#) equal to the last character of the current level entry.
        levelString="$levelString$level, " #creates a variable named disk with a string of hash symbols (#) equal to the last character of the current level entry.
      done
      echo "tower$i: ${levelString%, }"
      echo -e "$tower" #The line echo -e "$tower" prints the tower variable, which contains the stacked disks represented by hash symbols, with each level separated by a newline character. The -e flag enables interpretation of backslash escapes, allowing the newline character to be displayed correctly.
    else
      echo "tower$i: Tower does not exist" #The line echo "tower$i: Tower does not exist" prints a message indicating that the tower does not exist.
    fi
  done
  echo "------------------"
}

# Function to move a level from one tower to another
move() {
  local TW1="T$1"
  local TW2="T$2"
  local SOURCE="${!TW1}"
  local DESTINATION="${!TW2}"

  echo "Moving from tower $TW1 to tower $TW2"

  # Check if the source tower exists
  if ! [ -d "$SOURCE" ]; then
    echo "Error: Tower $TW1 does not exist!"
    return
  fi

  # Check if the destination tower exists
  if ! [ -d "$DESTINATION" ]; then
    echo "Error: Tower $TW2 does not exist!"
    return
  fi

  # Check if the source tower is empty
  if [ -z "$(ls -A "$SOURCE")" ]; then
    echo "The tower $TW1 is empty"
    return
  fi

  local LV="level9"

  for file in "$SOURCE"/level*; do
    if [[ "${file: -1}" -le "${LV: -1}" ]]; then
      LV="$file"
    fi
  done

  # Check if the destination tower can accommodate the disk
  if [ "$(ls -A "$DESTINATION")" ]; then
    for file1 in "$DESTINATION"/level*; do
      if [[ "${LV: -1}" -ge "${file1: -1}" ]]; then
        echo "You cannot put that level on that tower!"
        return
      fi
    done
  fi

  mv "$LV" "$DESTINATION"
  echo "Moved $LV from $SOURCE to $DESTINATION"
}


move1() {
  local TW1="T$1"
  local TW2="T$2"
  local SOURCE="${!TW1}"
  local DESTINATION="${!TW2}"

  local LV="level9"

  for file in "$SOURCE"/level*; do
    if [[ "${file: -1}" -le "${LV: -1}" ]]; then
      LV="$file"
    fi
  done

  mv $LV $DESTINATION
}

echo "The game has started!"
T1="$Dir/tower1"
T2="$Dir/tower2"
T3="$Dir/tower3"
mkdir -p "$T1" "$T2" "$T3" #create three directories - towers
for ((i = 1; i <= Height; i++)); do
  touch "$T1/level${i}" #create files
done

#find_smallest_disc $T1
automatic $Height $T1 $T2 $T3

# while [[ $END -eq 0 ]]; do
#   print
#   echo "Enter two numbers: the tower you want to move a level from, and what tower to put it on: "
#   echo "FROM TO"
#   read -r TW1 TW2

# if (( TW1 >= 1 && TW1 <= 3 && TW2 >= 1 && TW2 <= 3 )); then
#   move "$TW1" "$TW2"
# elif ((( TW1 < 1 || TW1 > 3 ) && ( TW2 < 1 || TW2 > 3 ))); then
#   echo "Both chosen towers do not exist"
# elif (( TW1 < 1 || TW1 > 3 )); then
#   echo "Tower FROM which you want to move a disk does not exist"
# elif (( TW2 < 1 || TW2 > 3 )); then
#   echo "Tower TO which you want to move a disk does not exist"
# fi

  #print
  # Check if the game is finished
  if [[ -z "$(ls -A "$T1")" && -z "$(ls -A "$T2")" ]]; then #if two first towers are empty the game is won
    echo "Congratulations! You have successfully completed the game."
    print
    END=1
  fi
# read x
# done

