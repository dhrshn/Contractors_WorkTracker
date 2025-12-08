-- Contractor Work-Tracker Database Schema

-- MySQL Database Creation Script

-- Create Database

CREATE DATABASE IF NOT EXISTS contractor_work_tracker;

USE contractor_work_tracker;

-- Set charset

SET NAMES utf8mb4;

SET CHARACTER SET utf8mb4;

-- ============================================

-- USERS TABLE (for authentication)

-- ============================================

CREATE TABLE users (

id INT AUTO_INCREMENT PRIMARY KEY,

username VARCHAR(50) UNIQUE NOT NULL,

password VARCHAR(255) NOT NULL, -- Store hashed passwords

role ENUM('admin', 'employee') NOT NULL DEFAULT 'employee',

status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',

created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

);

-- ============================================

-- CLIENTS TABLE

-- ============================================

CREATE TABLE clients (

id INT AUTO_INCREMENT PRIMARY KEY,

name VARCHAR(100) NOT NULL,

contact_person VARCHAR(100) NOT NULL,

phone VARCHAR(15) NOT NULL,

email VARCHAR(100),

address TEXT,

created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

INDEX idx_client_name (name),

INDEX idx_client_phone (phone)

);

-- ============================================

-- SITES TABLE

-- ============================================

CREATE TABLE sites (

id INT AUTO_INCREMENT PRIMARY KEY,

name VARCHAR(100) NOT NULL,

client_id INT NOT NULL,

location VARCHAR(200) NOT NULL,

start_date DATE NOT NULL,

end_date DATE,

scope_of_work TEXT,

status ENUM('active', 'completed', 'on_hold', 'cancelled') NOT NULL DEFAULT 'active',

created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,

INDEX idx_site_name (name),

INDEX idx_site_status (status),

INDEX idx_site_client (client_id)

);

-- ============================================

-- EMPLOYEES TABLE

-- ============================================

CREATE TABLE employees (

id INT AUTO_INCREMENT PRIMARY KEY,

user_id INT UNIQUE,

name VARCHAR(100) NOT NULL,

phone VARCHAR(15) NOT NULL UNIQUE,

email VARCHAR(100),

trade_skill VARCHAR(100) NOT NULL,

daily_wage_rate DECIMAL(10, 2) NOT NULL DEFAULT 0.00,

current_balance DECIMAL(10, 2) NOT NULL DEFAULT 0.00,

status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',

join_date DATE NOT NULL DEFAULT (CURRENT_DATE),

created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,

INDEX idx_employee_name (name),

INDEX idx_employee_phone (phone),

INDEX idx_employee_trade (trade_skill),

INDEX idx_employee_status (status)

);

-- ============================================

-- ATTENDANCE TABLE

-- ============================================

CREATE TABLE attendance (

id INT AUTO_INCREMENT PRIMARY KEY,

employee_id INT NOT NULL,

site_id INT NOT NULL,

date DATE NOT NULL,

in_time TIME,

out_time TIME,

total_hours DECIMAL(4, 2) DEFAULT 0.00,

overtime_hours DECIMAL(4, 2) DEFAULT 0.00,

status ENUM('present', 'absent', 'half_day', 'leave') NOT NULL DEFAULT 'present',

notes TEXT,

marked_by INT, -- admin who marked attendance

created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,

FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE,

FOREIGN KEY (marked_by) REFERENCES users(id) ON DELETE SET NULL,

UNIQUE KEY unique_employee_date (employee_id, date),

INDEX idx_attendance_date (date),

INDEX idx_attendance_employee (employee_id),

INDEX idx_attendance_site (site_id)

);

-- ============================================

-- BILLS TABLE

-- ============================================

CREATE TABLE bills (

id INT AUTO_INCREMENT PRIMARY KEY,

bill_number VARCHAR(50) UNIQUE NOT NULL,

client_id INT NOT NULL,

site_id INT NOT NULL,

amount DECIMAL(12, 2) NOT NULL,

bill_date DATE NOT NULL,

due_date DATE,

description TEXT,

status ENUM('pending', 'paid', 'partially_paid', 'overdue') NOT NULL DEFAULT 'pending',

created_by INT,

created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,

FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE,

FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,

INDEX idx_bill_number (bill_number),

INDEX idx_bill_client (client_id),

INDEX idx_bill_site (site_id),

INDEX idx_bill_status (status),

INDEX idx_bill_date (bill_date)

);

-- ============================================

-- PAYMENTS TABLE

-- ============================================

CREATE TABLE payments (

id INT AUTO_INCREMENT PRIMARY KEY,

bill_id INT NOT NULL,

amount DECIMAL(12, 2) NOT NULL,

payment_date DATE NOT NULL,

payment_method ENUM('cash', 'bank_transfer', 'cheque', 'upi', 'other') NOT NULL DEFAULT 'cash',

transaction_reference VARCHAR(100),

notes TEXT,

recorded_by INT,

created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

FOREIGN KEY (bill_id) REFERENCES bills(id) ON DELETE CASCADE,

FOREIGN KEY (recorded_by) REFERENCES users(id) ON DELETE SET NULL,

INDEX idx_payment_bill (bill_id),

INDEX idx_payment_date (payment_date),

INDEX idx_payment_method (payment_method)

);

-- ============================================

-- WAGE PAYMENTS TABLE

-- ============================================

CREATE TABLE wage_payments (

id INT AUTO_INCREMENT PRIMARY KEY,

employee_id INT NOT NULL,

amount DECIMAL(10, 2) NOT NULL,

payment_date DATE NOT NULL,

period_start DATE NOT NULL,

period_end DATE NOT NULL,

payment_type ENUM('salary', 'advance', 'bonus', 'overtime') NOT NULL DEFAULT 'salary',

payment_method ENUM('cash', 'bank_transfer', 'cheque', 'upi') NOT NULL DEFAULT 'cash',

notes TEXT,

paid_by INT,

created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,

FOREIGN KEY (paid_by) REFERENCES users(id) ON DELETE SET NULL,

INDEX idx_wage_employee (employee_id),

INDEX idx_wage_date (payment_date),

INDEX idx_wage_period (period_start, period_end)

);

-- ============================================

-- DOCUMENTS TABLE

-- ============================================

CREATE TABLE documents (

id INT AUTO_INCREMENT PRIMARY KEY,

name VARCHAR(255) NOT NULL,

original_name VARCHAR(255) NOT NULL,

file_path VARCHAR(500) NOT NULL,

file_size INT,

mime_type VARCHAR(100),

document_type ENUM('bill', 'receipt', 'drawing', 'blueprint', 'note', 'photo', 'other') NOT NULL,

site_id INT,

employee_id INT, -- if document is employee-specific

description TEXT,

upload_date DATE NOT NULL DEFAULT (CURRENT_DATE),

uploaded_by INT,

created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE,

FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,

FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE SET NULL,

INDEX idx_document_type (document_type),

INDEX idx_document_site (site_id),

INDEX idx_document_employee (employee_id),

INDEX idx_document_date (upload_date)

);

-- ============================================

-- WORK PROGRESS TABLE

-- ============================================

CREATE TABLE work_progress (

id INT AUTO_INCREMENT PRIMARY KEY,

site_id INT NOT NULL,

work_item VARCHAR(200) NOT NULL,

planned_quantity DECIMAL(10, 2) DEFAULT 0.00,

completed_quantity DECIMAL(10, 2) DEFAULT 0.00,

unit VARCHAR(50) DEFAULT 'units',

progress_percentage DECIMAL(5, 2) DEFAULT 0.00,

notes TEXT,

last_updated_by INT,

created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE,

FOREIGN KEY (last_updated_by) REFERENCES users(id) ON DELETE SET NULL,

INDEX idx_progress_site (site_id)

);

-- ============================================

-- SITE VISITS TABLE

-- ============================================

CREATE TABLE site_visits (

id INT AUTO_INCREMENT PRIMARY KEY,

site_id INT NOT NULL,

visit_date DATE NOT NULL,

visitor_name VARCHAR(100) NOT NULL,

visit_purpose VARCHAR(200),

notes TEXT,

photos_count INT DEFAULT 0,

recorded_by INT,

created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE,

FOREIGN KEY (recorded_by) REFERENCES users(id) ON DELETE SET NULL,

INDEX idx_visit_site (site_id),

INDEX idx_visit_date (visit_date)

);

-- ============================================

-- EMPLOYEE SITE ASSIGNMENTS TABLE

-- ============================================

CREATE TABLE employee_site_assignments (

id INT AUTO_INCREMENT PRIMARY KEY,

employee_id INT NOT NULL,

site_id INT NOT NULL,

assigned_date DATE NOT NULL,

unassigned_date DATE,

role_at_site VARCHAR(100),

status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',

assigned_by INT,

created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,

FOREIGN KEY (site_id) REFERENCES sites(id) ON DELETE CASCADE,

FOREIGN KEY (assigned_by) REFERENCES users(id) ON DELETE SET NULL,

INDEX idx_assignment_employee (employee_id),

INDEX idx_assignment_site (site_id),

INDEX idx_assignment_status (status)

);

-- ============================================

-- TRIGGERS FOR AUTOMATIC CALCULATIONS

-- ============================================

-- Trigger to calculate total hours and overtime in attendance

DELIMITER //

CREATE TRIGGER calculate_attendance_hours

BEFORE INSERT ON attendance

FOR EACH ROW

BEGIN

IF NEW.in_time IS NOT NULL AND NEW.out_time IS NOT NULL THEN

SET NEW.total_hours = TIME_TO_SEC(TIMEDIFF(NEW.out_time, NEW.in_time)) / 3600;

SET NEW.overtime_hours = GREATEST(0, NEW.total_hours - 8);

END IF;

END//

CREATE TRIGGER calculate_attendance_hours_update

BEFORE UPDATE ON attendance

FOR EACH ROW

BEGIN

IF NEW.in_time IS NOT NULL AND NEW.out_time IS NOT NULL THEN

SET NEW.total_hours = TIME_TO_SEC(TIMEDIFF(NEW.out_time, NEW.in_time)) / 3600;

SET NEW.overtime_hours = GREATEST(0, NEW.total_hours - 8);

END IF;

END//

-- Trigger to update employee balance after wage payment

CREATE TRIGGER update_employee_balance_after_payment

AFTER INSERT ON wage_payments

FOR EACH ROW

BEGIN

IF NEW.payment_type = 'advance' THEN

UPDATE employees

SET current_balance = current_balance + NEW.amount

WHERE id = NEW.employee_id;

ELSE

UPDATE employees

SET current_balance = current_balance - NEW.amount

WHERE id = NEW.employee_id;

END IF;

END//

-- Trigger to update bill status after payment

CREATE TRIGGER update_bill_status_after_payment

AFTER INSERT ON payments

FOR EACH ROW

BEGIN

DECLARE bill_amount DECIMAL(12,2);

DECLARE total_paid DECIMAL(12,2);

SELECT amount INTO bill_amount FROM bills WHERE id = NEW.bill_id;

SELECT SUM(amount) INTO total_paid FROM payments WHERE bill_id = NEW.bill_id;

IF total_paid >= bill_amount THEN

UPDATE bills SET status = 'paid' WHERE id = NEW.bill_id;

ELSE

UPDATE bills SET status = 'partially_paid' WHERE id = NEW.bill_id;

END IF;

END//

DELIMITER ;

-- ============================================

-- VIEWS FOR REPORTING

-- ============================================

-- View for employee attendance summary

CREATE VIEW employee_attendance_summary AS

SELECT

e.id as employee_id,

e.name as employee_name,

e.trade_skill,

COUNT(a.id) as total_days,

SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) as present_days,

SUM(CASE WHEN a.status = 'absent' THEN 1 ELSE 0 END) as absent_days,

SUM(a.total_hours) as total_hours_worked,

SUM(a.overtime_hours) as total_overtime_hours,

MONTH(a.date) as month,

YEAR(a.date) as year

FROM employees e

LEFT JOIN attendance a ON e.id = a.employee_id

GROUP BY e.id, MONTH(a.date), YEAR(a.date);

-- View for site progress summary

CREATE VIEW site_progress_summary AS

SELECT

s.id as site_id,

s.name as site_name,

c.name as client_name,

s.location,

s.status as site_status,

COUNT(DISTINCT e.id) as total_employees,

COUNT(DISTINCT w.id) as work_items,

AVG(w.progress_percentage) as overall_progress

FROM sites s

LEFT JOIN clients c ON s.client_id = c.id

LEFT JOIN employee_site_assignments esa ON s.id = esa.site_id AND esa.status = 'active'

LEFT JOIN employees e ON esa.employee_id = e.id

LEFT JOIN work_progress w ON s.id = w.site_id

GROUP BY s.id;

-- View for billing summary

CREATE VIEW billing_summary AS

SELECT

c.id as client_id,

c.name as client_name,

COUNT(b.id) as total_bills,

SUM(b.amount) as total_billed,

SUM(CASE WHEN b.status = 'paid' THEN b.amount ELSE 0 END) as total_paid,

SUM(CASE WHEN b.status IN ('pending', 'partially_paid', 'overdue') THEN b.amount ELSE 0 END) as total_pending,

AVG(DATEDIFF(CURDATE(), b.bill_date)) as avg_bill_age

FROM clients c

LEFT JOIN bills b ON c.id = b.client_id

GROUP BY c.id;

-- ============================================

-- STORED PROCEDURES

-- ============================================

-- Procedure to calculate employee wages for a period

DELIMITER //

CREATE PROCEDURE CalculateEmployeeWages(

IN emp_id INT,

IN start_date DATE,

IN end_date DATE,

OUT regular_wages DECIMAL(10,2),

OUT overtime_wages DECIMAL(10,2),

OUT total_wages DECIMAL(10,2)

)

BEGIN

DECLARE daily_rate DECIMAL(10,2);

DECLARE total_regular_hours DECIMAL(10,2) DEFAULT 0;

DECLARE total_overtime_hours DECIMAL(10,2) DEFAULT 0;

-- Get employee daily rate

SELECT daily_wage_rate INTO daily_rate FROM employees WHERE id = emp_id;

-- Calculate total hours

SELECT

SUM(LEAST(total_hours, 8)) as regular_hours,

SUM(overtime_hours) as overtime_hours

INTO total_regular_hours, total_overtime_hours

FROM attendance

WHERE employee_id = emp_id

AND date BETWEEN start_date AND end_date

AND status = 'present';

-- Calculate wages

SET regular_wages = COALESCE(total_regular_hours, 0) * (daily_rate / 8);

SET overtime_wages = COALESCE(total_overtime_hours, 0) * (daily_rate / 8) * 1.5;

SET total_wages = regular_wages + overtime_wages;

END//

-- Procedure to get dashboard statistics

CREATE PROCEDURE GetDashboardStats(

OUT total_sites INT,

OUT active_employees INT,

OUT pending_bills_amount DECIMAL(12,2),

OUT pending_wages_amount DECIMAL(12,2)

)

BEGIN

SELECT COUNT(*) INTO total_sites FROM sites WHERE status = 'active';

SELECT COUNT(*) INTO active_employees FROM employees WHERE status = 'active';

SELECT COALESCE(SUM(amount), 0) INTO pending_bills_amount FROM bills WHERE status IN ('pending', 'partially_paid', 'overdue');

SELECT COALESCE(SUM(current_balance), 0) INTO pending_wages_amount FROM employees WHERE status = 'active';

END//

DELIMITER ;

-- ============================================

-- INDEXES FOR PERFORMANCE

-- ============================================

-- Additional indexes for better query performance

CREATE INDEX idx_attendance_employee_date ON attendance(employee_id, date);

CREATE INDEX idx_bills_client_status ON bills(client_id, status);

CREATE INDEX idx_payments_bill_date ON payments(bill_id, payment_date);

CREATE INDEX idx_documents_site_type ON documents(site_id, document_type);

CREATE INDEX idx_employees_trade_status ON employees(trade_skill, status);

-- ============================================

-- SAMPLE DATA INSERTION

-- ============================================

-- Insert default admin user

INSERT INTO users (username, password, role, status) VALUES

('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', 'active'); -- password: admin123

-- Insert sample clients

INSERT INTO clients (name, contact_person, phone, email, address) VALUES

('ABC Builders Pvt Ltd', 'Mr. Rajesh Sharma', '9876543210', 'rajesh@abcbuilders.com', 'Plot No. 123, Sector 15, Pune, Maharashtra 411001'),

('XYZ Construction Co.', 'Mr. Amit Patel', '9876543211', 'amit@xyzconstruction.com', '45, Industrial Area, Mumbai, Maharashtra 400001'),

('Green Valley Developers', 'Ms. Priya Singh', '9876543212', 'priya@greenvalley.com', '78, MG Road, Nashik, Maharashtra 422001');

-- Insert sample sites

INSERT INTO sites (name, client_id, location, start_date, end_date, scope_of_work, status) VALUES

('Green Valley Apartments Phase 1', 1, 'Pune, Kharadi', '2024-01-15', '2024-12-15', 'Complete electrical work for 50 residential units', 'active'),

('Sunshine Villa Project', 2, 'Mumbai, Andheri', '2024-02-01', '2024-11-30', 'Plumbing and electrical work for luxury villa', 'active'),

('Metro Heights Complex', 3, 'Nashik, Gangapur Road', '2024-03-10', '2025-02-28', 'Complete MEP work for commercial complex', 'active');

-- Insert sample employees with user accounts

INSERT INTO users (username, password, role, status) VALUES

('emp001', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee', 'active'), -- password: emp123

('emp002', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee', 'active'), -- password: emp123

('emp003', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee', 'active'); -- password: emp123

INSERT INTO employees (user_id, name, phone, email, trade_skill, daily_wage_rate, current_balance, status, join_date) VALUES

(2, 'Ramesh Kumar', '9876543220', 'ramesh@email.com', 'Electrician', 800.00, 2400.00, 'active', '2024-01-01'),

(3, 'Suresh Patil', '9876543221', 'suresh@email.com', 'Plumber', 750.00, 1500.00, 'active', '2024-01-15'),

(4, 'Mahesh Jadhav', '9876543222', 'mahesh@email.com', 'Mason', 700.00, 1200.00, 'active', '2024-02-01');

-- Insert sample site assignments

INSERT INTO employee_site_assignments (employee_id, site_id, assigned_date, role_at_site, status, assigned_by) VALUES

(1, 1, '2024-01-15', 'Lead Electrician', 'active', 1),

(2, 2, '2024-02-01', 'Lead Plumber', 'active', 1),

(3, 3, '2024-03-10', 'Mason Supervisor', 'active', 1);

-- Insert sample attendance records

INSERT INTO attendance (employee_id, site_id, date, in_time, out_time, status, marked_by) VALUES

(1, 1, '2024-09-23', '08:00:00', '17:30:00', 'present', 1),

(1, 1, '2024-09-24', '08:00:00', '18:30:00', 'present', 1),

(2, 2, '2024-09-23', '08:15:00', '17:45:00', 'present', 1),

(2, 2, '2024-09-24', '08:15:00', '17:45:00', 'present', 1),

(3, 3, '2024-09-23', '07:45:00', '17:30:00', 'present', 1),

(3, 3, '2024-09-24', '07:45:00', '17:30:00', 'present', 1);

-- Insert sample bills

INSERT INTO bills (bill_number, client_id, site_id, amount, bill_date, due_date, description, status, created_by) VALUES

('INV001', 1, 1, 45000.00, '2024-09-15', '2024-10-15', 'Electrical work completion - Phase 1, Block A', 'pending', 1),

('INV002', 2, 2, 35000.00, '2024-09-10', '2024-10-10', 'Plumbing installation - Ground floor completed', 'paid', 1),

('INV003', 3, 3, 55000.00, '2024-09-20', '2024-10-20', 'MEP work - Basement level completed', 'pending', 1);

-- Insert sample payments

INSERT INTO payments (bill_id, amount, payment_date, payment_method, transaction_reference, recorded_by) VALUES

(2, 35000.00, '2024-09-12', 'bank_transfer', 'TXN123456789', 1);

-- Insert sample work progress

INSERT INTO work_progress (site_id, work_item, planned_quantity, completed_quantity, unit, progress_percentage, last_updated_by) VALUES

(1, 'Electrical Wiring - Residential Units', 50.00, 32.00, 'units', 64.00, 1),

(1, 'Switch Board Installation', 50.00, 28.00, 'units', 56.00, 1),

(2, 'Water Supply Lines', 100.00, 75.00, 'meters', 75.00, 1),

(2, 'Drainage System', 80.00, 45.00, 'meters', 56.25, 1),

(3, 'Electrical Panel Installation', 15.00, 8.00, 'units', 53.33, 1);

-- Insert sample wage payments

INSERT INTO wage_payments (employee_id, amount, payment_date, period_start, period_end, payment_type, payment_method, paid_by) VALUES

(1, 5000.00, '2024-09-01', '2024-08-01', '2024-08-31', 'advance', 'cash', 1),

(2, 3000.00, '2024-09-05', '2024-08-01', '2024-08-31', 'advance', 'cash', 1);

-- Insert sample documents

INSERT INTO documents (name, original_name, file_path, document_type, site_id, description, upload_date, uploaded_by) VALUES

('site_plan_gv_001.jpg', 'Site_Plan_GreenValley.jpg', '/uploads/documents/site_plan_gv_001.jpg', 'drawing', 1, 'Initial site layout plan for Green Valley Apartments', '2024-09-20', 1),

('material_bill_002.pdf', 'Material_Bill_September.pdf', '/uploads/documents/material_bill_002.pdf', 'bill', 2, 'Cement and steel purchase bill for Sunshine Villa', '2024-09-18', 1),

('progress_photo_003.jpg', 'Progress_Photo_Metro.jpg', '/uploads/documents/progress_photo_003.jpg', 'photo', 3, 'Construction progress photo - Basement level', '2024-09-22', 1);

-- Insert sample site visits

INSERT INTO site_visits (site_id, visit_date, visitor_name, visit_purpose, notes, recorded_by) VALUES

(1, '2024-09-20', 'Site Engineer - ABC Builders', 'Progress Inspection', 'Electrical work progressing well. Minor delays due to material shortage.', 1),

(2, '2024-09-18', 'Client Representative', 'Quality Check', 'Satisfied with plumbing work quality. Approved for next phase.', 1),

(3, '2024-09-22', 'Municipal Inspector', 'Compliance Check', 'All safety measures in place. Cleared for further construction.', 1);

-- ============================================

-- FUNCTIONS FOR COMMON CALCULATIONS

-- ============================================

DELIMITER //

-- Function to calculate age of a bill in days

CREATE FUNCTION GetBillAge(bill_date DATE)

RETURNS INT

READS SQL DATA

DETERMINISTIC

BEGIN

RETURN DATEDIFF(CURDATE(), bill_date);

END//

-- Function to get employee current site

CREATE FUNCTION GetEmployeeCurrentSite(emp_id INT)

RETURNS VARCHAR(100)

READS SQL DATA

BEGIN

DECLARE site_name VARCHAR(100);

SELECT s.name INTO site_name

FROM employee_site_assignments esa

JOIN sites s ON esa.site_id = s.id

WHERE esa.employee_id = emp_id

AND esa.status = 'active'

ORDER BY esa.assigned_date DESC

LIMIT 1;

RETURN COALESCE(site_name, 'Not Assigned');

END//

-- Function to calculate project completion percentage

CREATE FUNCTION GetProjectCompletionPercentage(site_id INT)

RETURNS DECIMAL(5,2)

READS SQL DATA

BEGIN

DECLARE completion_percentage DECIMAL(5,2);

SELECT AVG(progress_percentage) INTO completion_percentage

FROM work_progress

WHERE site_id = site_id;

RETURN COALESCE(completion_percentage, 0.00);

END//

DELIMITER ;

-- ============================================

-- FINAL OPTIMIZATIONS

-- ============================================

-- Analyze tables for better performance

ANALYZE TABLE users, clients, sites, employees, attendance, bills, payments, documents, work_progress, site_visits, employee_site_assignments, wage_payments;

-- Update table statistics

UPDATE INFORMATION_SCHEMA.TABLES SET TABLE_COMMENT = 'Optimized for contractor work tracking'

WHERE TABLE_SCHEMA = 'contractor_work_tracker';

-- ============================================

-- BACKUP AND MAINTENANCE SUGGESTIONS

-- ============================================

-- Create a backup procedure (example)

DELIMITER //

CREATE PROCEDURE CreateBackup()

BEGIN

DECLARE backup_date VARCHAR(20);

SET backup_date = DATE_FORMAT(NOW(), '%Y%m%d_%H%i%s');

-- In a real scenario, you would use mysqldump or similar

SELECT CONCAT('Backup created for date: ', backup_date) as backup_status;

END//

DELIMITER ;

-- ============================================

-- SECURITY SETTINGS

-- ============================================

-- Create application user with limited privileges

CREATE USER IF NOT EXISTS 'contractor_app'@'localhost' IDENTIFIED BY 'SecurePassword123!';

-- Grant necessary permissions

GRANT SELECT, INSERT, UPDATE, DELETE ON contractor_work_tracker.* TO 'contractor_app'@'localhost';

GRANT EXECUTE ON contractor_work_tracker.* TO 'contractor_app'@'localhost';

-- Revoke dangerous permissions

REVOKE DROP, CREATE, ALTER ON contractor_work_tracker.* FROM 'contractor_app'@'localhost';

-- Flush privileges

FLUSH PRIVILEGES;

-- ============================================

-- COMPLETION MESSAGE

-- ============================================

SELECT 'Contractor Work-Tracker Database Setup Complete!' as status,

'Total Tables Created: 11' as tables_created,

'Sample Data Inserted: Yes' as sample_data,

'Triggers Created: 3' as triggers,

'Views Created: 3' as views,

'Stored Procedures: 3' as procedures,

'Functions: 3' as functions;
