#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
USERNAME="";

echo "Enter your username:"
read USERNAME;
# check if username exists into the database
RES=$($PSQL "select username from usernames where username = '$USERNAME';")
# echo "FETCHED USERNAME: '$RES'";
if [[ -z $RES ]]
then
  # if not found
  # display a new user welcome message
  echo "Welcome, $USERNAME! It looks like this is your first time here.";
  # insert new user
  RES=$($PSQL "insert into usernames (username) values ('$USERNAME');");
else
  # get user statistics
    # number of played games
  GAMES=$($PSQL "select count(*) from games where username = '$USERNAME';");
    # best game (min(tries))
  BEST=$($PSQL "select min(guesses) from games where username = '$USERNAME' group by username;");
  # display a welcome back and user's statistics
  echo "Welcome back, $USERNAME! You have played $GAMES games, and your best game took $BEST guesses.";
fi
# initialize game's data
COUNT=0;
GUESS="";
SECRET=$(($RANDOM % 1000 + 1))
# echo "SECRET='$SECRET'"
# start playing! 
echo "Guess the secret number between 1 and 1000:"
read GUESS
while true
do
  [[ $COUNT -gt 0 ]] && read GUESS
  ((COUNT++))
  [[ "$GUESS" -eq "$SECRET" ]] && break;
  if [[ ! $GUESS =~ [0-9]+ ]]
  then
    echo "That is not an integer, guess again:"
  elif [ $GUESS -lt $SECRET ]
  then
    echo "It's higher than that, guess again:"
  else
    echo "It's lower than that, guess again:"
  fi
done
RES=$($PSQL "insert into games (username, guesses) values ('$USERNAME', $COUNT);");
echo "You guessed it in $COUNT tries. The secret number was $SECRET. Nice job!"
