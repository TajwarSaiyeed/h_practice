#!/bin/bash

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

clear

echo -e "${MAGENTA}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║    Microservices Architecture - Status Dashboard        ║${NC}"
echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════╝${NC}\n"

# Check Docker Services
echo -e "${BLUE}📦 Docker Services Status:${NC}"
echo -e "${CYAN}─────────────────────────────────────────────────────────────${NC}"
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}" | head -20
echo ""

# Check Service Health
echo -e "${BLUE}🏥 Service Health Checks:${NC}"
echo -e "${CYAN}─────────────────────────────────────────────────────────────${NC}"

# User Service
USER_HEALTH=$(curl -s http://localhost/api/users/health 2>/dev/null)
if echo "$USER_HEALTH" | grep -q "UP"; then
    echo -e "${GREEN}✓ User Service:${NC} Healthy"
else
    echo -e "${RED}✗ User Service:${NC} Down"
fi

# Post Service
POST_HEALTH=$(curl -s http://localhost/api/posts/health 2>/dev/null)
if echo "$POST_HEALTH" | grep -q "UP"; then
    echo -e "${GREEN}✓ Post Service:${NC} Healthy"
else
    echo -e "${RED}✗ Post Service:${NC} Down"
fi

# Interaction Service
INTERACTION_HEALTH=$(curl -s http://localhost/api/interactions/health 2>/dev/null)
if echo "$INTERACTION_HEALTH" | grep -q "UP"; then
    echo -e "${GREEN}✓ Interaction Service:${NC} Healthy"
else
    echo -e "${RED}✗ Interaction Service:${NC} Down"
fi

# Notification Service
NOTIFICATION_HEALTH=$(curl -s http://localhost:3004/health 2>/dev/null)
if echo "$NOTIFICATION_HEALTH" | grep -q "UP"; then
    echo -e "${GREEN}✓ Notification Service:${NC} Healthy"
else
    echo -e "${RED}✗ Notification Service:${NC} Down"
fi

# Prometheus
PROM_HEALTH=$(curl -s http://localhost:9090/-/healthy 2>/dev/null)
if [ ! -z "$PROM_HEALTH" ]; then
    echo -e "${GREEN}✓ Prometheus:${NC} Healthy"
else
    echo -e "${RED}✗ Prometheus:${NC} Down"
fi

# RabbitMQ
RABBIT_HEALTH=$(curl -s -u guest:guest http://localhost:15672/api/overview 2>/dev/null)
if echo "$RABBIT_HEALTH" | grep -q "rabbitmq_version"; then
    echo -e "${GREEN}✓ RabbitMQ:${NC} Healthy"
else
    echo -e "${RED}✗ RabbitMQ:${NC} Down"
fi

echo ""

# Database Status
echo -e "${BLUE}💾 Database Status:${NC}"
echo -e "${CYAN}─────────────────────────────────────────────────────────────${NC}"
docker compose exec -T user-db pg_isready -U postgres 2>/dev/null && echo -e "${GREEN}✓ User DB:${NC} Ready" || echo -e "${RED}✗ User DB:${NC} Not Ready"
docker compose exec -T post-db pg_isready -U postgres 2>/dev/null && echo -e "${GREEN}✓ Post DB:${NC} Ready" || echo -e "${RED}✗ Post DB:${NC} Not Ready"
docker compose exec -T interaction-db pg_isready -U postgres 2>/dev/null && echo -e "${GREEN}✓ Interaction DB:${NC} Ready" || echo -e "${RED}✗ Interaction DB:${NC} Not Ready"
echo ""

# RabbitMQ Queues
echo -e "${BLUE}📬 RabbitMQ Queues:${NC}"
echo -e "${CYAN}─────────────────────────────────────────────────────────────${NC}"
QUEUES=$(curl -s -u guest:guest http://localhost:15672/api/queues 2>/dev/null)
if [ ! -z "$QUEUES" ]; then
    echo "$QUEUES" | grep -o '"name":"[^"]*"' | sed 's/"name":"//g' | sed 's/"//g' | while read queue; do
        MESSAGES=$(echo "$QUEUES" | grep -A 20 "\"name\":\"$queue\"" | grep -o '"messages":[0-9]*' | head -1 | cut -d':' -f2)
        if [ ! -z "$MESSAGES" ]; then
            echo -e "  ${YELLOW}•${NC} $queue: ${GREEN}$MESSAGES${NC} messages"
        fi
    done
else
    echo -e "${RED}  Unable to fetch queue information${NC}"
fi
echo ""

# Recent Activity
echo -e "${BLUE}📊 Recent Activity:${NC}"
echo -e "${CYAN}─────────────────────────────────────────────────────────────${NC}"
echo -e "${YELLOW}Last 5 Notification Service Events:${NC}"
docker compose logs notification-service 2>&1 | grep "\[NOTIFICATION\]" | tail -5 | sed 's/notification-service  | /  /g'
echo ""

# Monitoring URLs
echo -e "${BLUE}🔗 Monitoring Dashboards:${NC}"
echo -e "${CYAN}─────────────────────────────────────────────────────────────${NC}"
echo -e "  ${GREEN}Grafana:${NC}        http://localhost:3000 (admin/admin)"
echo -e "  ${GREEN}Prometheus:${NC}     http://localhost:9090"
echo -e "  ${GREEN}RabbitMQ:${NC}       http://localhost:15672 (guest/guest)"
echo -e "  ${GREEN}Kibana:${NC}         http://localhost:5601"
echo -e "  ${GREEN}Elasticsearch:${NC}  http://localhost:9200"
echo ""

# Resource Usage
echo -e "${BLUE}💻 Resource Usage:${NC}"
echo -e "${CYAN}─────────────────────────────────────────────────────────────${NC}"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" | head -10
echo ""

# Quick Actions
echo -e "${BLUE}🚀 Quick Actions:${NC}"
echo -e "${CYAN}─────────────────────────────────────────────────────────────${NC}"
echo -e "  ${YELLOW}View logs:${NC}          docker compose logs -f [service-name]"
echo -e "  ${YELLOW}Run API test:${NC}       bash test_api.sh"
echo -e "  ${YELLOW}Restart service:${NC}    docker compose restart [service-name]"
echo -e "  ${YELLOW}Stop all:${NC}           docker compose down"
echo -e ""

echo -e "${MAGENTA}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║              System is operational! 🎉                   ║${NC}"
echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════╝${NC}"
