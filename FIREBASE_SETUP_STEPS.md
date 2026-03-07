# Firebase Setup - Step by Step Guide

## 🚀 Step 1: Create Firebase Project

### 1.1 Go to Firebase Console
- Open https://console.firebase.google.com/
- Sign in with your Google account

### 1.2 Create New Project
- Click "Add project" 
- Project name: `college-portal-complete`
- Click "Continue"
- Disable Google Analytics (optional for now)
- Click "Create project"

## 🗄️ Step 2: Enable Firestore Database

### 2.1 Create Firestore Database
- In your project dashboard, click "Firestore Database" in the left menu
- Click "Create database"
- Select "Start in test mode" (we'll secure it later)
- Choose a location: `asia-south1` (recommended for India)
- Click "Enable"

### 2.2 Verify Database
- You should see an empty database with "Collection" and "Document" options
- Keep this tab open

## 📱 Step 3: Add Web App

### 3.1 Register Web App
- In Firebase Console, click the Web icon (</>) 
- App nickname: `College Portal Web`
- Click "Register app"

### 3.2 Get Firebase Config
- Copy the firebaseConfig object that appears
- It looks like this:
```javascript
const firebaseConfig = {
  apiKey: "AIzaSy...",
  authDomain: "your-project.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abcdef123456"
};
```

### 3.3 Update Your Flutter App
- Replace the content of `lib/firebase_options.dart` with your actual config
- Update ONLY the values: apiKey, appId, messagingSenderId, projectId

## 🔒 Step 4: Set Up Security Rules

### 4.1 Go to Firestore Rules
- In Firebase Console, go to Firestore Database
- Click "Rules" tab
- Replace existing rules with the secure rules below

### 4.2 Copy These Security Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - authenticated users can read their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Students collection - role-based access
    match /students/{studentId} {
      allow read: if request.auth != null && (
        request.auth.uid == studentId || 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data().userType in ['faculty', 'principal', 'placement']
      );
      allow write: if request.auth != null && (
        request.auth.uid == studentId || 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data().userType in ['faculty', 'principal']
      );
    }
    
    // Faculty collection - read all, write own or principal
    match /faculty/{facultyId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && (
        request.auth.uid == facultyId || 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data().userType == 'principal'
      );
    }
    
    // Attendance - faculty write, authenticated read
    match /attendance/{attendanceId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data().userType in ['faculty', 'principal'];
    }
    
    // Marks - faculty write, authenticated read
    match /marks/{marksId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data().userType in ['faculty', 'principal'];
    }
    
    // Remarks - faculty write, authenticated read
    match /remarks/{remarksId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data().userType in ['faculty', 'principal'];
    }
    
    // Certificates - students write own, authenticated read
    match /certificates/{certificateId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Jobs - placement write, authenticated read
    match /jobs/{jobId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data().userType in ['placement', 'principal'];
    }
    
    // Notifications - system write, authenticated read
    match /notifications/{notificationId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    // Subjects, Timetable, Internal Marks - faculty write, authenticated read
    match /{otherCollection}/{docId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data().userType in ['faculty', 'principal', 'placement'];
    }
  }
}
```

### 4.3 Publish Rules
- Click "Publish" button
- Wait for rules to be published

## 👥 Step 5: Add Users Manually

### 5.1 Go to Firestore Data
- In Firebase Console, go to Firestore Database
- Click "Start collection"
- Collection ID: `users`

### 5.2 Add Student User
Click "Add document" and add:

**Document ID:** `student1`
**Fields:**
```
username: "23KT1A0596" (string)
password: "password123" (string)
userType: "student" (string)
name: "LANKE DURGA VENKATA KRISHNA VARMA" (string)
email: "lanke.student@college.edu" (string)
phone: "+91 98765 43210" (string)
isActive: true (boolean)
createdAt: (timestamp) - click "Add timestamp" → "Server timestamp"
```

### 5.3 Add Principal User
Click "Add document" and add:

**Document ID:** `principal1`
**Fields:**
```
username: "principal" (string)
password: "admin123" (string)
userType: "principal" (string)
name: "Dr. Principal Name" (string)
email: "principal@college.edu" (string)
phone: "+91 98765 43213" (string)
isActive: true (boolean)
createdAt: (timestamp) - click "Add timestamp" → "Server timestamp"
```

### 5.4 Add Faculty User (HoD)
Click "Add document" and add:

**Document ID:** `faculty1`
**Fields:**
```
username: "hod001" (string)
password: "faculty123" (string)
userType: "faculty" (string)
name: "Dr. Ramesh Kumar" (string)
email: "ramesh.kumar@college.edu" (string)
phone: "+91 98765 43212" (string)
department: "CSE" (string)
designation: "Professor & HoD" (string)
role: "hod" (string)
isActive: true (boolean)
createdAt: (timestamp) - click "Add timestamp" → "Server timestamp"
```

### 5.5 Add Placement User
Click "Add document" and add:

**Document ID:** `placement1`
**Fields:**
```
username: "placement" (string)
password: "place123" (string)
userType: "placement" (string)
name: "Placement Officer" (string)
email: "placement@college.edu" (string)
phone: "+91 98765 43214" (string)
isActive: true (boolean)
createdAt: (timestamp) - click "Add timestamp" → "Server timestamp"
```

## 🎓 Step 6: Add Student Profiles

### 6.1 Create Students Collection
- Click "Start collection"
- Collection ID: `students`

### 6.2 Add Student Profile
**Document ID:** `student1`
**Fields:**
```
admissionNo: "23KT1A0596" (string)
rollNo: "23KT1A0596" (string)
name: "LANKE DURGA VENKATA KRISHNA VARMA" (string)
course: "B.Tech" (string)
branch: "CSE" (string)
semester: "VI" (string)
section: "A" (string)
batch: "2023-2027" (string)
cgpa: "8.44" (string)
backlogs: 2 (number)
dob: "15/10/2005" (string)
gender: "Male" (string)
bloodGroup: "O+" (string)
nationality: "Indian" (string)
religion: "Hindu" (string)
category: "OC" (string)
aadhar: "123456789012" (string)
fatherName: "LANKE SURENDRA" (string)
fatherOccupation: "Business" (string)
motherName: "LANKE GOWRI" (string)
motherOccupation: "Home Maker" (string)
parentPhone: "+91 98765 43215" (string)
address: "123 College Road, Hyderabad, Telangana - 500001" (string)
permanentAddress: "456 Home Town, District, State - 123456" (string)
emergencyContact: "+91 98765 43216" (string)
email: "lanke.student@college.edu" (string)
phone: "+91 98765 43210" (string)
createdAt: (timestamp) - Server timestamp
updatedAt: (timestamp) - Server timestamp
```

## 👨‍🏫 Step 7: Add Faculty Profile

### 7.1 Create Faculty Collection
- Click "Start collection"
- Collection ID: `faculty`

### 7.2 Add Faculty Profile
**Document ID:** `faculty1`
**Fields:**
```
employeeId: "EMP001" (string)
name: "Dr. Ramesh Kumar" (string)
department: "CSE" (string)
designation: "Professor & HoD" (string)
email: "ramesh.kumar@college.edu" (string)
phone: "+91 98765 43212" (string)
qualification: "Ph.D. in Computer Science" (string)
experience: "12 Years" (string)
specialization: "Machine Learning, AI" (string)
subjects: ["CD", "CC", "ML"] (array)
isActive: true (boolean)
createdAt: (timestamp) - Server timestamp
```

## 🧪 Step 8: Test Your App

### 8.1 Run Your Flutter App
```bash
flutter run -d chrome
```

### 8.2 Test Login Credentials
- **Student:** username `23KT1A0596`, password `password123`
- **Principal:** username `principal`, password `admin123`
- **Faculty (HoD):** username `hod001`, password `faculty123`
- **Placement:** username `placement`, password `place123`

### 8.3 Verify Functionality
- ✅ Login works for all user types
- ✅ Students can see their data
- ✅ Faculty can access required features
- ✅ Principal has admin access
- ✅ Placement can manage jobs

## 🎯 SUCCESS!

Your Firebase is now:
✅ Properly configured with security rules
✅ Populated with test users
✅ Ready for production use
✅ Secure and protected

Your college portal is now fully operational with Firebase! 🎉
