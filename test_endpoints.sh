#!/bin/bash

# Configuration
BASE_URL="http://localhost/api"
USER_LOG="user-log.txt"
POST_LOG="post-log.txt"
COOKIE_JAR="cookies.txt"

# Reset Logs
echo "--- User Service Test Logs ---" > "$USER_LOG"
echo "--- Post Service Test Logs ---" > "$POST_LOG"
echo "Logs cleared."

# Generate Random User
RANDOM_ID=$RANDOM
EMAIL="user${RANDOM_ID}@example.com"
PASSWORD="password123"
NAME="User ${RANDOM_ID}"

echo "Starting Tests with User: $EMAIL"

# ==========================================
# USER SERVICE TESTS
# ==========================================

echo "1. Register User"
echo "Request: POST /api/users/register" >> "$USER_LOG"
REGISTER_RES=$(curl -s -c "$COOKIE_JAR" -X POST "$BASE_URL/users/register" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"$NAME\",\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")
echo "Response: $REGISTER_RES" >> "$USER_LOG"
echo "------------------------------------------------" >> "$USER_LOG"
echo "User Registered."

echo "2. Login User"
echo "Request: POST /api/users/auth" >> "$USER_LOG"
LOGIN_RES=$(curl -s -c "$COOKIE_JAR" -X POST "$BASE_URL/users/auth" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}")
echo "Response: $LOGIN_RES" >> "$USER_LOG"
echo "------------------------------------------------" >> "$USER_LOG"
echo "User Logged In."

echo "3. Get User Profile (Protected)"
echo "Request: GET /api/users/profile" >> "$USER_LOG"
PROFILE_RES=$(curl -s -b "$COOKIE_JAR" "$BASE_URL/users/profile")
echo "Response: $PROFILE_RES" >> "$USER_LOG"
echo "------------------------------------------------" >> "$USER_LOG"
echo "Profile Retrieved."

# ==========================================
# POST SERVICE TESTS
# ==========================================

echo "4. Create Post (Protected)"
TITLE="My First Post $RANDOM_ID"
CONTENT="This is the content of the post."
echo "Request: POST /api/posts" >> "$POST_LOG"
CREATE_POST_RES=$(curl -s -b "$COOKIE_JAR" -X POST "$BASE_URL/posts" \
  -H "Content-Type: application/json" \
  -d "{\"title\":\"$TITLE\",\"content\":\"$CONTENT\"}")
echo "Response: $CREATE_POST_RES" >> "$POST_LOG"
echo "------------------------------------------------" >> "$POST_LOG"

# Extract Post ID using jq
POST_ID=$(echo "$CREATE_POST_RES" | jq -r '.id')
echo "Post Created with ID: $POST_ID"

echo "5. Get All Posts (Public)"
echo "Request: GET /api/posts" >> "$POST_LOG"
GET_POSTS_RES=$(curl -s "$BASE_URL/posts")
echo "Response: $GET_POSTS_RES" >> "$POST_LOG"
echo "------------------------------------------------" >> "$POST_LOG"
echo "All Posts Retrieved."

if [ "$POST_ID" != "null" ] && [ -n "$POST_ID" ]; then
    echo "6. Get Single Post"
    echo "Request: GET /api/posts/$POST_ID" >> "$POST_LOG"
    GET_POST_RES=$(curl -s "$BASE_URL/posts/$POST_ID")
    echo "Response: $GET_POST_RES" >> "$POST_LOG"
    echo "------------------------------------------------" >> "$POST_LOG"
    echo "Single Post Retrieved."

    echo "7. Update Post (Protected)"
    echo "Request: PUT /api/posts/$POST_ID" >> "$POST_LOG"
    UPDATE_RES=$(curl -s -b "$COOKIE_JAR" -X PUT "$BASE_URL/posts/$POST_ID" \
      -H "Content-Type: application/json" \
      -d "{\"title\":\"Updated Title\",\"content\":\"Updated Content\"}")
    echo "Response: $UPDATE_RES" >> "$POST_LOG"
    echo "------------------------------------------------" >> "$POST_LOG"
    echo "Post Updated."

    # ==========================================
    # INTERACTION SERVICE TESTS
    # ==========================================
    
    echo "8. Like Post (Protected)"
    echo "Request: POST /api/interactions/$POST_ID" >> "$POST_LOG"
    LIKE_RES=$(curl -s -b "$COOKIE_JAR" -X POST "$BASE_URL/interactions/$POST_ID" \
      -H "Content-Type: application/json" \
      -d "{\"type\":\"LIKE\"}")
    echo "Response: $LIKE_RES" >> "$POST_LOG"
    echo "------------------------------------------------" >> "$POST_LOG"
    echo "Post Liked."

    echo "9. Get Interactions"
    echo "Request: GET /api/interactions/$POST_ID" >> "$POST_LOG"
    INTERACTION_RES=$(curl -s "$BASE_URL/interactions/$POST_ID")
    echo "Response: $INTERACTION_RES" >> "$POST_LOG"
    echo "------------------------------------------------" >> "$POST_LOG"
    echo "Interactions Retrieved: $INTERACTION_RES"

    echo "10. Delete Post (Protected)"
    echo "Request: DELETE /api/posts/$POST_ID" >> "$POST_LOG"
    DELETE_RES=$(curl -s -b "$COOKIE_JAR" -X DELETE "$BASE_URL/posts/$POST_ID")
    echo "Response: $DELETE_RES" >> "$POST_LOG"
    echo "------------------------------------------------" >> "$POST_LOG"
    echo "Post Deleted."
else
    echo "Skipping Update/Delete/Interaction tests as Post creation failed."
fi

echo "Tests Completed. Check $USER_LOG and $POST_LOG for details."
rm "$COOKIE_JAR"
