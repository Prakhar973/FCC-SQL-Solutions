#!/bin/bash

# Function to display services
display_services() {
  SERVICES=$(psql -U freecodecamp -d salon -t -A -c "SELECT service_id, name FROM services ORDER BY service_id;")
  echo "$SERVICES" | while read -r line; do
    service_id=$(echo "$line" | cut -d'|' -f1 | xargs)
    name=$(echo "$line" | cut -d'|' -f2 | xargs)
    echo "$service_id) $name"
  done
}

# Loop until valid service is selected
while true; do
  display_services
  echo "Please select a service:"
  read SERVICE_ID_SELECTED

  SERVICE_EXISTS=$(psql -U freecodecamp -d salon -t -c "SELECT COUNT(*) FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  if [ "$SERVICE_EXISTS" -gt 0 ]; then
    break
  fi
done

# Prompt for phone number
echo "What's your phone number?"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_ID=$(psql -U freecodecamp -d salon -t -c "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

if [ -z "$CUSTOMER_ID" ]; then
  # New customer
  echo "What's your name?"
  read CUSTOMER_NAME
  # Insert new customer
  psql -U freecodecamp -d salon -c "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');"
  # Get the new customer_id
  CUSTOMER_ID=$(psql -U freecodecamp -d salon -t -c "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
else
  # Existing customer
  CUSTOMER_NAME=$(psql -U freecodecamp -d salon -t -c "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
fi

# Prompt for time
echo "What time would you like your appointment?"
read SERVICE_TIME

# Insert appointment
psql -U freecodecamp -d salon -c "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"

# Get service name
SERVICE_NAME=$(psql -U freecodecamp -d salon -t -c "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")

# Output confirmation
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."