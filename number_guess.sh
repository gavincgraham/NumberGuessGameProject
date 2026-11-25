#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

#insert username
echo -e "Enter your username:"
read USERNAME

#Get user_id
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

#check if user doesn't exists
if [[ -z $USER_ID ]]; then
  #new user echo
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
  
  #insert new user into table
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  #Get user_id for new user
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
else
  #if user DOES exist
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(total_guesses) FROM games WHERE user_id=$USER_ID")

  echo -e "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

#Generate random number
SECRET_NUMBER=$(( RANDOM % 1000 + 1))

#Variables for game loop
USER_GUESS=0
NUMBER_OF_GUESSES=0

#Game loop
echo -e "Guess the secret number between 1 and 1000:"
until [[ $USER_GUESS == $SECRET_NUMBER ]]
do
  #Ask for input
  read USER_GUESS
  #Make sure input is a integer
  until [[ $USER_GUESS =~ ^[0-9]+$ ]] 
  do
    echo -e "That is not an integer, guess again:"
    read USER_GUESS
  done
  #increment guess
  (( NUMBER_OF_GUESSES++ ))
  #If guess is less than number
  if (( $USER_GUESS < $SECRET_NUMBER ))
  then
    echo -e "It's higher than that, guess again:"
  #If guess is greater than number
  elif (( $USER_GUESS > $SECRET_NUMBER ))
  then
    echo -e "It's lower than that, guess again:"
  #If input is correct
  elif (( $USER_GUESS == $SECRET_NUMBER ))
  then
    echo -e "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
  fi
done

#Save game to database
INSERT_GAME_RESULTS=$($PSQL "INSERT INTO games(user_id, total_guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES)")
