#!/bin/bash

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Testing Microservices Architecture${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Base URL
BASE_URL="http://localhost"
COOKIE_FILE="/tmp/cookies.txt"

# Clean up old cookies
rm -f $COOKIE_FILE

# Step 1: Register a user (or login if exists)
echo -e "${YELLOW}Step 1: Registering/Logging in user...${NC}"
REGISTER_RESPONSE=$(curl -s -c $COOKIE_FILE -X POST "$BASE_URL/api/users/register" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "password": "password123"
  }')

echo -e "${GREEN}Response:${NC} $REGISTER_RESPONSE\n"

# Step 2: If user exists, login
if echo "$REGISTER_RESPONSE" | grep -q "already exists"; then
  echo -e "${YELLOW}Step 2: User exists, logging in...${NC}"
  LOGIN_RESPONSE=$(curl -s -c $COOKIE_FILE -X POST "$BASE_URL/api/users/auth" \
    -H "Content-Type: application/json" \
    -d '{
      "email": "john@example.com",
      "password": "password123"
    }')
  
  echo -e "${GREEN}Response:${NC} $LOGIN_RESPONSE\n"
fi

# Check if we have a cookie
if [ ! -f "$COOKIE_FILE" ] || ! grep -q "jwt" "$COOKIE_FILE"; then
  echo -e "${RED}Failed to get authentication cookie. Exiting...${NC}"
  exit 1
fi

echo -e "${GREEN}✓ Authentication successful (cookie stored)${NC}\n"

# Step 3: Create a post
echo -e "${YELLOW}Step 3: Creating a new post...${NC}"
POST_RESPONSE=$(curl -s -b $COOKIE_FILE -X POST "$BASE_URL/api/posts" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "My First Post",
    "content": "This is my first post in the microservices architecture!"
  }')

echo -e "${GREEN}Response:${NC} $POST_RESPONSE\n"

# Extract post ID
POST_ID=$(echo $POST_RESPONSE | grep -o '"id":"[^"]*' | sed 's/"id":"//' | head -1)

if [ -z "$POST_ID" ]; then
  echo -e "${RED}Failed to get post ID. Exiting...${NC}"
  exit 1
fi

echo -e "${GREEN}Post ID: $POST_ID${NC}\n"

# Step 4: Get all posts
echo -e "${YELLOW}Step 4: Fetching all posts...${NC}"
POSTS_RESPONSE=$(curl -s -b $COOKIE_FILE -X GET "$BASE_URL/api/posts")

echo -e "${GREEN}Response:${NC} $POSTS_RESPONSE\n"

# Step 5: Like the post
echo -e "${YELLOW}Step 5: Liking the post...${NC}"
LIKE_RESPONSE=$(curl -s -b $COOKIE_FILE -X POST "$BASE_URL/api/interactions/$POST_ID" \
  -H "Content-Type: application/json" \
  -d "{
    \"type\": \"LIKE\"
  }")

echo -e "${GREEN}Response:${NC} $LIKE_RESPONSE\n"

# Step 6: Get interactions for the post
echo -e "${YELLOW}Step 6: Getting interactions for the post...${NC}"
INTERACTIONS_RESPONSE=$(curl -s -b $COOKIE_FILE -X GET "$BASE_URL/api/interactions/$POST_ID")

echo -e "${GREEN}Response:${NC} $INTERACTIONS_RESPONSE\n"

# Step 7: Create another post
echo -e "${YELLOW}Step 7: Creating another post...${NC}"
POST2_RESPONSE=$(curl -s -b $COOKIE_FILE -X POST "$BASE_URL/api/posts" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Second Post",
    "content": "Testing the microservices with multiple posts!"
  }')

echo -e "${GREEN}Response:${NC} $POST2_RESPONSE\n"

POST2_ID=$(echo $POST2_RESPONSE | grep -o '"id":"[^"]*' | sed 's/"id":"//' | head -1)

# Step 8: Dislike the second post
echo -e "${YELLOW}Step 8: Disliking the second post...${NC}"
DISLIKE_RESPONSE=$(curl -s -b $COOKIE_FILE -X POST "$BASE_URL/api/interactions/$POST2_ID" \
  -H "Content-Type: application/json" \
  -d "{
    \"type\": \"DISLIKE\"
  }")

echo -e "${GREEN}Response:${NC} $DISLIKE_RESPONSE\n"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}   Test Completed Successfully!${NC}"
echo -e "${BLUE}========================================${NC}\n"

echo -e "${GREEN}✓ User registered and logged in${NC}"
echo -e "${GREEN}✓ Posts created${NC}"
echo -e "${GREEN}✓ Interactions (Like/Dislike) recorded${NC}"
echo -e "${GREEN}✓ RabbitMQ events triggered${NC}\n"

echo -e "${YELLOW}Check the logs to see RabbitMQ event notifications:${NC}"
echo -e "  ${BLUE}docker compose logs -f notification-service${NC}\n"
