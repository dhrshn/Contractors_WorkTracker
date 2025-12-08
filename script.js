// Global Variables
let currentUser = null;
let userRole = null;

// Sample Data (Replace with actual database calls)
let clients = [];
let sites = [];
let employees = [];
let attendance = [];
let bills = [];
let payments = [];
let documents = [];

// Initialize the application
document.addEventListener('DOMContentLoaded', function() {
    // Set today's date as default
    const today = new Date().toISOString().split('T')[0];
    const attendanceDate = document.getElementById('attendanceDate');
    if (attendanceDate) {
        attendanceDate.value = today;
    }

    // Initialize modal close functionality
    initializeModals();

    // Initialize form handlers
    initializeForms();

    // Load sample data
    loadSampleData();
});

// Authentication Functions
function handleLogin(event) {
    event.preventDefault();
    
    const userType = document.getElementById('userType').value;
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;

    // Simple authentication (replace with actual database validation)
    if (userType === 'admin' && username === 'admin' && password === 'admin123') {
        currentUser = { id: 1, name: 'Admin User', role: 'admin', phone: '9876543210' };
        userRole = 'admin';
        showDashboard();
    } else if (userType === 'employee' && username === 'emp001' && password === 'emp123') {
        currentUser = { id: 1, name: 'John Doe', role: 'employee', phone: '9876543211' };
        userRole = 'employee';
        document.body.classList.add('employee-view');
        showDashboard();
    } else {
        showMessage('Invalid credentials. Please try again.', 'error', 'loginMessage');
    }
}

function showDashboard() {
    document.getElementById('loginSection').classList.add('hidden');
    document.getElementById('dashboardSection').classList.remove('hidden');
    document.getElementById('logoutBtn').style.display = 'block';
    document.getElementById('welcomeMsg').textContent = `Welcome, ${currentUser.name}`;
    updateProfileInfo();
    loadDashboardData();
}

function logout() {
    currentUser = null;
    userRole = null;
    document.body.classList.remove('employee-view');
    document.getElementById('loginSection').classList.remove('hidden');
    document.getElementById('dashboardSection').classList.add('hidden');
    document.getElementById('logoutBtn').style.display = 'none';
    document.getElementById('welcomeMsg').textContent = 'Welcome, Guest';
    // Reset form
    document.getElementById('loginForm').reset();
    clearMessage('loginMessage');
}

// Navigation Functions
function showSection(sectionName) {
    // Hide all dashboards
    const dashboards = document.querySelectorAll('.dashboard');
    dashboards.forEach(dashboard => {
        dashboard.classList.remove('active');
    });

    // Remove active class from all nav items
    const navItems = document.querySelectorAll('.nav-item');
    navItems.forEach(item => {
        item.classList.remove('active');
    });

    // Show selected dashboard
    document.getElementById(sectionName).classList.add('active');

    // Add active class to clicked nav item
    event.target.classList.add('active');

    // Load section-specific data
    loadSectionData(sectionName);
}

// Modal Functions
function initializeModals() {
    const modals = document.querySelectorAll('.modal');
    const closes = document.querySelectorAll('.close');

    closes.forEach(close => {
        close.onclick = function() {
            this.closest('.modal').style.display = 'none';
        }
    });

    window.onclick = function(event) {
        modals.forEach(modal => {
            if (event.target === modal) {
                modal.style.display = 'none';
            }
        });
    }
}

function openModal(modalId) {
    document.getElementById(modalId).style.display = 'block';
    
    // Load dropdown data for modals
    if (modalId === 'siteModal') {
        loadClientDropdown();
    } else if (modalId === 'attendanceModal') {
        loadEmployeeDropdown();
        loadSiteDropdown();
    } else if (modalId === 'billModal') {
        loadClientDropdown();
        loadSiteDropdown();
    } else if (modalId === 'documentModal') {
        loadSiteDropdown();
    }
}

function closeModal(modalId) {
    document.getElementById(modalId).style.display = 'none';
}

// Form Handlers
function initializeForms() {
    // Login form
    document.getElementById('loginForm').addEventListener('submit', handleLogin);

    // Client form
    document.getElementById('clientForm').addEventListener('submit', handleClientSubmit);

    // Site form
    document.getElementById('siteForm').addEventListener('submit', handleSiteSubmit);

    // Employee form
    document.getElementById('employeeForm').addEventListener('submit', handleEmployeeSubmit);

    // Attendance form
    document.getElementById('attendanceForm').addEventListener('submit', handleAttendanceSubmit);

    // Bill form
    document.getElementById('billForm').addEventListener('submit', handleBillSubmit);

    // Payment form
    document.getElementById('paymentForm').addEventListener('submit', handlePaymentSubmit);

    // Document form
    document.getElementById('documentForm').addEventListener('submit', handleDocumentSubmit);

    // Profile form
    document.getElementById('profileForm').addEventListener('submit', handleProfileSubmit);
}

function handleClientSubmit(event) {
    event.preventDefault();
    
    const clientData = {
        id: clients.length + 1,
        name: document.getElementById('clientName').value,
        contact: document.getElementById('clientContact').value,
        phone: document.getElementById('clientPhone').value,
        email: document.getElementById('clientEmail').value,
        address: document.getElementById('clientAddress').value,
        created_at: new Date().toISOString().split('T')[0]
    };

    clients.push(clientData);
    closeModal('clientModal');
    document.getElementById('clientForm').reset();
    showMessage('Client added successfully!', 'success');
    loadClientsTable();
}

function handleSiteSubmit(event) {
    event.preventDefault();
    
    const siteData = {
        id: sites.length + 1,
        name: document.getElementById('siteName').value,
        client_id: document.getElementById('siteClient').value,
        location: document.getElementById('siteLocation').value,
        start_date: document.getElementById('siteStartDate').value,
        end_date: document.getElementById('siteEndDate').value,
        scope_work: document.getElementById('siteScopeWork').value,
        status: 'active'
    };

    sites.push(siteData);
    closeModal('siteModal');
    document.getElementById('siteForm').reset();
    showMessage('Site added successfully!', 'success');
    loadSitesTable();
}

function handleEmployeeSubmit(event) {
    event.preventDefault();
    
    const employeeData = {
        id: employees.length + 1,
        name: document.getElementById('employeeName').value,
        phone: document.getElementById('employeePhone').value,
        email: document.getElementById('employeeEmail').value,
        trade: document.getElementById('employeeTrade').value,
        daily_wage: document.getElementById('employeeWage').value,
        username: document.getElementById('employeeUsername').value,
        password: document.getElementById('employeePassword').value,
        balance: 0,
        status: 'active'
    };

    employees.push(employeeData);
    closeModal('employeeModal');
    document.getElementById('employeeForm').reset();
    showMessage('Employee added successfully!', 'success');
    loadEmployeesTable();
}

function handleAttendanceSubmit(event) {
    event.preventDefault();
    
    const attendanceData = {
        id: attendance.length + 1,
        employee_id: document.getElementById('attendanceEmployee').value,
        site_id: document.getElementById('attendanceSite').value,
        date: document.getElementById('attendanceMarkDate').value,
        in_time: document.getElementById('attendanceInTime').value,
        out_time: document.getElementById('attendanceOutTime').value,
        status: document.getElementById('attendanceStatus').value,
        overtime_hours: calculateOvertimeHours(
            document.getElementById('attendanceInTime').value,
            document.getElementById('attendanceOutTime').value
        )
    };

    attendance.push(attendanceData);
    closeModal('attendanceModal');
    document.getElementById('attendanceForm').reset();
    showMessage('Attendance marked successfully!', 'success');
    loadAttendanceTable();
}

function handleBillSubmit(event) {
    event.preventDefault();
    
    const billData = {
        id: bills.length + 1,
        bill_no: 'INV' + String(bills.length + 1).padStart(3, '0'),
        client_id: document.getElementById('billClient').value,
        site_id: document.getElementById('billSite').value,
        amount: document.getElementById('billAmount').value,
        date: document.getElementById('billDate').value,
        description: document.getElementById('billDescription').value,
        status: 'pending'
    };

    bills.push(billData);
    closeModal('billModal');
    document.getElementById('billForm').reset();
    showMessage('Bill raised successfully!', 'success');
    loadBillsTable();
}

function handlePaymentSubmit(event) {
    event.preventDefault();
    
    const paymentData = {
        id: payments.length + 1,
        bill_id: document.getElementById('paymentBill').value,
        amount: document.getElementById('paymentAmount').value,
        date: document.getElementById('paymentDate').value,
        method: document.getElementById('paymentMethod').value
    };

    payments.push(paymentData);

    // Update bill status
    const billId = parseInt(document.getElementById('paymentBill').value);
    const bill = bills.find(b => b.id === billId);
    if (bill) {
        bill.status = 'paid';
    }

    closeModal('paymentModal');
    document.getElementById('paymentForm').reset();
    showMessage('Payment recorded successfully!', 'success');
    loadBillsTable();
}

function handleDocumentSubmit(event) {
    event.preventDefault();
    
    const fileInput = document.getElementById('documentFile');
    const file = fileInput.files[0];

    if (file) {
        const documentData = {
            id: documents.length + 1,
            name: file.name,
            type: document.getElementById('documentType').value,
            site_id: document.getElementById('documentSite').value,
            description: document.getElementById('documentDescription').value,
            upload_date: new Date().toISOString().split('T')[0],
            file_path: URL.createObjectURL(file) // In real app, upload to server
        };

        documents.push(documentData);
        closeModal('documentModal');
        document.getElementById('documentForm').reset();
        showMessage('Document uploaded successfully!', 'success');
        loadDocumentsTable();
    }
}

function handleProfileSubmit(event) {
    event.preventDefault();
    
    // Update current user data
    currentUser.name = document.getElementById('profileFullName').value;
    currentUser.phone = document.getElementById('profilePhoneNumber').value;
    currentUser.email = document.getElementById('profileEmail').value;

    if (userRole === 'employee') {
        currentUser.trade = document.getElementById('profileTrade').value;
        currentUser.daily_wage = document.getElementById('profileWage').value;
    }

    updateProfileInfo();
    showMessage('Profile updated successfully!', 'success');
}

// Data Loading Functions
function loadSampleData() {
    // Sample clients
    clients = [
        { id: 1, name: 'ABC Builders', contact: 'Mr. Sharma', phone: '9876543210', email: 'sharma@abc.com', address: 'Pune, MH' },
        { id: 2, name: 'XYZ Construction', contact: 'Mr. Patel', phone: '9876543211', email: 'patel@xyz.com', address: 'Mumbai, MH' }
    ];

    // Sample sites
    sites = [
        { id: 1, name: 'Green Valley Apartments', client_id: 1, location: 'Pune, MH', start_date: '2024-01-15', end_date: '2024-12-15', status: 'active' },
        { id: 2, name: 'Sunshine Villa', client_id: 2, location: 'Mumbai, MH', start_date: '2024-02-01', end_date: '2024-11-30', status: 'active' }
    ];

    // Sample employees
    employees = [
        { id: 1, name: 'Ramesh Kumar', phone: '9876543210', email: 'ramesh@email.com', trade: 'Electrician', daily_wage: 800, balance: 2400, status: 'active' },
        { id: 2, name: 'Suresh Patil', phone: '9876543211', email: 'suresh@email.com', trade: 'Plumber', daily_wage: 750, balance: 1500, status: 'active' }
    ];

    // Sample attendance
    attendance = [
        { id: 1, employee_id: 1, site_id: 1, date: '2024-09-24', in_time: '08:00', out_time: '18:30', status: 'present', overtime_hours: 2.5 },
        { id: 2, employee_id: 2, site_id: 2, date: '2024-09-24', in_time: '08:15', out_time: '17:45', status: 'present', overtime_hours: 1.5 }
    ];

    // Sample bills
    bills = [
        { id: 1, bill_no: 'INV001', client_id: 1, site_id: 1, amount: 45000, date: '2024-09-15', status: 'pending', description: 'Electrical work phase 1' },
        { id: 2, bill_no: 'INV002', client_id: 2, site_id: 2, amount: 35000, date: '2024-09-10', status: 'paid', description: 'Plumbing installation' }
    ];

    // Sample documents
    documents = [
        { id: 1, name: 'Site_Plan_GreenValley.jpg', type: 'drawing', site_id: 1, description: 'Initial site layout plan', upload_date: '2024-09-20' },
        { id: 2, name: 'Material_Bill_Sept.pdf', type: 'bill', site_id: 2, description: 'Cement and steel purchase bill', upload_date: '2024-09-18' }
    ];
}

function loadDashboardData() {
    updateDashboardStats();
    updateRecentActivities();
}

function loadSectionData(sectionName) {
    switch(sectionName) {
        case 'clients':
            loadClientsTable();
            break;
        case 'sites':
            loadSitesTable();
            break;
        case 'employees':
            loadEmployeesTable();
            break;
        case 'attendance':
            loadAttendanceTable();
            break;
        case 'billing':
            loadBillsTable();
            loadBillingSummary();
            break;
        case 'documents':
            loadDocumentsTable();
            break;
        case 'profile':
            loadProfileData();
            break;
    }
}

// Table Loading Functions
function loadClientsTable() {
    const tbody = document.getElementById('clientsTable');
    tbody.innerHTML = '';

    clients.forEach(client => {
        const row = `
            <tr>
                <td>${client.name}</td>
                <td>${client.contact}</td>
                <td>${client.phone}</td>
                <td>${client.address}</td>
                <td>
                    <button class="btn btn-warning" style="padding: 4px 8px; margin-right: 5px;">Edit</button>
                    <button class="btn btn-danger" style="padding: 4px 8px;">Delete</button>
                </td>
            </tr>
        `;
        tbody.innerHTML += row;
    });
}

function loadSitesTable() {
    const tbody = document.getElementById('sitesTable');
    tbody.innerHTML = '';

    sites.forEach(site => {
        const client = clients.find(c => c.id == site.client_id);
        const row = `
            <tr>
                <td>${site.name}</td>
                <td>${client ? client.name : 'Unknown'}</td>
                <td>${site.location}</td>
                <td>${site.start_date}</td>
                <td>${site.end_date || '-'}</td>
                <td><span class="status-badge status-${site.status}">${site.status}</span></td>
                <td>
                    <button class="btn btn-warning" style="padding: 4px 8px; margin-right: 5px;">Edit</button>
                    <button class="btn btn-danger" style="padding: 4px 8px;">Delete</button>
                </td>
            </tr>
        `;
        tbody.innerHTML += row;
    });
}

function loadEmployeesTable() {
    const tbody = document.getElementById('employeesTable');
    tbody.innerHTML = '';

    employees.forEach(employee => {
        const row = `
            <tr>
                <td>${employee.name}</td>
                <td>${employee.phone}</td>
                <td>${employee.trade}</td>
                <td>₹${employee.daily_wage}</td>
                <td>₹${employee.balance}</td>
                <td><span class="status-badge status-${employee.status}">${employee.status}</span></td>
                <td>
                    <button class="btn btn-warning" style="padding: 4px 8px; margin-right: 5px;">Edit</button>
                    <button class="btn btn-danger" style="padding: 4px 8px;">Delete</button>
                </td>
            </tr>
        `;
        tbody.innerHTML += row;
    });
}

function loadAttendanceTable() {
    const tbody = document.getElementById('attendanceTable');
    tbody.innerHTML = '';

    attendance.forEach(record => {
        const employee = employees.find(e => e.id == record.employee_id);
        const site = sites.find(s => s.id == record.site_id);
        const totalHours = calculateTotalHours(record.in_time, record.out_time);
        
        const row = `
            <tr>
                <td>${employee ? employee.name : 'Unknown'}</td>
                <td>${site ? site.name : 'Unknown'}</td>
                <td>${record.date}</td>
                <td>${record.in_time}</td>
                <td>${record.out_time}</td>
                <td>${totalHours.toFixed(1)}</td>
                <td>${record.overtime_hours.toFixed(1)}</td>
                <td><span class="status-badge status-${record.status}">${record.status}</span></td>
            </tr>
        `;
        tbody.innerHTML += row;
    });
}

function loadBillsTable() {
    const tbody = document.getElementById('billsTable');
    tbody.innerHTML = '';

    bills.forEach(bill => {
        const client = clients.find(c => c.id == bill.client_id);
        const site = sites.find(s => s.id == bill.site_id);
        
        const row = `
            <tr>
                <td>${bill.bill_no}</td>
                <td>${client ? client.name : 'Unknown'}</td>
                <td>${site ? site.name : 'Unknown'}</td>
                <td>₹${bill.amount}</td>
                <td>${bill.date}</td>
                <td><span class="status-badge status-${bill.status}">${bill.status}</span></td>
                <td>
                    <button class="btn btn-warning" style="padding: 4px 8px; margin-right: 5px;">Edit</button>
                    <button class="btn btn-danger" style="padding: 4px 8px;">Delete</button>
                </td>
            </tr>
        `;
        tbody.innerHTML += row;
    });
}

function loadDocumentsTable() {
    const tbody = document.getElementById('documentsTable');
    tbody.innerHTML = '';

    documents.forEach(doc => {
        const site = sites.find(s => s.id == doc.site_id);
        
        const row = `
            <tr>
                <td>${doc.name}</td>
                <td>${doc.type}</td>
                <td>${site ? site.name : 'General'}</td>
                <td>${doc.upload_date}</td>
                <td>${doc.description || '-'}</td>
                <td>
                    <button class="btn btn-primary" style="padding: 4px 8px; margin-right: 5px;">View</button>
                    <button class="btn btn-danger" style="padding: 4px 8px;">Delete</button>
                </td>
            </tr>
        `;
        tbody.innerHTML += row;
    });
}

// Dropdown Loading Functions
function loadClientDropdown() {
    const dropdown = document.getElementById('siteClient') || document.getElementById('billClient');
    if (dropdown) {
        dropdown.innerHTML = '<option value="">Select Client</option>';
        clients.forEach(client => {
            dropdown.innerHTML += `<option value="${client.id}">${client.name}</option>`;
        });
    }
}

function loadSiteDropdown() {
    const dropdown = document.getElementById('attendanceSite') || document.getElementById('billSite') || document.getElementById('documentSite');
    if (dropdown) {
        dropdown.innerHTML = '<option value="">Select Site</option>';
        sites.forEach(site => {
            dropdown.innerHTML += `<option value="${site.id}">${site.name}</option>`;
        });
    }
}

function loadEmployeeDropdown() {
    const dropdown = document.getElementById('attendanceEmployee');
    if (dropdown) {
        dropdown.innerHTML = '<option value="">Select Employee</option>';
        employees.forEach(employee => {
            dropdown.innerHTML += `<option value="${employee.id}">${employee.name}</option>`;
        });
    }
}

// Utility Functions
function calculateTotalHours(inTime, outTime) {
    if (!inTime || !outTime) return 0;
    
    const [inHours, inMinutes] = inTime.split(':').map(Number);
    const [outHours, outMinutes] = outTime.split(':').map(Number);
    
    const inTotalMinutes = inHours * 60 + inMinutes;
    const outTotalMinutes = outHours * 60 + outMinutes;
    
    return (outTotalMinutes - inTotalMinutes) / 60;
}

function calculateOvertimeHours(inTime, outTime) {
    const totalHours = calculateTotalHours(inTime, outTime);
    return Math.max(0, totalHours - 8);
}

function updateDashboardStats() {
    document.getElementById('totalSites').textContent = sites.filter(s => s.status === 'active').length;
    document.getElementById('totalEmployees').textContent = employees.filter(e => e.status === 'active').length;
    
    const today = new Date().toISOString().split('T')[0];
    const todayAttendance = attendance.filter(a => a.date === today && a.status === 'present').length;
    document.getElementById('todayAttendance').textContent = todayAttendance;
    
    const pendingBills = bills.filter(b => b.status === 'pending').length;
    document.getElementById('pendingBills').textContent = pendingBills;
}

function updateRecentActivities() {
    const activities = document.getElementById('recentActivities');
    activities.innerHTML = `
        <li>New employee added: ${employees[employees.length - 1]?.name || 'None'}</li>
        <li>Latest bill: ${bills[bills.length - 1]?.bill_no || 'None'}</li>
        <li>Recent attendance marked</li>
    `;
}

function loadBillingSummary() {
    const totalBilled = bills.reduce((sum, bill) => sum + parseFloat(bill.amount), 0);
    const totalPaid = bills.filter(b => b.status === 'paid').reduce((sum, bill) => sum + parseFloat(bill.amount), 0);
    const totalPending = totalBilled - totalPaid;

    document.getElementById('totalBillsRaised').textContent = totalBilled.toLocaleString();
    document.getElementById('totalPaymentsReceived').textContent = totalPaid.toLocaleString();
    document.getElementById('totalPendingAmount').textContent = totalPending.toLocaleString();
}

function updateProfileInfo() {
    if (currentUser) {
        document.getElementById('profileName').textContent = currentUser.name;
        document.getElementById('profileRole').textContent = currentUser.role;
        document.getElementById('profilePhone').textContent = currentUser.phone;
        document.getElementById('profileInitials').textContent = currentUser.name.charAt(0).toUpperCase();
        
        // Fill form fields
        document.getElementById('profileFullName').value = currentUser.name;
        document.getElementById('profilePhoneNumber').value = currentUser.phone;
        document.getElementById('profileEmail').value = currentUser.email || '';
        
        if (userRole === 'employee') {
            const employee = employees.find(e => e.name === currentUser.name);
            if (employee) {
                document.getElementById('profileWageRate').textContent = employee.daily_wage;
                document.getElementById('profileBalance').textContent = employee.balance;
                document.getElementById('profileTrade').value = employee.trade;
                document.getElementById('profileWage').value = employee.daily_wage;
            }
        }
    }
}

function loadProfileData() {
    updateProfileInfo();
}

// Message Functions
function showMessage(message, type = 'info', containerId = null) {
    const messageDiv = document.createElement('div');
    messageDiv.className = `${type}-msg`;
    messageDiv.textContent = message;
    
    if (containerId) {
        const container = document.getElementById(containerId);
        container.innerHTML = '';
        container.appendChild(messageDiv);
    } else {
        // Show in a general message area or alert
        alert(message);
    }
    
    // Auto-hide after 3 seconds
    setTimeout(() => {
        if (messageDiv.parentNode) {
            messageDiv.parentNode.removeChild(messageDiv);
        }
    }, 3000);
}

function clearMessage(containerId) {
    const container = document.getElementById(containerId);
    if (container) {
        container.innerHTML = '';
    }
}
