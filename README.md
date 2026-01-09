<p align="center">
  <img src="assets/logo.png" alt="Plateful Logo" width="140" />
</p>

<p align="center">
  <img src="assets/banner.png" alt="Plateful Banner" width="90%" />
</p>

<h1 align="center">Plateful</h1>
<h3 align="center">Smart Food Donation Platform for iOS (Donors • NGOs • Collectors • Admin)</h3>

<p align="center">
  A modern iOS platform that connects donors, verified NGOs, and collectors to streamline food donation workflows end-to-end — from creation to delivery confirmation — powered by real-time cloud infrastructure.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS-0A84FF?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Language-Swift%205.0%2B-F05138?style=for-the-badge" />
  <img src="https://img.shields.io/badge/UI-UIKit-34C759?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Architecture-MVC-5856D6?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Backend-Firebase-FF9500?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Images-Cloudinary-8E8E93?style=for-the-badge" />
</p>

<p align="center">
  <b>Status:</b> Production-ready university project • <b>Realtime:</b> Firestore listeners • <b>Media:</b> Cloud image hosting
</p>

<hr />

<h2>Overview</h2>
<p>
  <b>Plateful</b> is a scalable mobile donation ecosystem designed to reduce food waste and improve donation coordination.
  The app supports multiple roles with clean UI flows and role-based access:
</p>

<ul>
  <li><b>Donors</b> create donations, track statuses, manage favorites, and view history.</li>
  <li><b>NGOs</b> review incoming donations, accept items, coordinate pickups, and manage workflows.</li>
  <li><b>Collectors</b> execute pickups/deliveries and update delivery progress in real time.</li>
  <li><b>Admins</b> verify NGOs, manage users, monitor activity, and publish announcements/legal pages.</li>
</ul>

<hr />

<h2>Key Highlights</h2>
<ul>
  <li><b>Real-time updates</b> (Firestore live listeners) — status changes reflect instantly in the UI.</li>
  <li><b>Verified NGO ecosystem</b> — admin approval workflow ensures trust and safety.</li>
  <li><b>Clean iOS implementation</b> — UIKit + MVC, structured folders, maintainable controllers/models/services.</li>
  <li><b>Cloud media pipeline</b> — donations support images stored securely via Cloudinary URLs.</li>
  <li><b>Professional Git workflow</b> — feature branching, integration discipline, and clean history.</li>
</ul>

<hr />

<h2>Core Features</h2>

<h3>Donor</h3>
<ul>
  <li>Create donations with item details and images</li>
  <li>Status tracking lifecycle: <b>Pending → Accepted → Scheduled → Completed</b></li>
  <li>Donation history with details and confirmations</li>
  <li>NGO discovery and favorites</li>
  <li>Recurring donation management</li>
</ul>

<h3>NGO</h3>
<ul>
  <li>Browse available donations and accept items</li>
  <li>Schedule pickups and manage assigned donations</li>
  <li>Update statuses and maintain collection workflow</li>
  <li>Collector workflow integration screens</li>
</ul>

<h3>Collector</h3>
<ul>
  <li>Collector home dashboard and task list</li>
  <li>Update delivery status in real time</li>
  <li>Collector profile view</li>
</ul>

<h3>Admin</h3>
<ul>
  <li>NGO verification and approval system</li>
  <li>User management and platform moderation tools</li>
  <li>Donation reports and analytics</li>
  <li>Announcements and system notifications (role-targeted)</li>
  <li>Legal pages: FAQ, Privacy Policy, Terms & Conditions</li>
</ul>

<hr />

<h2>Feature Breakdown & Responsibilities</h2>
<p>
  This section is written to be clear for grading and evaluation. Names are consistent across features.
</p>

<h3>Feature 1: Authentication & Role Management</h3>
<ul>
  <li><b>Developer:</b> Ghadeer Alwasti</li>
  <li><b>Tester:</b> Abdulwahid Shehab</li>
  <li><b>Description:</b> Firebase Authentication and role-based routing (Donor/NGO/Collector/Admin) with protected navigation flows.</li>
</ul>

<h3>Feature 2: Donor Home & Donation Management</h3>
<ul>
  <li><b>Developer:</b> Abdulwahid Shehab</li>
  <li><b>Tester:</b> Rashed Alsuwaidi</li>
  <li><b>Description:</b> Donor dashboard UI, donation creation flow, donation history, and recurring donations management.</li>
</ul>

<h3>Feature 3: NGO Discovery & Favorites</h3>
<ul>
  <li><b>Developer:</b> Samana Kamal</li>
  <li><b>Tester:</b> Hasan Fardan</li>
  <li><b>Description:</b> Searchable NGO listings, NGO profile screens, and favorite/save functionality for donors.</li>
</ul>

<h3>Feature 4: Real-Time Donation Status Tracking</h3>
<ul>
  <li><b>Developer:</b> Adil Taufique</li>
  <li><b>Tester:</b> Ghadeer Alwasti</li>
  <li><b>Description:</b> Status lifecycle handling using Firestore listeners for instant UI updates across roles.</li>
</ul>

<h3>Feature 5: Collector Workflow & Delivery Updates</h3>
<ul>
  <li><b>Developer:</b> Rashed Alsuwaidi</li>
  <li><b>Tester:</b> Abdulwahid Shehab</li>
  <li><b>Description:</b> Collector dashboard and delivery status update flow with real-time synchronization.</li>
</ul>

<h3>Feature 6: Admin Dashboard & NGO Verification</h3>
<ul>
  <li><b>Developer:</b> Hasan Fardan</li>
  <li><b>Tester:</b> Samana Kamal</li>
  <li><b>Description:</b> Admin tools for NGO application review, verification decisions, and platform maintenance workflows.</li>
</ul>

<h3>Feature 7: Notifications & Announcements</h3>
<ul>
  <li><b>Developer:</b> Rashed Alsuwaidi</li>
  <li><b>Tester:</b> Ghadeer Alwasti</li>
  <li><b>Description:</b> Notification center and admin announcements targeting user roles (message/announcement/system types).</li>
</ul>

<h3>Feature 8: Legal Pages</h3>
<ul>
  <li><b>Developer:</b> Hasan Fardan</li>
  <li><b>Tester:</b> Adil Taufique</li>
  <li><b>Description:</b> FAQ, Privacy Policy, and Terms & Conditions pages accessible in-app for transparency and compliance.</li>
</ul>

<hr />

<h2>Architecture</h2>

<pre><code>Plateful (iOS App)
│
├── Presentation (UIKit Views, Storyboards)
├── Controllers  (ViewControllers, UI handlers)
├── Models       (Structs, DTOs, mapping)
├── Services     (Firebase, Cloudinary, Helpers)
└── Resources    (Assets, Icons, Branding)
</code></pre>

<p>
  The project follows a clean MVC structure with a scalable folder organization suitable for teamwork and grading.
</p>

<hr />

<h2>Backend Services</h2>

<h3>Firebase</h3>
<ul>
  <li>Authentication (role-based access)</li>
  <li>Firestore (users, NGOs, donations, notifications)</li>
  <li>Real-time updates (listeners)</li>
</ul>

<h3>Cloudinary</h3>
<ul>
  <li>Secure image hosting for donation media</li>
  <li>Optimized delivery (compression/resizing)</li>
  <li>URL storage inside Firestore documents</li>
</ul>

<hr />

<h2>Firestore Collections</h2>

<h3><code>users</code></h3>
<pre><code>id
name
email
role ("donor" | "ngo" | "collector" | "admin")
createdAt
</code></pre>

<h3><code>ngos</code></h3>
<pre><code>id
name
location
licenseNumber
description
approved (bool)
createdAt
</code></pre>

<h3><code>donations</code></h3>
<pre><code>donorId
ngoId
items[]
images[]   // Cloudinary URLs
pickupTime
status
createdAt
</code></pre>

<h3><code>notifications</code></h3>
<pre><code>title
body
type ("message" | "announcement" | "system")
targetRole
createdAt
</code></pre>

<hr />

<h2>Git Workflow</h2>

<h3>Main branches</h3>
<pre><code>main → final release
dev  → team integration
</code></pre>

<h3>Feature branches</h3>
<pre><code>feature/person1-auth-profile
feature/person2-donor-home-history
feature/person3-ngo-discovery-favorites
feature/person4-add-donation-status
feature/person5-ngo-collector-scheduling
feature/person6-admin-notifications-legal
</code></pre>

<h3>Rules</h3>
<ul>
  <li>No direct commits to <code>main</code></li>
  <li>All work happens in feature branches</li>
  <li>PR → <code>dev</code> → review → merge → release to <code>main</code></li>
  <li>No untested code enters <code>main</code></li>
</ul>

<hr />

<h2>Screenshots</h2>

<p align="center">
  <img src="assets/screenshots/login.png" width="230" alt="Login" />
  <img src="assets/screenshots/donor_home.png" width="230" alt="Donor Home" />
  <img src="assets/screenshots/ngo_list.png" width="230" alt="NGO List" />
</p>

<p align="center">
  <img src="assets/screenshots/add_donation.png" width="230" alt="Add Donation" />
  <img src="assets/screenshots/pickup_schedule.png" width="230" alt="Pickup Schedule" />
  <img src="assets/screenshots/admin_dashboard.png" width="230" alt="Admin Dashboard" />
</p>

<hr />

<h2>Team Responsibilities</h2>

<table>
  <thead>
    <tr>
      <th align="left">Person</th>
      <th align="left">Module</th>
      <th align="left">Responsibilities</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><b>1</b></td>
      <td>Auth + Profile</td>
      <td>Login, Signup, Profile, Firebase Auth</td>
    </tr>
    <tr>
      <td><b>2</b></td>
      <td>Donor Home + History</td>
      <td>Dashboard, Donation History, History Details</td>
    </tr>
    <tr>
      <td><b>3</b></td>
      <td>NGO Discovery</td>
      <td>NGO List, Search, NGO Profile, Favorites</td>
    </tr>
    <tr>
      <td><b>4</b></td>
      <td>Add Donation</td>
      <td>Donation Form Flow, Cloudinary Uploads, Status UI</td>
    </tr>
    <tr>
      <td><b>5</b></td>
      <td>NGO + Collector</td>
      <td>Accept Flow, Scheduling, Collector Workflow</td>
    </tr>
    <tr>
      <td><b>6</b></td>
      <td>Admin + Notifications</td>
      <td>Admin Dashboard, NGO Verification, Legal Pages, Repo Setup</td>
    </tr>
  </tbody>
</table>

<hr />

<h2>Developer Setup</h2>

<h3>1) Clone the repository</h3>
<pre><code>git clone &lt;repo-url&gt;
cd Plateful
</code></pre>

<h3>2) Install dependencies (if using CocoaPods)</h3>
<pre><code>pod install
</code></pre>

<h3>3) Open the workspace</h3>
<pre><code>open Plateful.xcworkspace
</code></pre>

<h3>4) Firebase configuration</h3>
<ul>
  <li>Drag <code>GoogleService-Info.plist</code> into Xcode</li>
  <li>Ensure it is included in the app target</li>
</ul>

<h3>5) Cloudinary configuration</h3>
<p>
  Add your Cloudinary configuration values to:
</p>
<pre><code>/Services/CloudinaryService.swift
</code></pre>

<hr />

<h2>Admin Reports & Insights</h2>
<ul>
  <li>Total donations</li>
  <li>Pending pickups</li>
  <li>Verified NGOs</li>
  <li>Activity timeline</li>
</ul>

<hr />

<h2>Legal Pages</h2>
<p>Located under <code>/documentation/</code>:</p>
<ul>
  <li>FAQ</li>
  <li>Privacy Policy</li>
  <li>Terms &amp; Conditions</li>
</ul>

<hr />

<h2>License</h2>
<p>© 2025 Plateful Team — All Rights Reserved.</p>
