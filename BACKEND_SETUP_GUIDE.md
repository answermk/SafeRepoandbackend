# Backend Setup & Database Guide

## 📋 **Prerequisites**

Before setting up the backend, ensure you have:

1. **Java 17** (JDK 17) - [Download here](https://www.oracle.com/java/technologies/javase/jdk17-archive-downloads.html)
2. **PostgreSQL** - [Download here](https://www.postgresql.org/download/)
3. **Maven** (optional, project includes Maven wrapper)
4. **IDE** (IntelliJ IDEA, Eclipse, or VS Code)

---

## 🗄️ **Database Setup: PostgreSQL**

### **Step 1: Install PostgreSQL**

1. Download PostgreSQL from [postgresql.org](https://www.postgresql.org/download/)
2. Install with default settings
3. **Remember your postgres user password** (you'll need it later)

### **Step 2: Create the Database**

The database **must be created manually**. Hibernate will auto-create tables, but not the database itself.

#### **Option A: Using pgAdmin (GUI)**

1. Open **pgAdmin** (installed with PostgreSQL)
2. Connect to PostgreSQL server (use your postgres password)
3. Right-click on **Databases** → **Create** → **Database**
4. Name: `SafeReport`
5. Click **Save**

#### **Option B: Using Command Line (psql)**

1. Open **Command Prompt** (Windows) or **Terminal** (Mac/Linux)
2. Navigate to PostgreSQL bin directory (usually `C:\Program Files\PostgreSQL\15\bin` on Windows)
3. Run:

```bash
# Connect to PostgreSQL
psql -U postgres

# Enter your postgres password when prompted

# Create the database
CREATE DATABASE "SafeReport";

# Verify it was created
\l

# Exit psql
\q
```

#### **Option C: Using SQL Script**

Create a file `create_database.sql`:

```sql
CREATE DATABASE "SafeReport"
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'English_United States.1252'
    LC_CTYPE = 'English_United States.1252'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;
```

Then run:
```bash
psql -U postgres -f create_database.sql
```

---

## ⚙️ **Backend Configuration**

### **Step 1: Set Environment Variables**

The backend uses environment variables for sensitive data. Create a `.env` file in the backend root directory:

**Location**: `SafeReport-Backend-APIS-main/.env`

```env
# Database Password
DB_PASSWORD=your_postgres_password_here

# JWT Secret (generate a random string, at least 256 bits)
JWT_SECRET=your-super-secret-jwt-key-at-least-256-bits-long-for-security

# Email Configuration (for password reset)
EMAIL_USERNAME=your-email@gmail.com
EMAIL_PASSWORD=your-app-specific-password

# AI Service (Optional - for AI features)
OPENAI_API_KEY=your-openai-key-here
GEMINI_API_KEY=your-gemini-key-here
```

**Important Notes:**
- Replace `your_postgres_password_here` with your actual PostgreSQL password
- Generate a strong JWT secret (you can use: `openssl rand -base64 32`)
- For Gmail, use an [App Password](https://support.google.com/accounts/answer/185833) instead of your regular password
- AI keys are optional - the app works without them

### **Step 2: Verify Database Connection**

Check `application.properties`:

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/SafeReport
spring.datasource.username=postgres
spring.datasource.password=${DB_PASSWORD}
```

**Make sure:**
- Database name is `SafeReport` (case-sensitive)
- Username is `postgres` (or your PostgreSQL username)
- Port is `5432` (default PostgreSQL port)

---

## 🚀 **Running the Backend**

### **Method 1: Using Maven Wrapper (Recommended)**

The project includes Maven wrapper, so you don't need Maven installed separately.

#### **Windows:**
```bash
cd SafeReport-Backend-APIS-main
.\mvnw.cmd spring-boot:run
```

#### **Mac/Linux:**
```bash
cd SafeReport-Backend-APIS-main
./mvnw spring-boot:run
```

### **Method 2: Using Maven (if installed)**

```bash
cd SafeReport-Backend-APIS-main
mvn spring-boot:run
```

### **Method 3: Using IDE (IntelliJ IDEA)**

1. Open IntelliJ IDEA
2. **File** → **Open** → Select `SafeReport-Backend-APIS-main` folder
3. Wait for Maven to download dependencies
4. Find `CrimeBackendApplication.java` in `src/main/java/com/crimeprevention/crime_backend/`
5. Right-click → **Run 'CrimeBackendApplication'**

### **Method 4: Build JAR and Run**

```bash
# Build the project
cd SafeReport-Backend-APIS-main
mvn clean package

# Run the JAR
java -jar target/crime-backend-0.0.1-SNAPSHOT.jar
```

---

## ✅ **Verifying Backend is Running**

### **Check Backend Status**

1. **Look for this in console:**
   ```
   Started CrimeBackendApplication in X.XXX seconds
   ```

2. **Test the API:**
   - Open browser: `http://localhost:8080/api/test` (if TestController exists)
   - Or use Postman/curl:
   ```bash
   curl http://localhost:8080/api/auth/login
   ```

3. **Check Database Tables:**
   - Open pgAdmin
   - Connect to `SafeReport` database
   - You should see tables auto-created by Hibernate:
     - `users`
     - `reports`
     - `messages`
     - `watch_groups`
     - etc.

---

## 🔧 **Troubleshooting**

### **Problem: Database Connection Failed**

**Error:** `Connection refused` or `FATAL: password authentication failed`

**Solutions:**
1. Check PostgreSQL is running:
   - Windows: Services → PostgreSQL
   - Mac: `brew services list`
   - Linux: `sudo systemctl status postgresql`

2. Verify database exists:
   ```bash
   psql -U postgres -l
   # Look for "SafeReport" in the list
   ```

3. Check password in `.env` file matches PostgreSQL password

4. Verify connection string in `application.properties`

### **Problem: Port 8080 Already in Use**

**Error:** `Port 8080 is already in use`

**Solutions:**
1. Find what's using port 8080:
   ```bash
   # Windows
   netstat -ano | findstr :8080
   
   # Mac/Linux
   lsof -i :8080
   ```

2. Kill the process or change port in `application.properties`:
   ```properties
   server.port=8081
   ```

3. Update Flutter `AppConfig.apiBaseUrl` to match new port

### **Problem: Tables Not Created**

**Error:** Database exists but no tables

**Solutions:**
1. Check `ddl-auto=update` in `application.properties`
2. Ensure Hibernate can connect (check logs)
3. Manually run SQL scripts if needed (see `sample_data.sql`)

### **Problem: JWT Secret Error**

**Error:** `JWT secret is too short`

**Solution:**
Generate a longer secret (at least 256 bits):
```bash
# Generate random secret
openssl rand -base64 32
```
Add to `.env` file.

---

## 📊 **Database Auto-Creation**

### **How It Works:**

The backend uses **Hibernate with `ddl-auto=update`**:

```properties
spring.jpa.hibernate.ddl-auto=update
```

This means:
- ✅ **Tables are auto-created** when backend starts
- ✅ **Columns are auto-added** if new fields are added to models
- ✅ **No manual SQL needed** for basic setup
- ⚠️ **Database must exist** (you create it manually)
- ⚠️ **Data is preserved** on restart (unlike `create-drop`)

### **What Gets Created:**

When you first run the backend, Hibernate automatically creates:

- `users` - User accounts
- `reports` - Crime reports
- `report_media` - Report attachments
- `messages` - Direct messages
- `watch_groups` - Community groups
- `watch_group_members` - Group memberships
- `notifications` - User notifications
- `forum_posts` - Forum posts
- `forum_replies` - Forum replies
- `report_summaries` - AI summaries
- And more...

---

## 🧪 **Testing the Setup**

### **1. Test Database Connection**

```bash
# Connect to database
psql -U postgres -d SafeReport

# List tables
\dt

# Exit
\q
```

### **2. Test Backend API**

**Using curl:**
```bash
# Test login endpoint (should return error without credentials, but confirms API is running)
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"test"}'
```

**Using Postman:**
1. Create new request
2. POST `http://localhost:8080/api/auth/login`
3. Body (JSON):
   ```json
   {
     "email": "test@test.com",
     "password": "test123"
   }
   ```

### **3. Test from Flutter App**

1. Update `lib/config/app_config.dart`:
   ```dart
   static const String baseUrl = 'http://localhost:8080/api';
   // For Android emulator, use: 'http://10.0.2.2:8080/api'
   // For iOS simulator, use: 'http://localhost:8080/api'
   // For physical device, use your computer's IP: 'http://192.168.1.X:8080/api'
   ```

2. Run Flutter app
3. Try logging in with backend credentials

---

## 📝 **Quick Start Checklist**

- [ok] Install PostgreSQL
- [ok] Create `SafeReport` database
- [ok] Create `.env` file with required variables
- [ok] Set `DB_PASSWORD` in `.env`
- [ok] Set `JWT_SECRET` in `.env`
- [ ] (Optional) Set email credentials
- [ ] (Optional) Set AI API keys
- [ ] Run backend: `./mvnw spring-boot:run`
- [ ] Verify backend running on `http://localhost:8080`
- [ ] Check database tables created
- [ ] Update Flutter `AppConfig.apiBaseUrl`
- [ ] Test login from Flutter app

---

## 🔐 **Security Notes**

1. **Never commit `.env` file** to Git (it should be in `.gitignore`)
2. **Use strong JWT secret** (at least 256 bits)
3. **Use App Passwords** for Gmail (not your regular password)
4. **Change default PostgreSQL password** in production
5. **Use environment variables** for all sensitive data

---

## 📚 **Additional Resources**

- **PostgreSQL Docs**: https://www.postgresql.org/docs/
- **Spring Boot Docs**: https://spring.io/projects/spring-boot
- **Maven Docs**: https://maven.apache.org/guides/

---

## 🆘 **Need Help?**

Common issues:
1. **Database connection**: Check PostgreSQL is running and password is correct
2. **Port conflicts**: Change port or stop conflicting service
3. **Missing dependencies**: Run `mvn clean install` first
4. **Environment variables**: Ensure `.env` file is in correct location

For more help, check the backend logs in the console output.

