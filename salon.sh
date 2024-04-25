#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU() {

  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "\nWelcome to My Salon, how can I help you?\n"
  fi

  #Get the services
  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services" )
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
  echo  -e "$SERVICE_ID) $SERVICE_NAME"
  done
  # Get the service they want
  read SERVICE_ID_SELECTED

  # Verificar si la selección es un número
if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
then
  NUMBER_IN_DB=$($PSQL "SELECT * FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
  # Verificar si el número está en la lista de SERVICE_ID
  if [[ -z $NUMBER_IN_DB ]]
  then
    # service doen't exixt
    MAIN_MENU "I could not find that service. What would you like today?"
  else

    # service correct
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # if the customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then
    # ask for the name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    # create an entry
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    fi
    # get the service name and customer name to print it
    
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED" )
    # ask for the time
    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # get the customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM  customers WHERE phone = '$CUSTOMER_PHONE' ")
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES('$CUSTOMER_ID',$SERVICE_ID_SELECTED,'$SERVICE_TIME') ")

    echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME."

  fi
else
  MAIN_MENU "I could not find that service. What would you like today?"
fi

}

MAIN_MENU





