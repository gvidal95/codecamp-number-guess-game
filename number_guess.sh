#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_game -t --no-align -c"

CREATE_GUESS_NUMBER_GAME() {
  # $1: USERNAME, $2 USERNAMEDB

  # Random numbers, beetween 1 and 1000
  SECRET_NUMBER=$(($RANDOM%1000 + 1))

  echo -e "Guess the secret number between 1 and 1000:"
  GUESS_NUMBER_GAME $SECRET_NUMBER 0 $1 $2
}

GUESS_NUMBER_GAME() {
  # $1: SECRET_NUMBER, $2 ATTEMPT COUNTER,  $3: USERNAME, $4 USERNAMEDB
  # echo -e "SECRET: $1"

  ATTEMPT_NUMBER=$2
 
  read INPUT_NUMBER

  if [[ ! $INPUT_NUMBER =~ ^[0-9]+$ ]]
  then
    echo -e "That is not an integer, guess again:"
    GUESS_NUMBER_GAME $1 $ATTEMPT_NUMBER $3 $4
  else
    (( ATTEMPT_NUMBER++ ))
    # Guess number
    if [[ $INPUT_NUMBER -gt $1 ]]
    then
      echo -e "It's higher than that, guess again:"
      GUESS_NUMBER_GAME $1 $ATTEMPT_NUMBER $3 $4
    elif [[ $INPUT_NUMBER -lt $1 ]]
    then
      echo -e "It's lower than that, guess again:"
      GUESS_NUMBER_GAME $1 $ATTEMPT_NUMBER $3 $4
    else
      USERNAME_DB=$4
      if [[ -z $USERNAME_DB ]]
      then
        INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES ('$3')")
        INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(attempts, username) VALUES ($ATTEMPT_NUMBER, '$3')")
      else 
        INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(attempts, username) VALUES ($ATTEMPT_NUMBER, '$USERNAME_DB')")
      fi

      echo -e "\nYou guessed it in $ATTEMPT_NUMBER tries. The secret number was $1. Nice job!"

    fi
  fi

}

READ_INPUT() {
  echo -e "Enter your username:"
  read USERNAME

  if [[ -z $USERNAME ]]
  then
    READ_INPUT
  else
    USERNAMEDB=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")

    if [[ -z $USERNAMEDB ]]
    then
      echo -e "Welcome, $USERNAME! It looks like this is your first time here."

      CREATE_GUESS_NUMBER_GAME $USERNAME $USERNAMEDB 

    else 
      NUMBER_GAMES=$($PSQL "SELECT COUNT(*) FROM games WHERE username = '$USERNAMEDB'")
      BEST_GAME_ATTEMTPS=$($PSQL "SELECT MIN(attempts) FROM games WHERE username = '$USERNAMEDB'")
      
      echo -e "Welcome back, $USERNAMEDB! You have played $NUMBER_GAMES games, and your best game took $BEST_GAME_ATTEMTPS guesses."

      CREATE_GUESS_NUMBER_GAME $USERNAME $USERNAMEDB

    fi
  fi
}

READ_INPUT


