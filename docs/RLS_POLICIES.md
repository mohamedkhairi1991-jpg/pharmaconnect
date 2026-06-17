\# PharmaConnect RLS Policies



Version: 1.0



Database Engine:



Supabase PostgreSQL



Status:



Approved



\---



\# 1. Security Principles



The platform follows a strict least-privilege model.



Users may only access data required for their role.



Sensitive information must never be exposed unnecessarily.



All business tables must have Row Level Security enabled.



\---



\# 2. Roles



Platform Roles:



\- healthcare\_professional

\- company\_user

\- admin

\- super\_admin



\---



\# 3. Healthcare Professional Permissions



Healthcare professionals may:



\- View approved products.

\- Search products.

\- Download approved brochures.

\- View approved companies.

\- Register for events.

\- Save favorite products.

\- Save favorite companies.

\- Submit reports.



Healthcare professionals may NOT:



\- Create products.

\- Edit products.

\- Create companies.

\- Access company analytics.

\- View private company documents.

\- Access administrative tools.



\---



\# 4. Pharmacist Permissions



Pharmacists follow the same permissions as healthcare professionals.



No additional administrative privileges are granted.



\---



\# 5. Company User Permissions



Company users may:



\- View their own company profile.

\- Edit their own company profile.

\- Manage their own products.

\- Upload brochures.

\- Upload product images.

\- Create campaigns.

\- Manage company events.

\- View company analytics.



Company users may NOT:



\- View competitor analytics.

\- Edit competitor products.

\- View private competitor files.

\- Access administrative tools.



\---



\# 6. Company Analytics Access



Company users may access:



\- Total product views.

\- Total brochure downloads.

\- Total favorites.

\- Views by country.

\- Views by city.

\- Views by specialty.



Company users may NOT access:



\- User names.

\- Emails.

\- Phone numbers.

\- Individual activity history.

\- Personally identifiable information.

\# 7. Table Policies



\## profiles



SELECT



\- User may view own profile.

\- Admin may view all profiles.

\- Super Admin may view all profiles.



INSERT



\- User may create own profile during registration.



UPDATE



\- User may update own profile.

\- Admin may update status fields.

\- Super Admin may update all fields.



DELETE



\- Not allowed.



\---



\## healthcare\_professionals



SELECT



\- Owner may view own record.

\- Admin may view all records.

\- Super Admin may view all records.



INSERT



\- Owner may create own record.



UPDATE



\- Owner may update non-verification fields.

\- Admin may update verification status.

\- Super Admin may update all fields.



DELETE



\- Not allowed.



\---



\## professional\_documents



SELECT



\- Owner may view own documents.

\- Admin may view all documents.

\- Super Admin may view all documents.



INSERT



\- Owner may upload own documents.



UPDATE



\- Admin may review documents.

\- Super Admin may review documents.



DELETE



\- Not allowed.



\---



\## companies



SELECT



\- Public users may view verified companies.

\- Company users may view their own company.

\- Admin may view all companies.

\- Super Admin may view all companies.



INSERT



\- Company user may create company application.



UPDATE



\- Company Admin may update own company.

\- Admin may update status.

\- Super Admin may update all fields.



DELETE



\- Not allowed.



\---



\## company\_users



SELECT



\- Company Admin may view users belonging to the same company.

\- Admin may view all.

\- Super Admin may view all.



INSERT



\- Company Admin may invite company users.



UPDATE



\- Company Admin may update company roles.



DELETE



\- Company Admin may deactivate users.



\---



\## company\_social\_links



SELECT



\- Public access.



INSERT



\- Company Admin.

\- Marketing Manager.



UPDATE



\- Company Admin.

\- Marketing Manager.



DELETE



\- Company Admin.



\---



\## company\_documents



SELECT



\- Company Admin.

\- Admin.

\- Super Admin.



INSERT



\- Company Admin.



UPDATE



\- Admin.

\- Super Admin.



DELETE



\- Not allowed.



\---



\## drug\_classes



SELECT



\- Public access.



INSERT



\- Admin.

\- Super Admin.



UPDATE



\- Admin.

\- Super Admin.



DELETE



\- Not allowed.



\---



\## generic\_drugs



SELECT



\- Public access.



INSERT



\- Admin.

\- Super Admin.



UPDATE



\- Admin.

\- Super Admin.



DELETE



\- Not allowed.



\---



\## specialties



SELECT



\- Public access.



INSERT



\- Admin.

\- Super Admin.



UPDATE



\- Admin.

\- Super Admin.



DELETE



\- Not allowed.

\# 8. Product Policies



\## products



SELECT



\- Public users may view active products.

\- Healthcare professionals may view active products.

\- Company users may view products belonging to their company.

\- Admin may view all products.

\- Super Admin may view all products.



INSERT



\- Company Admin.

\- Product Manager.



UPDATE



\- Company Admin.

\- Product Manager.

\- Admin.

\- Super Admin.



DELETE



\- Not allowed.



\---



\## product\_specialties



SELECT



\- Public access.



INSERT



\- Company Admin.

\- Product Manager.



UPDATE



\- Company Admin.

\- Product Manager.



DELETE



\- Company Admin.



\---



\## product\_search\_keywords



SELECT



\- Admin.

\- Super Admin.



INSERT



\- System Generated.



UPDATE



\- System Generated.



DELETE



\- Admin.

\- Super Admin.



\---



\# 9. Favorites Policies



\## favorite\_products



SELECT



\- Owner only.



INSERT



\- Owner only.



UPDATE



\- Not required.



DELETE



\- Owner only.



\---



\## favorite\_companies



SELECT



\- Owner only.



INSERT



\- Owner only.



UPDATE



\- Not required.



DELETE



\- Owner only.



\---



\# 10. Event Policies



\## events



SELECT



\- Public access for active events.



INSERT



\- Company Admin.

\- Marketing Manager.

\- Admin.

\- Super Admin.



UPDATE



\- Event owner.

\- Admin.

\- Super Admin.



DELETE



\- Not allowed.



\---



\## event\_registrations



SELECT



\- Owner may view own registrations.

\- Event owner may view registration count only.

\- Admin may view all.

\- Super Admin may view all.



INSERT



\- Healthcare professional.



UPDATE



\- Admin.

\- Super Admin.



DELETE



\- Owner may cancel registration.



\---



\# 11. Campaign Policies



\## campaigns



SELECT



\- Company users may view campaigns belonging to their company.

\- Admin may view all.

\- Super Admin may view all.



INSERT



\- Company Admin.

\- Marketing Manager.



UPDATE



\- Campaign owner.

\- Admin.

\- Super Admin.



DELETE



\- Not allowed.



\---



\# 12. Subscription Policies



\## subscription\_plans



SELECT



\- Public access.



INSERT



\- Super Admin only.



UPDATE



\- Super Admin only.



DELETE



\- Not allowed.



\---



\## company\_subscriptions



SELECT



\- Company Admin may view own subscription.

\- Admin may view all.

\- Super Admin may view all.



INSERT



\- Admin.

\- Super Admin.



UPDATE



\- Admin.

\- Super Admin.



DELETE



\- Not allowed.



\---



\# 13. Notification Policies



\## notifications



SELECT



\- Owner only.



INSERT



\- System.

\- Admin.



UPDATE



\- Owner may mark as read.



DELETE



\- Not allowed.



\---



\## notification\_preferences



SELECT



\- Owner only.



INSERT



\- Owner only.



UPDATE



\- Owner only.



DELETE



\- Not allowed.



\---



\# 14. Reporting Policies



\## reports



SELECT



\- Reporter may view own reports.

\- Admin may view all.

\- Super Admin may view all.



INSERT



\- Authenticated users.



UPDATE



\- Admin.

\- Super Admin.



DELETE



\- Not allowed.



\---



\# 15. Analytics Policies



\## analytics\_events



SELECT



\- Aggregated analytics only.

\- No raw user activity visible to companies.



Admin:



\- Full access.



Super Admin:



\- Full access.



INSERT



\- System generated only.



UPDATE



\- Not allowed.



DELETE



\- Not allowed.



\---



\## search\_events



SELECT



\- Admin.

\- Super Admin.



INSERT



\- System generated only.



UPDATE



\- Not allowed.



DELETE



\- Not allowed.



\---



\# 16. Audit Log Policies



\## audit\_logs



SELECT



\- Admin.

\- Super Admin.



INSERT



\- System generated only.



UPDATE



\- Not allowed.



DELETE



\- Not allowed.



Rules:



\- Immutable records.

\- Permanent historical trail.



\---



\# 17. Storage Policies



company-logos



\- Company users upload own files.

\- Public read access.



\---



product-images



\- Company users upload own files.

\- Public read access.



\---



package-images



\- Company users upload own files.

\- Public read access.



\---



brochures



\- Company users upload own files.

\- Healthcare professionals may download approved files.



\---



verification-documents



\- Private access.

\- Owner access.

\- Admin access.

\- Super Admin access.



\---



\# 18. Security Rules



Mandatory Rules



\- RLS enabled on all business tables.

\- Ownership checks enforced.

\- Company isolation enforced.

\- Audit logs immutable.

\- Analytics anonymized.

\- No personal data exposed to companies.

\- Soft delete preferred over hard delete.

\- Authentication required for all write operations.



\---



End of Document

