#!/bin/bash

export PGPASSWORD='1213fcz1016'
PSQL="psql --username=postgres --dbname=salon -A -t"

function MENU(){
    $PSQL -c "select * from services" | while IFS='|' read SERVICE_ID NAME
    do
        echo "$SERVICE_ID) $NAME"
    done 
    if [[ $1 ]]
    then
        echo -e "\n$1"
    fi
    echo -e "\nwhat service do you want to choose today,please enter your service id, phone number, (name if you are first time), and time"
}

function MAIN(){
    MENU
    IFS=',' read -ra INPUT_ARR
    SERVICE_ID_SELECTED=${INPUT_ARR[0]}
    CUSTOMER_PHONE=$(echo "${INPUT_ARR[1]}" | sed 's/^ *//g')
    SERVICE_NAME=$($PSQL -c "select name from services where service_id=${INPUT_ARR[0]}")
    while [[ -z $SERVICE_NAME ]]
    do
        MENU "the service doesn't exists, please select again!"
        IFS=',' read -ra INPUT_ARR
        SERVICE_ID_SELECTED=${INPUT_ARR[0]}
        CUSTOMER_PHONE=$(echo "${INPUT_ARR[1]}" | sed 's/^ *//g')
        SERVICE_NAME=$($PSQL -c "select name from services where service_id=${INPUT_ARR[0]}")
    done

    PHONE=$($PSQL -c "select phone from customers where phone='$CUSTOMER_PHONE'")
    if [[ -z $PHONE ]]
    then
        CUSTOMER_NAME=$(echo "${INPUT_ARR[2]}" | sed 's/^ *//g')
        SERVICE_TIME=$(echo "${INPUT_ARR[3]}" | sed 's/^ *//g')
        MS=$($PSQL -c "insert into customers(phone,name) values ('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
    else
        SERVICE_TIME=$(echo "${INPUT_ARR[2]}" | sed 's/^ *//g')
        CUSTOMER_NAME=$($PSQL -c "select name from customers where phone='$CUSTOMER_PHONE'")
    fi

    CUSTOMER_ID=$($PSQL -c "select customer_id from customers where phone='$CUSTOMER_PHONE'")
    MS=$($PSQL -c "insert into appoinments(customer_id,service_id,time) values($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
}

MAIN
unset PGPASSWORD
exit