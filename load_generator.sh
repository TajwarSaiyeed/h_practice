#!/bin/bash

# Continuous load generator for monitoring visualization
# This script generates realistic traffic to populate your monitoring dashboards

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Starting Load Generator...${NC}"
echo -e "${YELLOW}This will generate traffic for monitoring dashboards${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop${NC}\n"

BASE_URL="http://localhost"
COOKIE_FILE="/tmp/load_test_cookies.txt"
COUNTER=1

# Login first
echo -e "${GREEN}Logging in...${NC}"
curl -s -c $COOKIE_FILE -X POST "$BASE_URL/api/users/auth" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "password123"
  }' > /dev/null

while true; do
    echo -e "\n${BLUE}[$(date +%H:%M:%S)] Iteration $COUNTER${NC}"
    
    # Create a post
    echo -e "  ${YELLOW}→${NC} Creating post..."
    POST_RESPONSE=$(curl -s -b $COOKIE_FILE -X POST "$BASE_URL/api/posts" \
      -H "Content-Type: application/json" \
      -d "{
        \"title\": \"Load Test Post #$COUNTER\",
        \"content\": \"This is a test post created at $(date)\"
      }")
    
    POST_ID=$(echo $POST_RESPONSE | grep -o '"id":"[^"]*' | sed 's/"id":"//' | head -1)
    
    if [ ! -z "$POST_ID" ]; then
        echo -e "  ${GREEN}✓${NC} Post created: $POST_ID"
        
        # Random interaction (LIKE or DISLIKE)
        RANDOM_TYPE=$((RANDOM % 2))
        if [ $RANDOM_TYPE -eq 0 ]; then
            TYPE="LIKE"
        else
            TYPE="DISLIKE"
        fi
        
        echo -e "  ${YELLOW}→${NC} Adding $TYPE interaction..."
        curl -s -b $COOKIE_FILE -X POST "$BASE_URL/api/interactions/$POST_ID" \
          -H "Content-Type: application/json" \
          -d "{\"type\": \"$TYPE\"}" > /dev/null
        
        echo -e "  ${GREEN}✓${NC} Interaction added: $TYPE"
    else
        echo -e "  ${RED}✗${NC} Failed to create post"
    fi
    
    # Fetch posts
    echo -e "  ${YELLOW}→${NC} Fetching posts..."
    curl -s -b $COOKIE_FILE "$BASE_URL/api/posts" > /dev/null
    echo -e "  ${GREEN}✓${NC} Posts fetched"
    
    # Fetch interactions if we have a post
    if [ ! -z "$POST_ID" ]; then
        echo -e "  ${YELLOW}→${NC} Fetching interactions..."
        curl -s -b $COOKIE_FILE "$BASE_URL/api/interactions/$POST_ID" > /dev/null
        echo -e "  ${GREEN}✓${NC} Interactions fetched"
    fi
    
    COUNTER=$((COUNTER + 1))
    
    # Wait between iterations (adjust for desired load)
    sleep 3
done
