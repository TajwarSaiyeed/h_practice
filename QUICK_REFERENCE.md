# 🎯 Quick Reference Card

## 🚀 Start/Stop Commands

```bash
# Start everything
docker compose up -d

# Stop everything
docker compose down

# Restart a service
docker compose restart [service-name]

# View logs
docker compose logs -f [service-name]
```

## 📊 Monitoring URLs

| Tool | URL | Login |
|------|-----|-------|
| **Grafana** | http://localhost:3000 | admin / admin |
| **RabbitMQ** | http://localhost:15672 | guest / guest |
| **Prometheus** | http://localhost:9090 | - |
| **Kibana** | http://localhost:5601 | - |
| **Elasticsearch** | http://localhost:9200 | - |

## 🧪 Test Scripts

```bash
# Full API test
bash test_api.sh

# System status check
bash status_check.sh

# Generate continuous load
bash load_generator.sh
```

## 🔍 Useful Prometheus Queries

```promql
# Request rate (requests/sec)
rate(http_request_duration_seconds_count[5m])

# Average response time (ms)
rate(http_request_duration_seconds_sum[5m]) / rate(http_request_duration_seconds_count[5m]) * 1000

# Memory usage (MB)
nodejs_heap_size_used_bytes / 1024 / 1024

# CPU usage (%)
rate(process_cpu_seconds_total[5m]) * 100
```

## 📝 API Endpoints

```bash
# Register user
POST /api/users/register
{"name":"...", "email":"...", "password":"..."}

# Login
POST /api/users/auth
{"email":"...", "password":"..."}

# Create post
POST /api/posts
{"title":"...", "content":"..."}

# Like/Dislike post
POST /api/interactions/:postId
{"type":"LIKE"} or {"type":"DISLIKE"}

# Get posts
GET /api/posts

# Get interactions
GET /api/interactions/:postId
```

## 🔥 Watch Live Activity

```bash
# Terminal 1: Watch notifications
docker compose logs -f notification-service

# Terminal 2: Generate activity
bash load_generator.sh

# Browser 1: RabbitMQ Dashboard
http://localhost:15672 → Queues

# Browser 2: Grafana
http://localhost:3000 → Create dashboard
```

## 🐛 Debugging

```bash
# Check container status
docker compose ps

# Service logs
docker compose logs [service-name]

# Enter container
docker compose exec [service-name] sh

# Check database
docker compose exec user-db psql -U postgres -d user_db

# Test service health
curl http://localhost/api/posts/health
```

## 📦 Services Overview

| Service | Port | Database Port | Purpose |
|---------|------|---------------|---------|
| Gateway | 80 | - | API Gateway |
| User Service | 3001 | 5432 | Auth |
| Post Service | 3002 | 5433 | Posts |
| Interaction Service | 3003 | 5434 | Likes/Dislikes |
| Notification Service | 3004 | - | Events |
| RabbitMQ | 5672, 15672 | - | Message Queue |
| Prometheus | 9090 | - | Metrics |
| Grafana | 3000 | - | Dashboards |

## ⚡ Quick Tips

- **Grafana:** Refresh interval → Set to 5s for live updates
- **RabbitMQ:** Queues tab shows message flow
- **Prometheus:** Graph tab for visualizations
- **Load Test:** Run for 30+ seconds to see nice graphs
- **Logs:** Use `-f` flag to follow (tail -f style)

## 🎨 Create Grafana Dashboard

1. Open http://localhost:3000
2. Click "+" → "Dashboard"
3. "Add new panel"
4. Query: `rate(http_request_duration_seconds_count[5m])`
5. Panel title: "Request Rate"
6. Visualization: Graph
7. Save dashboard

---

**Happy Monitoring! 🚀**
