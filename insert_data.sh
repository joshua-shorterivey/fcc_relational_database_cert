#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

#trunate tables before running rest of script 
echo $($PSQL "TRUNCATE teams, games;")

#read in csv data to variables  with while loop
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
    #do check for first line text, if passed check for team_id of winner in table
    if [[ $WINNER != 'winner' ]]
    then 
      #get winner id
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
      #if the id not found then insert into table
      if  [[ -z $WINNER_ID ]]
      then
        #insert into table
        INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")
        ## success message
        if [[ $INSERT_WINNER_RESULT = 'INSERT 0 1' ]]
        then
          echo Inserted into teams, $WINNER
        fi
        #after insertion grab id again
        WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
      fi

      #get OPPONENT id
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
      #if the id not found then insert into table
      if  [[ -z $OPPONENT_ID ]]
      then
        #insert into table
        INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")
        ## success message
        if [[ $INSERT_OPPONENT_RESULT = 'INSERT 0 1' ]]
        then
          echo Inserted into teams, $OPPONENT
        fi
        #after insertion grab id again
        OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")
      fi
      
      #insert correct values into games table
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")
      #echo result
      if [[ $INSERT_GAME_RESULT == 'INSERT 0 1' ]] 
      then 
        echo Inserted into games, $YEAR : $ROUND : $WINNER_ID : $OPPONENT_ID : $WINNER_GOALS : $OPPONENT_GOALS 
      fi

    fi

done

