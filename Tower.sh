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

print() {
  echo "Towers:"
  for i in {1..3}; do
    local TW="T$i"
    if [ -d "${!TW}" ]; then
      local levels=$(ls -A "${!TW}")
      local tower=""
      local levelString=""
      for level in $levels; do
        local disk=$(printf "%0.s#" $(seq 1 ${level: -1}))
        tower="$tower$disk\n"
        levelString="$levelString$level, "
      done
      echo "tower$i: ${levelString%, }"
      echo -e "$tower"
    else
      echo "tower$i: Tower does not exist"
    fi
  done
  echo "------------------"
}

# Function to move a level from one tower to another
move() {
  local TW1="T$1"
  local TW2="T$2"

  # Check if the source tower exists
  if ! [ -d "${!TW1}" ]; then
    echo "Error: Tower $1 does not exist!"
    continue
  fi

  # Check if the destination tower exists
  if ! [ -d "${!TW2}" ]; then
    echo "Error: Tower $2 does not exist!"
    continue
  fi

  local LV="level9"
  local TW1="${!TW1}/"
  local TW2="${!TW2}/"

  if [ -z "$(ls -A "$TW1")" ]; then
    echo "The tower FROM is empty"
    return
  else
    for file in "$TW1"*; do
      if [[ "${file: -1}" -le "${LV: -1}" ]]; then
        LV="$file"
      fi
    done
  fi

  if ! [ -z "$(ls -A "$TW2")" ]; then
    for file1 in "$TW2"*; do
      if [[ "${LV: -1}" -ge "${file1: -1}" ]]; then
        echo "You cannot put that level on that tower!"
        return
      fi
    done
  fi

  mv "$LV" "$TW2"
  echo "Moved $LV from $TW1 to $TW2"
}

echo "The game has started!"
T1="$Dir/tower1"
T2="$Dir/tower2"
T3="$Dir/tower3"
mkdir -p "$T1" "$T2" "$T3"
for i in $(seq 1 $Height); do
  touch "$T1/level$i"
done

while [[ $END -eq 0 ]]; do
  print
  echo "Enter two numbers: the tower you want to move a level from, and what tower to put it on: "
  echo "FROM TO"
  read -r TW1 TW2

if (( TW1 >= 1 && TW1 <= 3 && TW2 >= 1 && TW2 <= 3 )); then
  move "$TW1" "$TW2"
elif ((( TW1 < 1 || TW1 > 3 ) && ( TW2 < 1 || TW2 > 3 ))); then
  echo "Both chosen towers do not exist"
elif (( TW1 < 1 || TW1 > 3 )); then
  echo "Tower FROM which you want to move a disk does not exist"
elif (( TW2 < 1 || TW2 > 3 )); then
  echo "Tower TO which you want to move a disk does not exist"
fi
  # Check if the game is finished
  if [[ -z "$(ls -A "$T1")" && -z "$(ls -A "$T2")" ]]; then
    echo "Congratulations! You have successfully completed the game."
    print
    END=1
  fi
done
