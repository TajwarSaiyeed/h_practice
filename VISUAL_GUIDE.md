# 🎯 Quick Start Guide - Visual Monitoring

## ✅ System Status

Your microservices architecture is **FULLY OPERATIONAL**! 🎉

All services are running:
- ✅ User Service (Authentication)
- ✅ Post Service (Content Management)
- ✅ Interaction Service (Likes/Dislikes)
- ✅ Notification Service (Event Processing)
- ✅ 3 PostgreSQL Databases
- ✅ RabbitMQ (Message Queue)
- ✅ Prometheus (Metrics)
- ✅ Grafana (Dashboards)
- ✅ Kibana + Elasticsearch (Logs)
- ✅ Loki + Promtail (Log Aggregation)
- ✅ NGINX Gateway

---

## 🎨 Visual Dashboards (ALREADY OPEN)

### 1. **Grafana** - http://localhost:3000
**Login:** admin / admin

**What you'll see:**
- Real-time service metrics
- Request rates and response times
- CPU and memory usage graphs
- Error rates
- Custom dashboards

**How to use:**
1. Login with admin/admin
2. Click "Dashboards" → "Browse"
3. Create a new dashboard
4. Add panels with Prometheus queries:
   ```
   rate(http_request_duration_seconds_count[5m])
   nodejs_heap_size_used_bytes
   process_cpu_seconds_total
   ```

### 2. **RabbitMQ Management** - http://localhost:15672
**Login:** guest / guest

**What you'll see:**
- Message queues: `post_events` and `interaction_events`
- Message flow rates
- Consumer connections
- Queue depths

**What to watch:**
- When you create a post → messages in `post_events` queue
- When you like/dislike → messages in `interaction_events` queue
- Notification service consuming these messages

### 3. **Prometheus** - http://localhost:9090

**What you'll see:**
- Metrics explorer
- All service metrics
- Query builder

**Try these queries:**
```promql
# Request rate
rate(http_request_duration_seconds_count[5m])

# Memory usage
nodejs_heap_size_used_bytes

# HTTP request duration
http_request_duration_seconds_sum

# Requests in progress
http_requests_in_progress
```

---

## 🧪 Generate Visual Activity

### Run API Tests (One-time)
```bash
bash test_api.sh
```
**This will:**
- Create a user
- Create 2 posts
- Add 1 like and 1 dislike
- Trigger RabbitMQ events
- Show in all dashboards

### Generate Continuous Load (For Monitoring)
```bash
bash load_generator.sh
```
**This will:**
- Continuously create posts
- Add random likes/dislikes
- Generate metrics for dashboards
- Fill Prometheus graphs
- Create RabbitMQ activity

**Leave this running while you explore dashboards!**

---

## 👀 What to Watch in Real-time

### 1. **RabbitMQ Dashboard**
- Go to http://localhost:15672
- Click "Queues" tab
- Watch message counts change as you run tests
- See messages being consumed in real-time

### 2. **Notification Service Logs**
```bash
docker compose logs -f notification-service
```
**You'll see:**
```
[NOTIFICATION] New Post Created by User xxx: "Post Title"
[NOTIFICATION] User xxx LIKED post yyy
[NOTIFICATION] User xxx DISLIKED post zzz
```

### 3. **Prometheus Metrics**
- Open http://localhost:9090
- Go to "Graph" tab
- Enter: `rate(http_request_duration_seconds_count[1m])`
- Click "Execute"
- Switch to "Graph" view
- Run `load_generator.sh` in another terminal
- **Watch the graph climb in real-time!**

### 4. **Grafana Real-time Dashboard**
- Open http://localhost:3000
- Create a new dashboard
- Add a graph panel
- Query: `rate(http_request_duration_seconds_count[1m])`
- Set auto-refresh to 5 seconds
- Run load generator
- **Watch beautiful live graphs!**

---

## 📊 Status Dashboard

Run anytime to see system status:
```bash
bash status_check.sh
```

**Shows:**
- ✅ All services status
- 💚 Health checks
- 💾 Database status
- 📬 RabbitMQ queue depths
- 📊 Recent events
- 💻 Resource usage
- 🔗 All dashboard URLs

---

## 🎬 Demo Flow (Best Visual Experience)

### Step 1: Open All Dashboards
1. Grafana: http://localhost:3000 (admin/admin)
2. RabbitMQ: http://localhost:15672 (guest/guest)
3. Prometheus: http://localhost:9090

### Step 2: Start Monitoring
In one terminal:
```bash
docker compose logs -f notification-service
```

### Step 3: Run Load Generator
In another terminal:
```bash
bash load_generator.sh
```

### Step 4: Watch the Magic! ✨

**In RabbitMQ Dashboard:**
- Click "Queues" tab
- Watch message rates graph moving
- See messages being published and consumed

**In Notification Logs:**
- See events flowing in real-time
- Every 3 seconds new notifications appear

**In Prometheus:**
- Query: `rate(http_request_duration_seconds_count[1m])`
- Click "Execute" every few seconds
- Watch the metrics increase

**In Grafana:**
- Create a dashboard with the same query
- Set refresh to 5s
- Beautiful live graphs!

---

## 📈 Sample Prometheus Queries for Visualization

### Request Rate (Requests per second)
```promql
rate(http_request_duration_seconds_count[5m])
```

### Average Response Time
```promql
rate(http_request_duration_seconds_sum[5m]) / rate(http_request_duration_seconds_count[5m])
```

### Memory Usage
```promql
nodejs_heap_size_used_bytes / 1024 / 1024
```

### CPU Usage
```promql
rate(process_cpu_seconds_total[5m]) * 100
```

### Active Requests
```promql
http_requests_in_progress
```

---

## 🎯 Testing Individual Services

### Create a Post
```bash
curl -b /tmp/cookies.txt -X POST http://localhost/api/posts \
  -H "Content-Type: application/json" \
  -d '{"title":"Test","content":"Hello World"}'
```

### Like a Post
```bash
curl -b /tmp/cookies.txt -X POST http://localhost/api/interactions/POST_ID \
  -H "Content-Type: application/json" \
  -d '{"type":"LIKE"}'
```

### Get All Posts
```bash
curl -b /tmp/cookies.txt http://localhost/api/posts
```

---

## 🔥 Best Monitoring Experience

1. **Arrange Your Windows:**
   - Left: RabbitMQ Dashboard
   - Center: Grafana
   - Right: Terminal with notification logs

2. **Run Load Generator:**
   ```bash
   bash load_generator.sh
   ```

3. **Watch Everything Happen:**
   - RabbitMQ: Messages flowing
   - Grafana: Graphs climbing
   - Logs: Events streaming
   - Prometheus: Metrics increasing

---

## 📦 What Each Service Does

| Service | Port | Purpose | Visual Output |
|---------|------|---------|--------------|
| User Service | 3001 | Authentication | Login events |
| Post Service | 3002 | Manage posts | Post creation events |
| Interaction Service | 3003 | Likes/Dislikes | Interaction events |
| Notification Service | 3004 | Event processing | Console notifications |
| RabbitMQ | 15672 | Message queue | Queue dashboard |
| Prometheus | 9090 | Metrics collection | Metric queries |
| Grafana | 3000 | Visualization | Live dashboards |
| Kibana | 5601 | Log analysis | Log search |

---

## 🎊 You Now Have:

✅ A fully functional microservices architecture  
✅ Real-time monitoring with Grafana  
✅ Message queue visualization with RabbitMQ  
✅ Metrics collection with Prometheus  
✅ Log aggregation with ELK stack  
✅ Event-driven architecture with RabbitMQ  
✅ API Gateway with NGINX  
✅ Database per service pattern  
✅ Test scripts for generating activity  
✅ Beautiful visual dashboards  

## 🚀 Have Fun Exploring!

Run `bash status_check.sh` anytime to see the current status!
