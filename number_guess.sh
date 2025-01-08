#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# get username
echo "Enter your username:"
read USERNAME

# check if it is in the db

USER_ID=$($PSQL "SELECT user_id FROM user_table WHERE name = '$USERNAME'")
if [[ -z $USER_ID ]]
then 
  # if it is not in the db return
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
  # add user to db
  INSERT_USER=$($PSQL "INSERT INTO user_table(name) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM user_table WHERE name = '$USERNAME'")
else
  # if it is in the db return
  USER_ID=$($PSQL "SELECT user_id FROM user_table WHERE name = '$USERNAME'")
  GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE user_id = $USER_ID")
  echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
#generate a random number
SECRET_NUMBER=$((1 + $RANDOM % 1000))

#Guess the secret number between 1 and 1000:
echo "Guess the secret number between 1 and 1000:"

NUMBER_OF_GUESSES=0

#recursive function for the guessing game:
GUESSING_GAME() {
  ((NUMBER_OF_GUESSES++))
  read GUESS
  if [[ $GUESS = $SECRET_NUMBER ]]
  then
    # record game_id user_id number_of_guesses
    INSERT_GUESSES=$($PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)")
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    exit 0
  else
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
      GUESSING_GAME
    else
      if [[ $GUESS > $SECRET_NUMBER ]]
      then 
        echo "It's lower than that, guess again:"
        GUESSING_GAME
      else
        echo "It's higher than that, guess again:"
        GUESSING_GAME
      fi
    fi
  fi
  
}

GUESSING_GAME
