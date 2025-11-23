Ref. No.: MES IMCC/ [REF_NUMBER] /2024-25                                                              Date: [DATE]
  
# CERTIFICATE

This is to certify that the Project entitled **"CropGuard - Smart Crop Disease Detection System"** is completed by **"[STUDENT_NAME]"** of M.C.A. Semester II for the Academic Year 2024-25 at Maharashtra Education Society's Institute of Management & Career Courses (IMCC), Pune - 411038.

To the best of our knowledge, this is an original study done by the said student and important sources used by him/her have been duly acknowledged in this report.

The report is submitted as a part of course ITP21 Mini Project (Research Project) for the Academic Year 2024-25 as per the rules and guidelines prescribed by the institute.


                                                                         
    Ms. Kalpana Dhende                       Ms. Manasi Shirurkar                     Dr. Ravikant Zirmite
    Project Coordinator                        Program Coordinator                     Head, Dept. Of MCA

---

# CropGuard
## Smart Crop Disease Detection System

---

## 1. Introduction

The **CropGuard - Smart Crop Disease Detection System** is a comprehensive mobile and web-based platform designed to help farmers identify and manage crop diseases using artificial intelligence and machine learning. The system leverages TensorFlow Lite for on-device disease detection, providing instant analysis of crop health through image recognition. It connects farmers with agricultural experts for professional consultation and provides access to nearby agricultural stores for treatment supplies.

### 1.1 Objective

The objective of the CropGuard system is to develop an intelligent, user-friendly mobile application that:
- Enables farmers to detect crop diseases in real-time using AI-powered image analysis
- Provides instant treatment recommendations and preventive measures
- Connects farmers with verified agricultural experts for professional consultation
- Helps locate nearby agricultural stores for purchasing necessary supplies
- Generates comprehensive reports and analytics for crop health monitoring
- Reduces crop losses through early disease detection and timely intervention

### 1.2 Project Scope

This project covers the development of a complete crop disease management ecosystem with three distinct user interfaces:

1. **Farmer Module**: Disease detection, expert consultation, store locator, and health reports
2. **Expert Module**: Query management, case review, knowledge base, and disease trend analysis
3. **Admin Module**: User management, expert verification, store management, and system analytics

The system integrates features like:
- Real-time disease detection using TensorFlow Lite ML models
- Offline-capable disease analysis with local model inference
- Location-based agricultural store search using Google Maps
- Secure authentication via JWT tokens
- Email notifications for expert verification and query responses
- Comprehensive analytics and reporting dashboards

---

## 2. Technologies Used

### Backend Technologies
- **Framework**: Spring Boot 3.2.0
- **Language**: Java 17
- **Database**: MySQL 8.0
- **Security**: Spring Security with JWT (JSON Web Tokens)
- **ORM**: Spring Data JPA with Hibernate
- **Email Service**: Spring Boot Mail
- **Build Tool**: Maven

### Frontend Technologies
- **Framework**: Flutter (Dart SDK 3.8.1)
- **State Management**: Provider
- **HTTP Client**: http package
- **Secure Storage**: flutter_secure_storage
- **Machine Learning**: TensorFlow Lite (tflite_flutter)
- **Image Processing**: image, image_picker, camera
- **Maps & Location**: google_maps_flutter, geolocator, geocoding
- **Charts**: fl_chart
- **Notifications**: flutter_local_notifications
- **Connectivity**: connectivity_plus

### Additional Technologies
- **Machine Learning**: TensorFlow Lite for on-device crop disease detection
- **Maps API**: Google Maps API for store location services
- **Authentication**: JWT-based token authentication
- **Email**: SMTP for notification services

---

## 3. Project Modules

### 3.1 User Registration & Authentication
This module manages user registration, login, and authentication for all three user roles (Farmer, Expert, Admin). It implements secure JWT-based authentication ensuring that only registered users can access the system. Users can register with email and mobile number, and experts must undergo admin verification before gaining full access. The module includes OTP verification for secure account creation and password recovery.

### 3.2 Disease Detection & Analysis
The core module that enables farmers to capture or upload images of crop leaves and receive instant AI-powered disease analysis. Using TensorFlow Lite models running locally on the device, the system identifies the plant type, detects diseases, calculates confidence levels, and provides severity assessments. The module works offline, ensuring farmers in remote areas can still access disease detection capabilities. Results include detailed symptoms, treatment recommendations, and preventive measures.

### 3.3 Scan History & Reports
This module maintains a comprehensive history of all disease scans performed by farmers. Users can view past scans with details including plant type, disease detected, confidence scores, timestamps, and images. The system generates periodic reports (weekly, monthly, crop-specific) with analytics showing disease trends, healthy vs diseased crop ratios, critical issues, and actionable recommendations. Reports can be exported and shared with agricultural advisors.

### 3.4 Expert Consultation System
Farmers can submit queries to agricultural experts when they need professional advice beyond automated disease detection. The module allows farmers to create detailed queries with crop type, category (disease, pest, nutrition, etc.), urgency level, descriptions, and supporting images. Experts receive notifications of new queries, can review cases, provide detailed responses, and track query history. The system maintains a complete conversation thread for each consultation.

### 3.5 Agricultural Store Locator
This module helps farmers find nearby agricultural stores for purchasing seeds, fertilizers, pesticides, and equipment. Using Google Maps integration and GPS location services, the system displays stores on an interactive map with distance calculations, contact information, and navigation support. Stores are categorized by type (seeds, fertilizers, pesticides, equipment, general) for easy filtering. Admins can add and manage store listings.

### 3.6 Notification System
A comprehensive notification module that keeps users informed about important events. Farmers receive notifications when experts respond to their queries, when disease trends are detected, or for system announcements. Experts get notified about new queries, urgent cases, and verification status updates. The system supports both in-app notifications and email notifications for critical updates.

### 3.7 Admin Module
The administrative module provides complete system oversight and management capabilities:
- **User Management**: View and manage all registered farmers and experts
- **Expert Verification**: Review expert registration requests, verify credentials (license numbers, certificates), approve or reject applications
- **Store Management**: Add, edit, and remove agricultural store listings with location details
- **Analytics Dashboard**: View system-wide statistics including total users, scans, queries, disease trends, and platform usage metrics
- **System Configuration**: Manage system settings, email templates, and notification preferences

### 3.8 Expert Module
Dedicated interface for verified agricultural experts:
- **Query Dashboard**: View and manage farmer queries filtered by status (pending, in-progress, resolved)
- **Case Review**: Examine scan results, view crop images, provide expert opinions and ratings
- **Knowledge Base**: Access and contribute to a repository of crop diseases, treatments, and best practices
- **Disease Trends**: Analyze disease patterns across regions and crops with visual analytics
- **Expert Settings**: Manage profile, specialization, availability, and notification preferences

### 3.9 Analytics & Dashboard
Provides role-specific dashboards with key metrics and insights:
- **Farmer Dashboard**: Recent scans, query status, disease alerts, quick access to detection and consultation
- **Expert Dashboard**: Pending queries, cases requiring attention, response statistics, contribution metrics
- **Admin Dashboard**: System health, user growth, disease detection statistics, expert performance, geographic distribution of issues

---

## 4. Users of the System

### 4.1 Farmers (End Users)
Primary users of the system who are crop growers seeking to identify and manage crop diseases. They use the mobile application to:
- Capture images of crop leaves for disease detection
- Receive instant AI-powered analysis and treatment recommendations
- Consult with agricultural experts for complex issues
- Track crop health history and generate reports
- Locate nearby agricultural stores for supplies
- Receive notifications about disease outbreaks and expert responses

### 4.2 Agricultural Experts
Verified professionals with expertise in agriculture, plant pathology, or agronomy. They use the system to:
- Review and respond to farmer queries
- Provide professional diagnosis and treatment advice
- Validate AI-detected diseases and provide expert ratings
- Contribute to the knowledge base
- Analyze disease trends across regions
- Build their professional reputation by helping farmers

### 4.3 System Administrators
Personnel responsible for platform management and quality assurance. They:
- Verify expert credentials and approve registrations
- Manage agricultural store listings
- Monitor system performance and user activity
- Handle user support and dispute resolution
- Analyze platform analytics and generate insights
- Ensure data quality and system integrity
- Configure system settings and notification templates

---

## 5. Analysis and Design

### 5.1 Entity Relationship Diagram (ERD)

```
┌─────────────────────┐
│       USERS         │
├─────────────────────┤
│ PK: id              │
│     username        │
│     mobile          │
│     password        │
│     email           │
│     full_name       │
│     role            │ (USER/EXPERT/ADMIN)
│     specialization  │
│     is_verified     │
│     verification_   │
│       status        │
│     verification_   │
│       document      │
│     license_number  │
│     verified_at     │
│     verified_by     │
│     created_at      │
│     updated_at      │
│     enabled         │
└─────────────────────┘
          │
          │ 1:N
          ├──────────────────────────┐
          │                          │
          ▼                          ▼
┌─────────────────────┐    ┌─────────────────────┐
│       SCANS         │    │   EXPERT_QUERIES    │
├─────────────────────┤    ├─────────────────────┤
│ PK: id              │    │ PK: id              │
│ FK: user_id         │    │ FK: farmer_id       │
│     plant_type      │    │ FK: expert_id       │
│     disease         │    │     title           │
│     confidence      │    │     description     │
│     severity        │    │     crop_type       │
│     status          │    │     category        │
│     image_path      │    │     urgency         │
│     recommendations │    │     image_path      │
│     symptoms        │    │     status          │
│     expert_notes    │    │     has_image       │
│     expert_rating   │    │     response        │
│     created_at      │    │     response_date   │
│     updated_at      │    │     created_at      │
└─────────────────────┘    │     updated_at      │
                           └─────────────────────┘
          │                          │
          │ 1:N                      │ 1:N
          ▼                          ▼
┌─────────────────────┐    ┌─────────────────────┐
│      REPORTS        │    │  EXPERT_RESPONSES   │
├─────────────────────┤    ├─────────────────────┤
│ PK: id              │    │ PK: id              │
│ FK: user_id         │    │ FK: query_id        │
│     title           │    │ FK: expert_id       │
│     type            │    │     response_text   │
│     status          │    │     created_at      │
│     summary         │    └─────────────────────┘
│     disease_count   │
│     healthy_count   │
│     critical_issues │
│     recommendations_│
│       count         │
│     report_data     │
│     file_path       │
│     generated_at    │
│     period_start    │
│     period_end      │
│     created_at      │
│     updated_at      │
└─────────────────────┘

          │ 1:N
          ▼
┌─────────────────────┐
│   NOTIFICATIONS     │
├─────────────────────┤
│ PK: id              │
│ FK: user_id         │
│     title           │
│     message         │
│     type            │
│     is_read         │
│     related_id      │
│     created_at      │
└─────────────────────┘

┌─────────────────────┐
│    AGRI_STORES      │
├─────────────────────┤
│ PK: id              │
│     name            │
│     description     │
│     address         │
│     latitude        │
│     longitude       │
│     contact_number  │
│     owner_name      │
│     store_type      │
│     is_active       │
│     created_by      │
│     created_at      │
│     updated_at      │
└─────────────────────┘

┌─────────────────────┐
│     OTP_ENTITY      │
├─────────────────────┤
│ PK: id              │
│     email           │
│     otp             │
│     created_at      │
│     expires_at      │
└─────────────────────┘
```

### 5.2 Use Case Diagram

```
                                    CropGuard System
                                    
┌──────────────┐                                              ┌──────────────┐
│              │                                              │              │
│    Farmer    │                                              │    Expert    │
│              │                                              │              │
└──────┬───────┘                                              └──────┬───────┘
       │                                                             │
       │  ┌────────────────────────────────────────┐               │
       ├──│ Register / Login                       │               │
       │  └────────────────────────────────────────┘               │
       │                                                             │
       │  ┌────────────────────────────────────────┐               │
       ├──│ Capture Crop Image                     │               │
       │  └────────────────────────────────────────┘               │
       │                                                             │
       │  ┌────────────────────────────────────────┐               │
       ├──│ Detect Disease (AI Analysis)           │               │
       │  └────────────────────────────────────────┘               │
       │                                                             │
       │  ┌────────────────────────────────────────┐               │
       ├──│ View Treatment Recommendations         │               │
       │  └────────────────────────────────────────┘               │
       │                                                             │
       │  ┌────────────────────────────────────────┐               │
       ├──│ Submit Query to Expert                 │◄──────────────┤
       │  └────────────────────────────────────────┘               │
       │                                                             │
       │  ┌────────────────────────────────────────┐               │
       ├──│ View Scan History                      │               │
       │  └────────────────────────────────────────┘               │
       │                                                             │
       │  ┌────────────────────────────────────────┐               │
       ├──│ Generate Health Reports                │               │
       │  └────────────────────────────────────────┘               │
       │                                                             │
       │  ┌────────────────────────────────────────┐               │
       ├──│ Find Nearby Agri Stores                │               │
       │  └────────────────────────────────────────┘               │
       │                                                             │
       │  ┌────────────────────────────────────────┐               │
       ├──│ View Notifications                     │◄──────────────┤
       │  └────────────────────────────────────────┘               │
       │                                                             │
       │                                                             │
       │                                                ┌────────────────────────────────────────┐
       │                                                │ Register as Expert                     │
       │                                                └────────────────────────────────────────┘
       │                                                             │
       │                                                ┌────────────────────────────────────────┐
       │                                                │ View Farmer Queries                    │
       │                                                └────────────────────────────────────────┘
       │                                                             │
       │                                                ┌────────────────────────────────────────┐
       │                                                │ Respond to Queries                     │
       │                                                └────────────────────────────────────────┘
       │                                                             │
       │                                                ┌────────────────────────────────────────┐
       │                                                │ Review Scan Cases                      │
       │                                                └────────────────────────────────────────┘
       │                                                             │
       │                                                ┌────────────────────────────────────────┐
       │                                                │ Analyze Disease Trends                 │
       │                                                └────────────────────────────────────────┘
       │                                                             │
       │                                                ┌────────────────────────────────────────┐
       │                                                │ Manage Knowledge Base                  │
       │                                                └────────────────────────────────────────┘
       │                                                             │
       │                                                             │
┌──────┴───────┐                                              ┌──────┴───────┐
│              │                                              │              │
│    Admin     │                                              │              │
│              │                                              │              │
└──────┬───────┘                                              └──────────────┘
       │
       │  ┌────────────────────────────────────────┐
       ├──│ Verify Expert Credentials              │
       │  └────────────────────────────────────────┘
       │
       │  ┌────────────────────────────────────────┐
       ├──│ Manage Users                           │
       │  └────────────────────────────────────────┘
       │
       │  ┌────────────────────────────────────────┐
       ├──│ Add/Edit Agri Stores                   │
       │  └────────────────────────────────────────┘
       │
       │  ┌────────────────────────────────────────┐
       ├──│ View System Analytics                  │
       │  └────────────────────────────────────────┘
       │
       │  ┌────────────────────────────────────────┐
       ├──│ Send System Notifications              │
       │  └────────────────────────────────────────┘
       │
       │
```

---

## 6. Data Dictionary

### 6.1 Users Table

| Field Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| id | BIGINT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier for each user |
| username | VARCHAR(50) | NOT NULL, UNIQUE | User's login username |
| mobile | VARCHAR(15) | NOT NULL, UNIQUE | User's mobile number (10-15 digits) |
| password | VARCHAR(255) | NOT NULL | Encrypted password |
| email | VARCHAR(100) | UNIQUE | User's email address |
| full_name | VARCHAR(100) | | User's full name |
| role | ENUM | NOT NULL, DEFAULT 'USER' | User role: USER, EXPERT, ADMIN |
| specialization | VARCHAR(200) | | Expert's area of specialization |
| is_verified | BOOLEAN | DEFAULT FALSE | Expert verification status |
| verification_status | ENUM | DEFAULT 'PENDING' | PENDING, APPROVED, REJECTED, SUSPENDED |
| verification_document | VARCHAR(255) | | Path to uploaded certificate/ID |
| license_number | VARCHAR(100) | | Professional license number |
| verified_at | DATETIME | | Timestamp of verification |
| verified_by | BIGINT | FOREIGN KEY | Admin who verified the expert |
| created_at | DATETIME | NOT NULL | Account creation timestamp |
| updated_at | DATETIME | | Last update timestamp |
| enabled | BOOLEAN | DEFAULT TRUE | Account active status |

### 6.2 Scans Table

| Field Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| id | BIGINT | PRIMARY KEY, AUTO_INCREMENT | Unique scan identifier |
| user_id | BIGINT | FOREIGN KEY, NOT NULL | Reference to users table |
| plant_type | VARCHAR(100) | NOT NULL | Type of crop/plant scanned |
| disease | VARCHAR(100) | NOT NULL | Detected disease name |
| confidence | DOUBLE | NOT NULL | AI confidence score (0-1) |
| severity | VARCHAR(50) | | Disease severity level |
| status | VARCHAR(50) | | Scan status |
| image_path | VARCHAR(255) | | Path to uploaded crop image |
| recommendations | TEXT | | Treatment recommendations |
| symptoms | TEXT | | Disease symptoms description |
| expert_notes | TEXT | | Expert's additional notes |
| expert_rating | INTEGER | | Expert's rating of AI accuracy |
| created_at | DATETIME | NOT NULL | Scan timestamp |
| updated_at | DATETIME | | Last update timestamp |

### 6.3 Expert Queries Table

| Field Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| id | BIGINT | PRIMARY KEY, AUTO_INCREMENT | Unique query identifier |
| farmer_id | BIGINT | FOREIGN KEY, NOT NULL | Reference to farmer (users table) |
| expert_id | BIGINT | FOREIGN KEY | Reference to assigned expert |
| title | VARCHAR(200) | NOT NULL | Query title/subject |
| description | TEXT | | Detailed query description |
| crop_type | VARCHAR(100) | | Type of crop |
| category | VARCHAR(50) | NOT NULL | Query category (disease/pest/nutrition) |
| urgency | VARCHAR(20) | NOT NULL | Urgency level (low/medium/high) |
| image_path | VARCHAR(255) | | Path to supporting image |
| status | VARCHAR(50) | DEFAULT 'pending' | pending, in-progress, resolved |
| has_image | BOOLEAN | DEFAULT FALSE | Whether image is attached |
| response | TEXT | | Expert's response |
| response_date | DATETIME | | Response timestamp |
| created_at | DATETIME | NOT NULL | Query creation timestamp |
| updated_at | DATETIME | | Last update timestamp |

### 6.4 Expert Responses Table

| Field Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| id | BIGINT | PRIMARY KEY, AUTO_INCREMENT | Unique response identifier |
| query_id | BIGINT | FOREIGN KEY, NOT NULL | Reference to expert_queries table |
| expert_id | BIGINT | FOREIGN KEY, NOT NULL | Reference to expert (users table) |
| response_text | TEXT | NOT NULL | Expert's detailed response |
| created_at | DATETIME | NOT NULL | Response timestamp |

### 6.5 Reports Table

| Field Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| id | BIGINT | PRIMARY KEY, AUTO_INCREMENT | Unique report identifier |
| user_id | BIGINT | FOREIGN KEY, NOT NULL | Reference to users table |
| title | VARCHAR(200) | NOT NULL | Report title |
| type | VARCHAR(50) | NOT NULL | Report type (Weekly/Monthly/Crop) |
| status | VARCHAR(50) | NOT NULL | Report status |
| summary | TEXT | | Report summary |
| disease_count | INTEGER | | Number of diseased scans |
| healthy_count | INTEGER | | Number of healthy scans |
| critical_issues | INTEGER | | Count of critical issues |
| recommendations_count | INTEGER | | Number of recommendations |
| report_data | TEXT | | JSON data for detailed report |
| file_path | VARCHAR(255) | | Path to generated report file |
| generated_at | DATETIME | NOT NULL | Report generation timestamp |
| period_start | DATETIME | | Report period start date |
| period_end | DATETIME | | Report period end date |
| created_at | DATETIME | NOT NULL | Creation timestamp |
| updated_at | DATETIME | | Last update timestamp |

### 6.6 Notifications Table

| Field Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| id | BIGINT | PRIMARY KEY, AUTO_INCREMENT | Unique notification identifier |
| user_id | BIGINT | FOREIGN KEY, NOT NULL | Reference to users table |
| title | VARCHAR(200) | NOT NULL | Notification title |
| message | TEXT | | Notification message content |
| type | ENUM | NOT NULL | QUERY_RESPONSE, QUERY_STATUS_UPDATE, SYSTEM_NOTIFICATION |
| is_read | BOOLEAN | DEFAULT FALSE | Read status |
| related_id | BIGINT | | ID of related entity (e.g., query ID) |
| created_at | DATETIME | NOT NULL | Notification timestamp |

### 6.7 Agri Stores Table

| Field Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| id | BIGINT | PRIMARY KEY, AUTO_INCREMENT | Unique store identifier |
| name | VARCHAR(100) | NOT NULL | Store name |
| description | VARCHAR(500) | | Store description |
| address | VARCHAR(255) | NOT NULL | Store address |
| latitude | DOUBLE | NOT NULL | GPS latitude coordinate |
| longitude | DOUBLE | NOT NULL | GPS longitude coordinate |
| contact_number | VARCHAR(15) | | Store contact number |
| owner_name | VARCHAR(100) | | Store owner name |
| store_type | ENUM | DEFAULT 'GENERAL' | SEEDS, FERTILIZERS, PESTICIDES, EQUIPMENT, GENERAL |
| is_active | BOOLEAN | DEFAULT TRUE | Store active status |
| created_by | BIGINT | FOREIGN KEY | Admin who created the entry |
| created_at | DATETIME | NOT NULL | Creation timestamp |
| updated_at | DATETIME | | Last update timestamp |

### 6.8 OTP Entity Table

| Field Name | Data Type | Constraints | Description |
|------------|-----------|-------------|-------------|
| id | BIGINT | PRIMARY KEY, AUTO_INCREMENT | Unique OTP identifier |
| email | VARCHAR(100) | NOT NULL | Email address for OTP |
| otp | VARCHAR(6) | NOT NULL | One-time password code |
| created_at | DATETIME | NOT NULL | OTP generation timestamp |
| expires_at | DATETIME | NOT NULL | OTP expiration timestamp |

---

## 7. Sample Input and Output Screens

### 7.1 Login and Registration Screens

#### 7.1.1 Farmer Login Screen
*[Screenshot to be added: Farmer login page with username/mobile and password fields, "Remember Me" checkbox, and "Forgot Password" link]*

**Features:**
- Username/Mobile number input
- Password input with show/hide toggle
- Remember me option
- Forgot password functionality
- Register new account link

#### 7.1.2 Expert Registration Screen
*[Screenshot to be added: Expert registration form with all required fields]*

**Features:**
- Full name, email, mobile number fields
- Specialization selection
- License number input
- Document upload for verification
- Terms and conditions acceptance
- Submit for admin approval

### 7.2 Farmer Dashboard
*[Screenshot to be added: Main farmer dashboard with quick access cards]*

**Features:**
- Welcome message with farmer name
- Quick action buttons: Scan Crop, Ask Expert, View Reports
- Recent scan history summary
- Active query status
- Disease alerts and notifications
- Nearby stores quick access

### 7.3 Disease Detection Screens

#### 7.3.1 Capture Crop Image
*[Screenshot to be added: Camera interface for capturing crop leaf image]*

**Features:**
- Live camera preview
- Capture button
- Gallery selection option
- Flash toggle
- Guidelines for proper image capture

#### 7.3.2 Disease Analysis Result
*[Screenshot to be added: Disease detection result screen]*

**Features:**
- Captured crop image display
- Detected plant type
- Disease name with confidence percentage
- Severity indicator (Low/Medium/High)
- Detailed symptoms list
- Treatment recommendations
- Preventive measures
- Save to history button
- Ask expert about this scan option

### 7.4 Scan History Screen
*[Screenshot to be added: List of all previous scans]*

**Features:**
- Chronological list of scans
- Each entry shows: thumbnail image, plant type, disease, date, confidence
- Filter by plant type or disease
- Search functionality
- Tap to view full details

### 7.5 Expert Consultation Screens

#### 7.5.1 Submit Query to Expert
*[Screenshot to be added: Query submission form]*

**Features:**
- Query title input
- Crop type selection
- Category dropdown (Disease/Pest/Nutrition/Irrigation/Soil)
- Urgency level (Low/Medium/High)
- Detailed description text area
- Image attachment option
- Submit button

#### 7.5.2 My Queries Screen
*[Screenshot to be added: List of farmer's submitted queries]*

**Features:**
- Query list with status badges (Pending/In-Progress/Resolved)
- Each entry shows: title, crop type, urgency, date, expert name (if assigned)
- Filter by status
- Tap to view query details and expert response

### 7.6 Agricultural Store Locator
*[Screenshot to be added: Map view with store markers]*

**Features:**
- Google Maps integration
- Current location marker
- Store markers with category icons
- Distance from current location
- Store type filter (Seeds/Fertilizers/Pesticides/Equipment/General)
- Store details card: name, address, contact, directions button
- Call store button
- Get directions button

### 7.7 Reports Screen
*[Screenshot to be added: Reports dashboard with charts]*

**Features:**
- Report type selection (Weekly/Monthly/Crop-specific)
- Date range selector
- Visual charts:
  - Disease vs Healthy scans pie chart
  - Disease trend line graph
  - Most common diseases bar chart
- Summary statistics: total scans, disease count, critical issues
- Download report button
- Share report option

### 7.8 Expert Dashboard
*[Screenshot to be added: Expert's main dashboard]*

**Features:**
- Pending queries count with urgent indicator
- Cases requiring attention
- Response statistics (total responses, average response time)
- Recent queries list
- Quick access to: Queries, Case Review, Knowledge Base, Trends
- Contribution metrics

### 7.9 Expert Query Management
*[Screenshot to be added: Expert's query list and response interface]*

**Features:**
- Query list filtered by status
- Urgency indicators
- Query details view with farmer information
- Attached images viewer
- Response text editor
- Submit response button
- Mark as resolved option

### 7.10 Expert Case Review Screen
*[Screenshot to be added: Expert reviewing AI-detected disease]*

**Features:**
- Scan image display
- AI detection results
- Plant type and disease
- Confidence score
- Symptoms and recommendations
- Expert rating system (1-5 stars)
- Expert notes input
- Validate or correct diagnosis option

### 7.11 Disease Trends Analytics
*[Screenshot to be added: Expert's disease trend analysis dashboard]*

**Features:**
- Geographic disease distribution map
- Seasonal trend charts
- Crop-wise disease breakdown
- Severity distribution
- Time period filter
- Export analytics data

### 7.12 Admin Dashboard
*[Screenshot to be added: Admin's main control panel]*

**Features:**
- System statistics cards:
  - Total users (Farmers/Experts)
  - Total scans performed
  - Active queries
  - Registered stores
- Pending expert verifications count
- Recent user registrations
- System health indicators
- Quick access to: User Management, Expert Verification, Store Management, Analytics

### 7.13 Admin Expert Verification Screen
*[Screenshot to be added: Expert verification interface]*

**Features:**
- Pending expert applications list
- Expert details: name, email, mobile, specialization
- License number display
- Uploaded document viewer
- Approve button
- Reject button with reason input
- Email notification preview

### 7.14 Admin Store Management
*[Screenshot to be added: Agricultural store management interface]*

**Features:**
- Store list with search and filter
- Add new store button
- Store form: name, description, address, coordinates, contact, type
- Map for location selection
- Edit/Delete options
- Active/Inactive toggle

### 7.15 Notifications Screen
*[Screenshot to be added: User notifications list]*

**Features:**
- Chronological notification list
- Unread indicator
- Notification types with icons
- Timestamp
- Mark as read option
- Clear all notifications
- Tap to view related content

---

## 8. System Architecture

### 8.1 Architecture Overview

The CropGuard system follows a **client-server architecture** with the following components:

**Frontend (Mobile App)**
- Flutter-based cross-platform mobile application
- Runs on Android and iOS devices
- Local TensorFlow Lite model for offline disease detection
- Communicates with backend via REST APIs
- Stores user credentials securely using flutter_secure_storage

**Backend (API Server)**
- Spring Boot REST API server
- Handles authentication, data management, and business logic
- Processes expert queries and notifications
- Manages user roles and permissions
- Sends email notifications

**Database**
- MySQL relational database
- Stores user data, scans, queries, reports, and stores
- Maintains data integrity with foreign key relationships

**External Services**
- Google Maps API for store location services
- SMTP server for email notifications
- Cloud storage for images (optional)

### 8.2 Security Features

1. **Authentication**: JWT-based token authentication
2. **Password Security**: BCrypt password hashing
3. **Role-Based Access Control**: USER, EXPERT, ADMIN roles
4. **Secure Storage**: Encrypted local storage for tokens
5. **API Security**: Spring Security with CORS configuration
6. **Expert Verification**: Admin approval required for expert accounts

### 8.3 Offline Capabilities

- Disease detection works offline using local TensorFlow Lite models
- Scan results cached locally until internet connection available
- Automatic sync when connection restored
- Connectivity status monitoring

---

## 9. Key Features Summary

1. ✅ **AI-Powered Disease Detection** - Real-time crop disease identification using TensorFlow Lite
2. ✅ **Offline Functionality** - Works without internet for disease detection
3. ✅ **Expert Consultation** - Direct communication with verified agricultural experts
4. ✅ **Store Locator** - Find nearby agricultural stores with navigation
5. ✅ **Comprehensive Reports** - Generate detailed crop health reports with analytics
6. ✅ **Multi-Role System** - Separate interfaces for Farmers, Experts, and Admins
7. ✅ **Notification System** - Real-time alerts for queries, responses, and updates
8. ✅ **Expert Verification** - Admin-controlled expert credential verification
9. ✅ **Scan History** - Complete history of all disease detections
10. ✅ **Analytics Dashboard** - Visual insights into disease trends and patterns

---

## 10. Future Enhancements

1. **Weather Integration** - Correlate disease outbreaks with weather patterns
2. **Crop Calendar** - Planting and harvesting schedule management
3. **Community Forum** - Farmer-to-farmer knowledge sharing
4. **Multilingual Support** - Support for regional languages
5. **Voice Input** - Voice-based query submission for low-literacy users
6. **Pest Detection** - Extend AI model to detect crop pests
7. **Soil Testing Integration** - Connect with soil testing services
8. **Market Prices** - Real-time crop market price information
9. **Government Schemes** - Information about agricultural subsidies and schemes
10. **Video Consultation** - Live video calls with experts

---

## 11. Conclusion

CropGuard represents a comprehensive solution to the critical problem of crop disease management in modern agriculture. By combining artificial intelligence, expert knowledge, and location-based services, the system empowers farmers with the tools they need to protect their crops and improve yields. The multi-role architecture ensures that farmers, experts, and administrators can collaborate effectively within a single ecosystem.

The use of offline-capable AI models makes the system accessible even in remote areas with limited internet connectivity, while the expert consultation feature provides professional guidance when needed. The system's analytics and reporting capabilities help farmers make data-driven decisions about crop health management.

With its user-friendly interface, robust security, and comprehensive feature set, CropGuard has the potential to significantly reduce crop losses, improve agricultural productivity, and contribute to food security.

---

## 12. References

1. Spring Boot Documentation - https://spring.io/projects/spring-boot
2. Flutter Documentation - https://flutter.dev/docs
3. TensorFlow Lite Documentation - https://www.tensorflow.org/lite
4. Google Maps Platform - https://developers.google.com/maps
5. JWT Authentication - https://jwt.io/
6. MySQL Documentation - https://dev.mysql.com/doc/

---

**Project Developed By:** [STUDENT_NAME]  
**Academic Year:** 2024-25  
**Institution:** Maharashtra Education Society's Institute of Management & Career Courses (IMCC), Pune  
**Program:** M.C.A. Semester II  
**Course:** ITP21 Mini Project (Research Project)

---

*End of Documentation*
