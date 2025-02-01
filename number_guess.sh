#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER=$(( ($RANDOM % 1000)+1 ))
echo "Enter your username:"
read USERNAME
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")
if [[ -z $GAMES_PLAYED ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  CREATE_USER=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, 1000)")
else
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
echo "Guess the secret number between 1 and 1000:"
GUESSES=0
GUESSED=0
while [[ $GUESSED -eq 0 ]]
do
  read GUESS
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    GUESSES=$(( $GUESSES + 1 ))
    if [[ $GUESS -eq $NUMBER ]]
    then
      echo "You guessed it in $GUESSES tries. The secret number was $NUMBER. Nice job!"
      GUESSED=1
    elif [[ $GUESS -gt $NUMBER ]] 
    then
      echo "It's lower than that, guess again:"
    elif [[ $GUESS -lt $NUMBER ]] 
    then
      echo "It's higher than that, guess again:"
    fi
  else
    echo That is not an integer, guess again:
  fi
done

UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = games_played+1 WHERE username = '$USERNAME'")
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")
if [[ $BEST_GAME -gt $GUESSES ]]
then
  UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = $GUESSES WHERE username = '$USERNAME'")
fi
