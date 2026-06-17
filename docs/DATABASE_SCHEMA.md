\# PharmaConnect Database Schema



Version: 1.0



Status: Design Freeze Approved



Database Engine: PostgreSQL (Supabase)



\---



\# 1. Database Principles



The database must support:



\* Multi-country deployment

\* Healthcare professionals

\* Pharmaceutical companies

\* Product discovery

\* Advertising

\* Analytics

\* Future platform expansion



Design goals:



\* Scalability

\* Security

\* Performance

\* Maintainability



Primary Key Type:



\* UUID



Timestamp Fields:



\* created\_at

\* updated\_at



Deletion Strategy:



\* Soft delete preferred

\* Historical records preserved whenever possible



\---



\# 2. Geography Tables



\## countries



Purpose:



Supported countries.



Columns:



\* id

\* name

\* iso\_code

\* is\_active

\* created\_at



Examples:



\* Iraq

\* Jordan

\* Saudi Arabia

\* UAE



\---



\## cities



Purpose:



Cities within supported countries.



Columns:



\* id

\* country\_id

\* name

\* is\_active

\* created\_at



Relationship:



country



↓



many cities



\---



\# 3. Identity Tables



\## profiles



Purpose:



Master user profile table.



Columns:



\* id

\* auth\_user\_id

\* full\_name

\* email

\* phone

\* role

\* country\_id

\* city\_id

\* status

\* created\_at

\* updated\_at



Role Values:



\* healthcare\_professional

\* company\_user

\* admin

\* super\_admin



Status Values:



\* pending

\* active

\* suspended

\* archived



\---



\## specialties



Purpose:



Defines healthcare specialties and pharmacy practice areas.



Columns:



\* id

\* specialty\_name

\* profession\_type

\* is\_active

\* created\_at

\* updated\_at



Profession Type Values:



\* physician

\* pharmacist

\* general



Examples:



Physician:



\* Internal Medicine

\* Respiratory Medicine

\* Cardiology

\* Pediatrics



Pharmacist:



\* Clinical Pharmacy

\* Hospital Pharmacy

\* Community Pharmacy



Rules:



\* Managed by administrators only.



\---



\## healthcare\_professionals



Purpose:



Healthcare professional details.



Columns:



\* id

\* profile\_id

\* profession\_type

\* specialty\_id

\* workplace

\* license\_number

\* verification\_status

\* approved\_by

\* approved\_at

\* created\_at

\* updated\_at



Profession Types:



\* physician

\* pharmacist



Verification Status:



\* pending

\* approved

\* rejected

\* documents\_requested



\---



\## professional\_documents



Purpose:



Optional verification documents.



Columns:



\* id

\* healthcare\_professional\_id

\* document\_type

\* file\_url

\* status

\* reviewed\_by

\* reviewed\_at

\* created\_at



Document Type Examples:



\* medical\_syndicate\_id

\* pharmacy\_syndicate\_id

\* ministry\_of\_health\_id

\* board\_id

\* residency\_id



Status Values:



\* pending

\* approved

\* rejected

\# 4. Company Tables



\## companies



Purpose:



Represents pharmaceutical companies, scientific offices, manufacturers, distributors, and authorized healthcare industry organizations.



Columns:



\* id

\* owner\_profile\_id

\* country\_id

\* city\_id

\* company\_name

\* legal\_name

\* description

\* logo\_url

\* website\_url

\* contact\_email

\* contact\_phone

\* status

\* verified\_by

\* verified\_at

\* created\_at

\* updated\_at



Status Values:



\* pending

\* verified

\* suspended

\* archived



Rules:



\* Only verified companies may publish public products.

\* A company may contain multiple users.

\* Products are retained even if the company becomes inactive.

\* Companies are responsible for all information they publish.



\---



\## company\_users



Purpose:



Links company accounts to user profiles.



Columns:



\* id

\* company\_id

\* profile\_id

\* company\_role

\* is\_active

\* created\_at

\* updated\_at



Company Role Values:



\* company\_admin

\* marketing\_manager

\* product\_manager

\* representative

\* viewer



Rules:



\* One company may have many users.

\* One profile may belong to only one company in MVP.

\* Company users can only access data belonging to their company.



Permission Summary:



company\_admin



\* Manage company profile

\* Manage company users

\* Manage products

\* View analytics



marketing\_manager



\* Manage campaigns

\* View analytics



product\_manager



\* Manage products

\* Upload brochures

\* Upload images



representative



\* View assigned products

\* View company information



viewer



\* Read-only access



\---



\## company\_social\_links



Purpose:



Stores official company external links.



Columns:



\* id

\* company\_id

\* platform

\* url

\* is\_active

\* created\_at

\* updated\_at



Platform Values:



\* website

\* facebook

\* linkedin

\* instagram

\* youtube

\* x\_twitter



Rules:



\* Social links are optional.

\* Visible on public company profiles.

\* Managed only by company users belonging to the company.



\---



\## company\_documents



Purpose:



Administrative company verification documents.



Columns:



\* id

\* company\_id

\* document\_type

\* file\_url

\* status

\* reviewed\_by

\* reviewed\_at

\* created\_at



Document Types:



\* commercial\_registration

\* scientific\_office\_license

\* authorization\_letter

\* other



Status Values:



\* pending

\* approved

\* rejected



Rules:



\* Documents are private.

\* Not visible to healthcare professionals.

\* May be requested by administrators when necessary.



\---



\# 5. Product Taxonomy Tables



\## drug\_classes



Purpose:



Defines pharmaceutical classification hierarchy.



Columns:



\* id

\* class\_name

\* parent\_class\_id

\* is\_active

\* created\_at

\* updated\_at



Examples:



\* Respiratory Drugs

\* Cardiovascular Drugs

\* Anti-Infectives

\* Endocrine Drugs



Hierarchy Example:



Respiratory Drugs



↓



ICS/LABA



↓



Specific Products



Rules:



\* Supports hierarchical structure.

\* Managed by administrators only.



\---



\## generic\_drugs



Purpose:



Master list of active pharmaceutical ingredients.



Columns:



\* id

\* generic\_name

\* drug\_class\_id

\* description

\* is\_active

\* created\_at

\* updated\_at



Examples:



\* Rosuvastatin

\* Budesonide + Formoterol

\* Sacubitril + Valsartan

\* Amoxicillin + Clavulanate



Rules:



\* Generic drugs are created centrally.

\* Companies select existing generic drugs.

\* Duplicate generic records are not allowed.

\* Supports generic landing pages.



Benefits:



\* Search consistency.

\* Better analytics.

\* Future AI compatibility.

\# 8. Events Tables



\## events



Purpose:



Stores educational, scientific, promotional, and platform activities.



Ownership Types:



\* Company Event

\* Platform Event



Columns:



\* id

\* company\_id

\* created\_by

\* title

\* description

\* event\_type

\* event\_date

\* event\_location

\* registration\_link

\* is\_sponsored

\* status

\* created\_at

\* updated\_at



Event Type Values:



\* conference

\* symposium

\* webinar

\* workshop

\* training\_course

\* other



Status Values:



\* draft

\* active

\* cancelled

\* archived



Rules:



\* company\_id may be null for platform events.

\* Company events belong to a company.

\* Platform events are created by administrators.



\---



\## event\_registrations



Purpose:



Stores healthcare professional registrations.



Columns:



\* id

\* event\_id

\* healthcare\_professional\_id

\* registration\_date

\* attendance\_status



Attendance Status Values:



\* registered

\* attended

\* absent



Rules:



\* One registration per user per event.



Unique Constraint:



event\_id + healthcare\_professional\_id



\---



\# 9. Campaign Tables



\## campaigns



Purpose:



Stores promotional and advertising campaigns.



Columns:



\* id

\* company\_id

\* title

\* description

\* campaign\_type

\* target\_country\_id

\* target\_city\_id

\* target\_specialty\_id

\* start\_date

\* end\_date

\* status

\* created\_at

\* updated\_at



Campaign Type Values:



\* featured\_product

\* featured\_company

\* banner\_campaign

\* sponsored\_event



Status Values:



\* draft

\* active

\* paused

\* completed

\* archived



Rules:



\* Campaigns belong to companies.

\* Campaigns may target specialties.

\* Campaigns may target cities.

\* Campaigns are used for monetization.



\---



\# 10. Subscription Tables



\## subscription\_plans



Purpose:



Defines available commercial plans.



Columns:



\* id

\* plan\_name

\* monthly\_price

\* yearly\_price

\* max\_products

\* max\_company\_users

\* analytics\_level

\* created\_at

\* updated\_at



Plan Values:



\* free

\* professional

\* enterprise



Rules:



\* Managed by administrators only.

\* Used for future monetization.



\---



\## company\_subscriptions



Purpose:



Links companies to subscription plans.



Columns:



\* id

\* company\_id

\* subscription\_plan\_id

\* start\_date

\* end\_date

\* status

\* created\_at

\* updated\_at



Status Values:



\* active

\* expired

\* cancelled

\* suspended



Rules:



\* One company may have only one active subscription.

\* Historical subscriptions are preserved.

\# 11. Notification Tables



\## notifications



Purpose:



Stores notifications delivered to platform users.



Columns:



\* id

\* profile\_id

\* title

\* message

\* notification\_type

\* is\_read

\* created\_at



Notification Type Values:



\* product\_update

\* event\_announcement

\* campaign

\* system\_message

\* account\_update



Rules:



\* Notifications belong to a single user.

\* Read status is tracked.

\* Notifications remain available for historical reference.



\---



\## notification\_preferences



Purpose:



Stores user notification preferences.



Columns:



\* id

\* profile\_id

\* product\_updates

\* event\_notifications

\* marketing\_notifications

\* system\_notifications

\* created\_at

\* updated\_at



Rules:



\* One preference record per user.



Unique Constraint:



profile\_id



\---



\# 12. Reporting Tables



\## reports



Purpose:



Allows users to report issues related to platform content.



Columns:



\* id

\* reporter\_profile\_id

\* target\_type

\* target\_id

\* reason

\* description

\* status

\* reviewed\_by

\* reviewed\_at

\* created\_at



Target Type Values:



\* product

\* company

\* event

\* campaign



Reason Values:



\* incorrect\_information

\* duplicate\_content

\* misleading\_content

\* inappropriate\_content

\* other



Status Values:



\* open

\* under\_review

\* resolved

\* rejected



Rules:



\* Reports cannot be modified after submission.

\* Reports are reviewed by administrators.



\---



\# 13. Audit Tables



\## audit\_logs



Purpose:



Records critical platform actions.



Columns:



\* id

\* actor\_profile\_id

\* action

\* target\_type

\* target\_id

\* old\_data

\* new\_data

\* created\_at



Examples:



\* Product Created

\* Product Updated

\* Product Archived

\* Company Verified

\* Company Suspended

\* Campaign Activated

\* Subscription Changed



Rules:



\* Audit logs are immutable.

\* No update operations allowed.

\* No delete operations allowed.

\* Visible only to administrators.



\---



\# 14. Analytics Tables



\## analytics\_events



Purpose:



Stores measurable user interactions.



Columns:



\* id

\* profile\_id

\* company\_id

\* target\_type

\* target\_id

\* event\_type

\* country\_id

\* city\_id

\* created\_at



Target Type Values:



\* product

\* company

\* event

\* campaign



Event Type Values:



\* product\_view

\* company\_view

\* brochure\_download

\* event\_view

\* event\_registration

\* campaign\_click

\* favorite\_product

\* favorite\_company



Rules:



\* Analytics data is append-only.

\* Records are never updated.

\* Used for aggregated reporting.



\---



\## search\_events



Purpose:



Stores search activity.



Columns:



\* id

\* profile\_id

\* search\_query

\* search\_type

\* results\_count

\* created\_at



Search Type Values:



\* generic

\* brand

\* company

\* drug\_class



Rules:



\* Used for analytics.

\* Used for future trend analysis.

\* Used for future market intelligence.

\# 15. Storage Buckets



Purpose:



Defines Supabase Storage structure.



\---



\## company-logos



Stores company logo images.



Access:



\* Company users can upload and update their own logo.

\* Public read access for approved companies.



\---



\## product-images



Stores product images.



Access:



\* Company users can upload images for their own products.

\* Public read access for approved products.



\---



\## package-images



Stores packaging images.



Access:



\* Company users can upload package images.

\* Public read access for approved products.



\---



\## brochures



Stores PDF brochures and product documents.



Access:



\* Company users can upload brochures.

\* Healthcare professionals can download approved brochures.



\---



\## verification-documents



Stores verification and administrative documents.



Access:



\* Private access only.

\* Available to administrators.

\* Available to the document owner when appropriate.



Rules:



\* Verification documents are never public.



\---



\# 16. Index Strategy



Purpose:



Maintain fast search performance and efficient filtering.



\---



Products



Indexes:



\* brand\_name

\* generic\_drug\_id

\* company\_id

\* country\_id

\* status



\---



Companies



Indexes:



\* company\_name

\* status



\---



Generic Drugs



Indexes:



\* generic\_name



\---



Healthcare Professionals



Indexes:



\* specialty\_id

\* country\_id

\* city\_id



\---



Events



Indexes:



\* event\_date

\* status



\---



Campaigns



Indexes:



\* company\_id

\* status

\* start\_date

\* end\_date



\---



Analytics



Indexes:



\* company\_id

\* target\_type

\* event\_type



\---



Search Events



Indexes:



\* search\_query

\* search\_type



\---



\# 17. Database Relationships Summary



Countries



↓



Cities



↓



Profiles



\---



Profiles



↓



Healthcare Professionals



\---



Profiles



↓



Company Users



↓



Companies



\---



Companies



↓



Products



\---



Generic Drugs



↓



Products



\---



Products



↓



Product Specialties



↓



Specialties



\---



Healthcare Professionals



↓



Favorite Products



↓



Products



\---



Healthcare Professionals



↓



Favorite Companies



↓



Companies



\---



Companies



↓



Campaigns



\---



Companies



↓



Events



\---



Events



↓



Event Registrations



↓



Healthcare Professionals



\---



\# 18. Database Rules



Mandatory Rules:



\* UUID primary keys.

\* Foreign key constraints enforced.

\* Soft delete preferred over hard delete.

\* Historical records preserved whenever possible.

\* RLS enabled on all business tables.

\* Audit logs are immutable.

\* Analytics tables are append-only.

\* Multi-country support enabled.

\* Future expansion support maintained.



\---



\# 19. Database Success Criteria



The schema is considered successful when it:



\* Supports healthcare professionals.

\* Supports pharmaceutical companies.

\* Supports product publishing.

\* Supports product discovery.

\* Supports advertising campaigns.

\* Supports subscriptions.

\* Supports analytics.

\* Supports future regional expansion.



\---



End of Document



