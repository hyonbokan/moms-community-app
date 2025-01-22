# social-media-project

```scss
                   ┌─────────────────────────┐
                   │  Mobile/Web Client      │
                   │ (iOS/Android/React etc.)│
                   └─────────┬───────────────┘
                             │  (HTTPS & WebSocket)
                             ▼
                  ┌─────────────────────────┐
                  │ AWS Application/Network │
                  │      Load Balancer      │
                  └─────────┬───────────────┘
                            ▼ (Routes to ECS tasks)
          ┌─────────────────────────────────────────────────┐
          │                 AWS ECS (Fargate)              │
          │  (Container Orchestrator for Spring Boot Apps) │
          │─────────────────────────────────────────────────│
          │   ┌─────────────────────┐   ┌──────────────────┐
          │   │ Auth Service        │   │  NotificationSvc │
          │   │ (JWT or Cognito)    │   │ (Push/Email)     │
          │   └─────────────────────┘   └──────────────────┘
          │   ┌─────────────────────┐   ┌──────────────────┐
          │   │ User Service        │   │   MessagingSvc   │
          │   │ (Profiles, Follows) │   │ (WebSocket Chat) │
          │   └─────────────────────┘   └──────────────────┘
          │   ┌──────────────────────────┐
          │   │ Post/Channel Service    │
          │   │ (Images, Channels)      │
          │   └──────────────────────────┘
          └─────────────────────────────────────────────────┘

                     ▼           ▼
   ┌────────────────────────┐   ┌─────────────────────────┐
   │   Amazon RDS (Postgre) │   │    Amazon S3 (Images)   │
   └────────────────────────┘   └─────────────────────────┘

        Optional / Additional:
   ┌─────────────────────────┐   ┌─────────────────────────┐
   │Amazon ElastiCache Redis │   │  Amazon Cognito (Auth)  │
   └─────────────────────────┘   └─────────────────────────┘

```

# Legend

- **Client**: Mobile or web application calling the backend via HTTPS and optionally WebSocket connections.
- **ALB/NLB**: AWS Load Balancer distributing incoming requests/WebSocket connections to ECS tasks.
- **ECS**: Docker containers running each Spring Boot microservice (Auth, User, Post, Messaging, Notification).
- **RDS**: PostgreSQL database for structured data (users, posts, channels).
- **S3**: Object storage for uploaded images, attachments.
- **Cognito**: Could replace or supplement the custom Auth Service.
- **ElastiCache (Redis)**: Optional caching for session data or frequently accessed queries.

---

## Component Responsibilities

### **Auth Service**
- Handles user sign-up, login.
- Issues JWT tokens upon successful authentication.
- Alternatively, you can rely on **Amazon Cognito** to offload user pool management and token issuing.

### **User Service**
- Stores user profile info (name, bio, etc.) and relationships (follows/friends).
- Provides endpoints like `GET /users/{id}`, `POST /users/follow`.

### **Post/Channel Service**
- Manages user posts (text or images) and organizes them into channels (e.g., *preemies, preschools*, etc.).
- Image upload goes to **Amazon S3**, storing only the S3 URL in the database.
- Could also handle **feed or timeline generation** if needed.

### **Messaging Service (WebSocket)**
- Real-time direct messages or group chats.
- Maintains **WebSocket** connections for each online user.
- For scale, **ephemeral chat states** might be stored in **Redis** or a **message broker**.

### **Notification Service**
- Listens to events like `"User X posted"` or `"New direct message"`.
- Sends **push notifications** (Apple/Google push), **in-app notifications**, or **email**.
- Could be triggered by **Amazon SNS (Simple Notification Service)** or an internal queue.

---

## AWS Services & Deployment

### **1. ECS (Fargate)**
- Each Spring Boot service is **packaged as a Docker image** and deployed to **AWS Elastic Container Registry (ECR)**.
- **Fargate** provides serverless container hosting—no need to manage EC2 instances.
- You define **Task Definitions** for each microservice, set **CPU/memory limits**, and run them in a **cluster**.
- ECS will handle **auto-scaling** if traffic increases.

### **2. Load Balancer**
- An **Application Load Balancer (ALB)** can route **HTTP requests** to the correct service:
  - `/auth/*` → Auth Service
  - `/posts/*` → Post Service
- **WebSocket Support**:
  - ALB supports sticky sessions for WebSocket connections.
  - **Network Load Balancer (NLB)** can be used for raw TCP/WebSocket pass-through.

### **3. Database & Storage**
#### **Amazon RDS (PostgreSQL)**
- Stores **relational data** (users, posts, channel membership).
- Provides **high availability** with **Multi-AZ replication**.

#### **Amazon S3**
- Stores **images and attachments**.
- The **Post Service** generates a **presigned S3 URL** so the client can **upload directly**.

#### **ElastiCache (Redis) (Optional)**
- Stores **sessions, caching user profiles**, or **ephemeral chat states**.
- In a **real-time messaging scenario**, Redis helps with **horizontal scaling**.

### **4. AWS Cognito (Optional Replacement for Auth)**
- Instead of a custom **Auth Service**, you can use **Cognito** for:
  - User registration, login flows.
  - JWT token issuing.
- Other microservices **trust Cognito tokens** for authentication.

---

## WebSocket Implementation
**Scenario: Direct messaging or real-time notifications.**

- The **Messaging Service** is a **Spring Boot application** using **Spring WebSocket or Netty**.
- For high scale, **active connection info** is stored in **Redis** or a **shared database**.
- The **mobile/web client** connects via WebSocket: **wss://{ALB_domain}/messaging**
- The **Messaging Service** fires events to **Notification Service** (push notifications if the user is offline).

---

## Event-Driven Notifications & Future Expansion

### **Event bus:**
- When a **new post** or **direct message** arrives:
- The service **publishes an event** to **Amazon SNS** or **EventBridge**.
- The **Notification Service** subscribes to these events and **triggers notifications**.
- This **decouples new features** (e.g., analytics, recommendations) from **existing services**.

---

## Scaling & Observability

### **Auto Scaling**
- ECS tasks scale **automatically** based on:
- **CPU/memory usage**
- **Custom CloudWatch metrics** (e.g., queue length if using SQS).

### **Monitoring**
- Use **Amazon CloudWatch** for **logs and metrics**.
- Use **AWS X-Ray or Jaeger** for **distributed tracing**.

### **CI/CD**
- Use **AWS CodePipeline** or **GitHub Actions** for:
- **Building Docker images**.
- **Deploying to ECS**.

---

## Putting It All Together (Step-by-Step Flow)

### **1. User logs in:**
- Mobile app calls `POST /auth/login` → ALB → **Auth Service**.
- Auth Service validates credentials (or delegates to Cognito) and issues a **JWT token**.

### **2. User posts an image:**
- The **client** obtains a **presigned S3 URL** from the **Post Service**.
- Uploads the image to **S3**.
- **Post Service** records metadata in **RDS** (storing the S3 URL).
- Publishes a `"NewPostEvent"` to **SNS or EventBridge**.

### **3. Notification for followers:**
- **Notification Service** sees the event, looks up the **poster’s followers**, and **sends notifications**.

### **4. Direct message:**
- **User A** opens a WebSocket connection: wss://.../messaging
  - **User A** sends a message to **User B**.
- **Messaging Service** routes it to **B’s WebSocket** (if online).
- If **B is offline**, it **publishes an event** to **trigger push notifications**.

---

### **Final Thoughts**
This architecture is **modular and scalable**:
- Each **Spring Boot microservice** runs on **ECS**.
- Data is stored in **RDS** and images in **S3**.
- Real-time communication is handled via **WebSockets**.
- By **leveraging AWS managed services** (ALB, RDS, S3, Cognito, ElastiCache), you can **focus on business logic** instead of managing infrastructure.


