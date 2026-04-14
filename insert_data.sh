#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINGLS OPPGLS
do
  # Trim whitespace from variables
  YEAR=$(echo "$YEAR" | xargs)
  ROUND=$(echo "$ROUND" | xargs)
  WINNER=$(echo "$WINNER" | xargs)
  OPPONENT=$(echo "$OPPONENT" | xargs)
  WINGLS=$(echo "$WINGLS" | xargs)
  OPPGLS=$(echo "$OPPGLS" | xargs)

  if [[ $WINNER != "winner" ]]
  then
    WIN_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    if [[ -z $WIN_ID ]]
    then
      TEAM_INSERT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
    fi
    OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
    if [[ -z $OPP_ID ]]
    then
      TEAM_INSERT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
    fi
    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE winner_id=$WIN_ID AND opponent_id=$OPP_ID")
    if [[ -z $GAME_ID ]]
    then
      GAME_INSERT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WIN_ID, $OPP_ID, $WINGLS, $OPPGLS)")
    fi
  fi
done
