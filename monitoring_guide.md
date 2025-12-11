# 🎯 Monitoring & Visualization Guide

## 📊 Available Dashboards

### 1. **Grafana** - Main Monitoring Dashboard
- **URL:** http://localhost:3000
- **Username:** `admin`
- **Password:** `admin`
- **Features:**
  - Real-time metrics visualization
  - Pre-configured Prometheus datasource
  - Custom dashboards for service monitoring
  - CPU, Memory, Request rates, Response times

**What to do:**
1. Open http://localhost:3000 in your browser
2. Login with admin/admin (change password if prompted)
3. Go to "Dashboards" to see metrics
4. Create custom dashboards by adding panels

---

### 2. **Prometheus** - Metrics Collection
- **URL:** http://localhost:9090
- **Features:**
  - Query metrics from all services
  - Real-time data exploration
  - Service health monitoring

**Sample Queries to Try:**
```promql
# Request rate for user-service
rate(http_request_duration_seconds_count{service="user-service"}[5m])

# Memory usage
nodejs_heap_size_used_bytes

# Active requests
http_requests_in_progress
```

**What to do:**
1. Open http://localhost:9090
2. Click "Graph" tab
3. Try the sample queries above
4. Explore the "Status" > "Targets" to see all scraped services

---

### 3. **RabbitMQ Management** - Message Queue Dashboard
- **URL:** http://localhost:15672
- **Username:** `guest`
- **Password:** `guest`
- **Features:**
  - Queue monitoring
  - Message rates
  - Consumer connections
  - Event flow visualization

**What to do:**
1. Open http://localhost:15672
2. Login with guest/guest
3. Check "Queues" tab to see `post_events` and `interaction_events`
4. View message rates after running test_api.sh

---

### 4. **Kibana** - Log Analytics
- **URL:** http://localhost:5601
- **Features:**
  - Elasticsearch log visualization
  - Search and filter logs
  - Create custom visualizations

**What to do:**
1. Open http://localhost:5601
2. Wait for Kibana to initialize (may take 1-2 minutes)
3. Create an index pattern for logs
4. Explore logs from all services

---

### 5. **Elasticsearch** - Log Storage
- **URL:** http://localhost:9200
- **API Endpoint:** Direct queries
- **Features:**
  - Full-text search
  - Log aggregation
  - RESTful API

**Quick Test:**
```bash
curl http://localhost:9200/_cluster/health?pretty
```

---

## 🧪 Testing & Generating Activity

### Run API Tests
```bash
bash test_api.sh
```
This script will:
- Register a user
- Create posts
- Add likes/dislikes
- Trigger RabbitMQ events
- Generate metrics for monitoring

### Watch Logs in Real-time
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f user-service
docker compose logs -f notification-service
docker compose logs -f post-service
docker compose logs -f interaction-service

# Multiple services
docker compose logs -f user-service post-service
```

### Check Service Health
```bash
# User Service
curl http://localhost/api/users/health

# Post Service  
curl http://localhost/api/posts/health

# Interaction Service
curl http://localhost/api/interactions/health

# Notification Service
curl http://localhost:3004/health
```

### View Metrics Endpoints
```bash
# User Service Metrics
curl http://user-service:3001/metrics  # From within Docker network
# or via gateway
curl http://localhost/metrics/user

# Post Service Metrics
curl http://localhost/metrics/post

# Interaction Service Metrics
curl http://localhost/metrics/interaction
```

---

## 📈 What to Monitor

### 1. **Service Health**
- Check all services are running: `docker compose ps`
- Verify all show "Up" status

### 2. **RabbitMQ Events**
- Open RabbitMQ dashboard
- Watch queues fill when creating posts/interactions
- See consumers processing messages

### 3. **Prometheus Metrics**
- Request rates
- Response times
- Error rates
- System resources (CPU, Memory)

### 4. **Grafana Visualizations**
- Create dashboards for each service
- Monitor trends over time
- Set up alerts

### 5. **Application Logs**
- Watch notification-service for event processing
- Check for errors in service logs
- Monitor RabbitMQ connection status

---

## 🎨 Creating a Custom Grafana Dashboard

1. Login to Grafana (http://localhost:3000)
2. Click "+" → "Dashboard" → "Add new panel"
3. Select "Prometheus" as datasource
4. Use queries like:
   - `rate(http_request_duration_seconds_count[5m])`
   - `nodejs_heap_size_used_bytes`
   - `process_cpu_seconds_total`
5. Choose visualization type (Graph, Stat, Gauge, etc.)
6. Save the dashboard

---

## 🔍 Troubleshooting

### Services not starting?
```bash
docker compose down
docker compose up -d
docker compose logs -f
```

### Database connection issues?
```bash
# Check database containers
docker compose ps user-db post-db interaction-db

# Check logs
docker compose logs user-db
```

### RabbitMQ not connecting?
```bash
# Restart RabbitMQ
docker compose restart rabbitmq

# Check RabbitMQ logs
docker compose logs rabbitmq
```

---

## 📦 Quick Commands Reference

```bash
# Start all services
docker compose up -d

# Stop all services
docker compose down

# Restart a specific service
docker compose restart user-service

# View logs
docker compose logs -f [service-name]

# Check status
docker compose ps

# Run tests
bash test_api.sh

# Scale a service
docker compose up -d --scale post-service=3
```

---

## 🎯 Next Steps

1. ✅ Open all dashboards in your browser
2. ✅ Run `bash test_api.sh` to generate activity
3. ✅ Watch RabbitMQ queues fill up
4. ✅ See metrics in Prometheus
5. ✅ Create custom Grafana dashboards
6. ✅ Monitor logs in real-time
7. ✅ Test different API endpoints

**Happy Monitoring! 🚀**
