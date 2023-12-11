#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME_INPUT

USERNAME=$($PSQL "SELECT username FROM user_info WHERE username='$USERNAME_INPUT'")
GAMES_PLAYED=$($PSQL "SELECT games_played FROM user_info WHERE username='$USERNAME_INPUT'")
BEST_SCORE=$($PSQL "SELECT best_game FROM user_info WHERE username='$USERNAME_INPUT'")
SECRET_NUMBER=$((1 + $RANDOM % 1000))
NUMBER_OF_GUESSES=1

UPDATE_GAMES_PLAYED() {
  ((GAMES_PLAYED++))
}

UPDATE_BEST_SCORE() {
  if [[ $GAMES_PLAYED -eq 0 ]]
  then 
    BEST_SCORE=$NUMBER_OF_GUESSES
  elif [[ $NUMBER_OF_GUESSES -lt $BEST_SCORE ]] 
  then
      BEST_SCORE=$NUMBER_OF_GUESSES
  fi
}

GUESSING_GAME() {
  echo -e "\nGuess the secret number between 1 and 1000:"
  read GUESS

  while [[ $GUESS -ne $SECRET_NUMBER ]]
  do
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
      read GUESS
    elif [[ $GUESS -lt $SECRET_NUMBER ]]
    then 
      echo "It's higher than that, guess again:"
      ((NUMBER_OF_GUESSES++))
      read GUESS
    elif [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      ((NUMBER_OF_GUESSES++))
      read GUESS
    fi
  done

  UPDATE_BEST_SCORE
  UPDATE_GAMES_PLAYED

  $PSQL "UPDATE user_info SET games_played = $GAMES_PLAYED, best_game = $BEST_SCORE WHERE username = '$USERNAME_INPUT'" >/dev/null
  echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
}


if [[ -z $USERNAME ]]
then
  echo "Welcome, $USERNAME_INPUT! It looks like this is your first time here."
  $PSQL "INSERT INTO user_info(username) VALUES('$USERNAME_INPUT')" >/dev/null
else 
  echo "Welcome back, $USERNAME_INPUT! You have played $GAMES_PLAYED games, and your best game took $BEST_SCORE guesses."
fi

GUESSING_GAME
