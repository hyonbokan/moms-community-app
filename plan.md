1. Project Overview
Working Title: “Moms Community App (MCA)”—a social platform enabling moms to share posts (images/text), follow topics (channels), and communicate via direct messaging.

Objectives
Create a mobile-focused social platform (though a web client may exist).
Provide secure user authentication.
Allow users to post text and images, organize them in channels.
Implement real-time messaging (WebSocket).
Send notifications (push, in-app) about new posts, replies, or direct messages.
Leverage AWS for infrastructure (containers, DB, storage).
2. Project Scope & Feature Set
User Onboarding & Profiles

Sign up/login with email & password (or third-party OAuth, if time permits).
Basic profile info: name, photo, location, child’s age, short bio.
Topics/Channels

Each post belongs to one or more “channels” (e.g., “preemies,” “preschools”).
Users can discover or follow channels that interest them.
Posts & Image Uploads

Users can create text-based posts or attach images.
Images are stored in Amazon S3 with a reference in the database.
Optionally, users can “like” or comment on posts (if time allows).
Direct Messaging (WebSocket)

Real-time chat between two (or more) users.
WebSocket connections handled via a Messaging Service in Spring Boot.
Store chat history so it can be retrieved upon reconnection.
Notifications

Send push notifications (or in-app) for events like new direct messages, replies to a post, etc.
Possibly rely on AWS SNS or a custom Notification Service for sending them.
Security & Auth

JWT-based authentication.
Each microservice validates the JWT.
Optionally integrate AWS Cognito if desired to manage user pools.
AWS Deployment

Containerize each service with Docker.
Deploy to AWS ECS (Fargate) or a similar container solution.
Amazon RDS (PostgreSQL) for relational data.
Amazon S3 for images.
ALB or NLB for load balancing the microservices + WebSockets.
3. Key Requirements
3.1 Functional Requirements
User Registration & Login
Users can create an account by providing email/password.
Must handle password hashing, validation, and error states.
Channel Management
Create, list, and join channels.
A user can post in channels they follow or discover public channels.
Post Management
Create text-based posts or upload images (via S3) with optional captions.
Retrieve a feed of posts filtered by channel.
Direct Messaging
Real-time chat with another user.
See message history if offline.
Basic “online/offline” user presence if time permits.
Notifications
Notify a user if they receive a new direct message or if someone interacts with their post.
Possibly integrated with push notifications for mobile (iOS/Android).
3.2 Non-Functional Requirements
Performance
Should handle up to 10,000 users concurrently for MVP (adjust as needed).
Real-time messaging with minimal latency (<1–2 seconds).
Scalability
ECS can scale microservices horizontally if traffic grows.
S3 for images to avoid large file storage in the DB.
Security
JWT tokens or Cognito for all API requests.
Encrypt user passwords in transit (HTTPS) and at rest.
Strict IAM roles for microservices in AWS so each service only accesses what it needs.
Maintainability
Clear domain-based microservices: Auth, User, Post, Messaging, Notification.
Each has its own repository or submodule with documented endpoints.
Use consistent coding standards (Java style, Spring Boot best practices).
Usability & UX
The main consumption is from a mobile app (iOS/Android).
A simpler web UI might be created for demonstration or admin tasks.
3.3 Technical Constraints
Spring Boot for each service (Java 17 or higher).
Docker for containerizing; AWS ECS (Fargate) for orchestration.
AWS RDS (PostgreSQL) for data. Possibly ElastiCache (Redis) if we need caching.
AWS S3 for image uploads.
WebSocket for direct messaging; must be load balanced via ALB or NLB.
Must adhere to best practices for environment variables (e.g. use AWS Parameter Store or Secrets Manager).
4. High-Level User Stories
Sign Up: As a new user, I can create an account with an email and password so that I can log in.
User Profile: As a user, I can update my profile info and upload a profile picture to personalize my account.
Browse Channels: As a user, I can view a list of channels and subscribe to those relevant to me.
Create Post: As a user, I can post text or images in a channel so other members can see.
Direct Message: As a user, I can send a real-time message to another user and get an immediate response if they are online.
Notifications: As a user, I want to receive a push notification when I get a new direct message or reply, so I can respond promptly.
5. Initial Timeline & Milestones
Week 1–2:
Finalize architecture, set up Git repos, skeleton Spring Boot services.
Basic Auth Service (JWT) + RDS connection.
Week 3–4:
User Service & Post/Channel Service.
S3 integration for image upload, basic CRUD endpoints.
Week 5–6:
Messaging Service with WebSocket.
Basic real-time chat.
Week 7:
Notification Service or integrate AWS SNS for push notifications.
Polish & bug fixes.
Week 8:
Dockerize & Deploy to AWS ECS.
Testing, performance checks, final demo.
(Timelines are approximate—adjust as needed for your specific pace.)

6. Next Steps
Validate these requirements with any stakeholders or team members.
Move on to Step 2: Set up repository structure, create Spring Boot skeleton projects, and put placeholders for each microservice.
Update the project plan in the README or a Wiki to ensure the entire scope is documented for reference.

