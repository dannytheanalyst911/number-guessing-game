#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
ANSWER=$(( $RANDOM % 1000 + 1 ))
INPUTS=0

echo -e "Enter your username:"
read USERNAME

CHECK=$($PSQL "SELECT * FROM users WHERE username = '$USERNAME'")
if [[ -z $CHECK ]]
then
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
  Z=$($PSQL "INSERT INTO users(username, game_played, best_game) VALUES('$USERNAME', 0, 1000)")
else
  echo $CHECK | while IFS="|" read ID NAME PLAY BEST
  do
    echo "Welcome back, $NAME! You have played $PLAY games, and your best game took $BEST guesses." 
  done
fi

X=$($PSQL "UPDATE users SET game_played = game_played + 1 WHERE username = '$USERNAME'")

echo -e "\nGuess the secret number between 1 and 1000:"
while true
do
  read INPUT
  ((INPUTS++))
  if [[ $INPUT =~ ^[0-9]+$ ]]
  then
    if [[ $INPUT > $ANSWER ]]
    then
      echo -e "It's lower than that, guess again:"  
    else
      if [[ $INPUT < $ANSWER ]]
      then 
        echo -e "It's higher than that, guess again:"   
      else
        BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")
        if [[ $INPUTS -lt $BEST_GAME ]]
        then
          Y=$($PSQL "UPDATE users SET best_game = $INPUTS WHERE username = '$USERNAME'")
        fi
        echo "You guessed it in $INPUTS tries. The secret number was $ANSWER. Nice job!"
        exit
      fi
    fi
  else
    echo -e "That is not an integer, guess again:"   
  fi
done
