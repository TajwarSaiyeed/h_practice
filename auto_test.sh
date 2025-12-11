#!/bin/bash

BASE_URL="http://localhost/api"
COOKIE_JAR="auto_test_cookies.txt"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting Automatic Endpoint Testing Simulation...${NC}"

# 1. Register and Login a User
RANDOM_ID=$RANDOM
EMAIL="auto_user_${RANDOM_ID}@example.com"
PASSWORD="password123"
NAME="Auto User ${RANDOM_ID}"

echo -e "${YELLOW}Registering User: $EMAIL${NC}"
curl -s -c "$COOKIE_JAR" -X POST "$BASE_URL/users/register" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"$NAME\",\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}" > /dev/null

echo -e "${GREEN}User Registered & Logged In.${NC}"

# Function to make requests with retry logic
make_request_with_retry() {
    local url="$1"
    local method="$2"
    local data="$3"
    local cookie_jar="$4"
    local max_retries=30
    local wait_time=2
    local attempt=1

    while [ $attempt -le $max_retries ]; do
        if [ -n "$data" ]; then
            response=$(curl -s -b "$cookie_jar" -X "$method" "$url" -H "Content-Type: application/json" -d "$data")
        else
            response=$(curl -s -b "$cookie_jar" -X "$method" "$url" -H "Content-Type: application/json")
        fi

        # Check for Nginx errors (502/504) or Connection Refused
        if echo "$response" | grep -qE "502 Bad Gateway|504 Gateway Time-out|Connection refused"; then
             echo -e "${YELLOW}   Service unavailable (Attempt $attempt/$max_retries). Retrying in ${wait_time}s...${NC}" >&2
             sleep $wait_time
             attempt=$((attempt + 1))
        else
             echo "$response"
             return 0
        fi
    done
    
    echo "$response"
    return 1
}

# Loop 100 times
for COUNTER in {1..100}; do
    echo -e "\n${BLUE}--- Iteration $COUNTER ---${NC}"

    # 2. Create Post
    TITLE="Auto Post $RANDOM_ID - $COUNTER"
    CONTENT="This is an automatically generated post content for iteration $COUNTER."
    
    echo -n "Creating Post... "
    CREATE_RES=$(make_request_with_retry "$BASE_URL/posts" "POST" "{\"title\":\"$TITLE\",\"content\":\"$CONTENT\"}" "$COOKIE_JAR")
    
    POST_ID=$(echo "$CREATE_RES" | jq -r '.id')

    if [ "$POST_ID" != "null" ] && [ -n "$POST_ID" ]; then
        echo -e "${GREEN}Success (ID: $POST_ID)${NC}"
        
        # 3. Like Post
        echo -n "Liking Post... "
        LIKE_RES=$(make_request_with_retry "$BASE_URL/interactions/$POST_ID" "POST" "{\"type\":\"LIKE\"}" "$COOKIE_JAR")
        echo -e "${GREEN}Done${NC}"

        # 4. Get Interactions
        echo -n "Checking Interactions... "
        INTERACTION_RES=$(make_request_with_retry "$BASE_URL/interactions/$POST_ID" "GET" "" "$COOKIE_JAR")
        LIKES=$(echo "$INTERACTION_RES" | jq -r '.likes')
        DISLIKES=$(echo "$INTERACTION_RES" | jq -r '.dislikes')
        echo -e "${YELLOW}Likes: $LIKES | Dislikes: $DISLIKES${NC}"

    else
        echo -e "${RED}Failed to create post${NC}"
        echo "Response: $CREATE_RES"
    fi

    sleep 1
done

