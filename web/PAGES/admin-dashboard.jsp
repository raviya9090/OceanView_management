<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="MODELS.Room" %>
<%@ page import="MODELS.Reservation" %>
<%@ page import="MODELS.User" %>
<%@ page import="SERVICES.RoomService" %>
<%@ page import="SERVICES.ReservationService" %>
<%@ page import="SERVICES.UserService" %>

<%
    // ── Auth guard ────────────────────────────────────────────────────────────
    String role = (String) session.getAttribute("role");
    if (role == null || !role.equalsIgnoreCase("ADMIN")) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // ── Load data ─────────────────────────────────────────────────────────────
    List<Room> rooms = (List<Room>) request.getAttribute("rooms");
    if (rooms == null) { rooms = new RoomService().getAllRooms(); }

    List<Reservation> reservations = (List<Reservation>) request.getAttribute("reservations");
    if (reservations == null) { reservations = new ReservationService().getAllReservations(); }

    List<User> guests = (List<User>) request.getAttribute("guests");
    if (guests == null) { guests = new UserService().getAllGuests(); }

    int  totalRooms     = rooms.size();
    long availableCount = rooms.stream().filter(r -> "Available".equals(r.getAvailability())).count();

    Integer totalReservations = (Integer) request.getAttribute("totalReservations");
    if (totalReservations == null) { totalReservations = new ReservationService().getTotalReservationCount(); }

    Integer totalGuests = (Integer) request.getAttribute("totalGuests");
    if (totalGuests == null) { totalGuests = new ReservationService().getTotalGuestCount(); }

    String activeTab = (String) request.getAttribute("activeTab");
    if (activeTab == null) activeTab = "rooms";

    String msgType = (String) session.getAttribute("msgType");
    String msgText = (String) session.getAttribute("msgText");
    session.removeAttribute("msgType");
    session.removeAttribute("msgText");

    User viewUser = (User) request.getAttribute("viewUser");
    List<Reservation> userReservations = (List<Reservation>) request.getAttribute("userReservations");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - Ocean View Resort</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f8f9fa; font-size: 14px; }
        header { background: #ffffff; box-shadow: 0 2px 10px rgba(0,0,0,0.05); padding: 1rem 0; position: sticky; top: 0; z-index: 100; }
        nav { max-width: 1400px; margin: 0 auto; display: flex; justify-content: space-between; align-items: center; padding: 0 2rem; }
        .logo { font-size: 1.5rem; font-weight: bold; color: #ff6b35; }
        .user-info { display: flex; align-items: center; gap: 1.5rem; }
        .username { color: #2c3e50; font-weight: 600; font-size: 0.9rem; }
        .btn-logout { padding: 0.5rem 1.2rem; background: #ff6b35; color: white; border: none; border-radius: 6px; cursor: pointer; font-size: 0.85rem; font-weight: 600; }
        .btn-logout:hover { background: #e55a2b; }
        .container { max-width: 1400px; margin: 2rem auto; padding: 0 2rem; }
        .dashboard-header { margin-bottom: 2rem; }
        .dashboard-header h1 { color: #2c3e50; font-size: 1.8rem; margin-bottom: 0.5rem; }
        .dashboard-header p { color: #5a6c7d; font-size: 0.9rem; }
        .tabs { display: flex; gap: 0.5rem; margin-bottom: 2rem; border-bottom: 2px solid #e8e8e8; }
        .tab { padding: 0.8rem 1.5rem; background: transparent; border: none; cursor: pointer; font-size: 0.9rem; font-weight: 600; color: #5a6c7d; border-bottom: 3px solid transparent; transition: all 0.3s ease; }
        .tab.active { color: #ff6b35; border-bottom-color: #ff6b35; }
        .tab:hover { color: #ff6b35; }
        .tab-content { display: none; }
        .tab-content.active { display: block; }
        .action-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; gap: 1rem; flex-wrap: wrap; }
        .action-bar-left { display: flex; gap: 0.8rem; align-items: center; flex-wrap: wrap; flex: 1; }
        .search-box { flex: 1; max-width: 350px; }
        .search-box input { width: 100%; padding: 0.6rem 1rem; border: 2px solid #e8e8e8; border-radius: 6px; font-size: 0.85rem; }
        .search-box input:focus { outline: none; border-color: #ff6b35; }
        .user-filter-wrap { display: flex; gap: 0.5rem; align-items: center; flex-wrap: wrap; }
        .user-filter-wrap select { padding: 0.6rem 0.8rem; border: 2px solid #e8e8e8; border-radius: 6px; font-size: 0.85rem; min-width: 200px; }
        .user-filter-wrap select:focus { outline: none; border-color: #ff6b35; }
        .btn-filter { padding: 0.6rem 1.1rem; background: #2c3e50; color: white; border: none; border-radius: 6px; cursor: pointer; font-size: 0.85rem; font-weight: 600; }
        .btn-filter:hover { background: #1a252f; }
        .btn-filter-clear { padding: 0.6rem 1.1rem; background: #e8e8e8; color: #5a6c7d; border: none; border-radius: 6px; cursor: pointer; font-size: 0.85rem; font-weight: 600; text-decoration: none; display: inline-block; }
        .btn-filter-clear:hover { background: #d0d0d0; }
        .btn-add { padding: 0.6rem 1.5rem; background: #ff6b35; color: white; border: none; border-radius: 6px; cursor: pointer; font-size: 0.85rem; font-weight: 600; white-space: nowrap; }
        .btn-add:hover { background: #e55a2b; }
        .table-container { background: white; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); overflow: hidden; }
        table { width: 100%; border-collapse: collapse; }
        thead { background: #f8f9fa; }
        th { padding: 0.8rem 1rem; text-align: left; font-weight: 600; color: #2c3e50; font-size: 0.8rem; text-transform: uppercase; border-bottom: 2px solid #e8e8e8; }
        td { padding: 0.8rem 1rem; color: #5a6c7d; font-size: 0.85rem; border-bottom: 1px solid #f0f0f0; }
        tbody tr:hover { background: #f8f9fa; }
        .status-badge { padding: 0.3rem 0.8rem; border-radius: 12px; font-size: 0.75rem; font-weight: 600; }
        .status-available   { background: #e5ffe5; color: #2d7a2d; }
        .status-occupied    { background: #ffe5e5; color: #d32f2f; }
        .status-maintenance { background: #fff5e5; color: #e67e22; }
        .status-paid        { background: #e5ffe5; color: #2d7a2d; }
        .status-pending     { background: #fff5e5; color: #e67e22; }
        .status-cancelled   { background: #ffe5e5; color: #d32f2f; }
        .action-buttons { display: flex; gap: 0.5rem; flex-wrap: wrap; }
        .btn-edit, .btn-delete, .btn-view-user { padding: 0.4rem 0.8rem; border: none; border-radius: 4px; cursor: pointer; font-size: 0.75rem; font-weight: 600; }
        .btn-edit         { background: #fff5f2; color: #ff6b35; border: 1px solid #ff6b35; }
        .btn-edit:hover   { background: #ff6b35; color: white; }
        .btn-delete       { background: #ffe5e5; color: #d32f2f; border: 1px solid #d32f2f; }
        .btn-delete:hover { background: #d32f2f; color: white; }
        .btn-view-user       { background: #e5f0ff; color: #2563eb; border: 1px solid #2563eb; }
        .btn-view-user:hover { background: #2563eb; color: white; }
        /* Modals */
        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); overflow-y: auto; }
        .modal-content { background: white; margin: 3% auto; padding: 2rem; border-radius: 8px; max-width: 600px; position: relative; }
        .modal-header { margin-bottom: 1.5rem; }
        .modal-header h2 { color: #2c3e50; font-size: 1.4rem; }
        .modal-header p  { color: #5a6c7d; font-size: 0.85rem; margin-top: 0.3rem; }
        .close { position: absolute; right: 1.5rem; top: 1.5rem; font-size: 1.8rem; cursor: pointer; color: #999; }
        .close:hover { color: #ff6b35; }
        .form-group { margin-bottom: 1.2rem; }
        .form-group label { display: block; margin-bottom: 0.4rem; color: #2c3e50; font-weight: 600; font-size: 0.85rem; }
        .form-group input, .form-group select, .form-group textarea { width: 100%; padding: 0.6rem; border: 2px solid #e8e8e8; border-radius: 6px; font-size: 0.85rem; }
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus { outline: none; border-color: #ff6b35; }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }
        .btn-submit { width: 100%; padding: 0.8rem; background: #ff6b35; color: white; border: none; border-radius: 6px; font-size: 0.9rem; font-weight: 600; cursor: pointer; margin-top: 1rem; }
        .btn-submit:hover { background: #e55a2b; }
        /* Stats */
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; margin-bottom: 2rem; }
        .stat-card { background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); border-left: 4px solid #ff6b35; }
        .stat-card h3 { color: #5a6c7d; font-size: 0.8rem; text-transform: uppercase; margin-bottom: 0.5rem; }
        .stat-card p  { color: #2c3e50; font-size: 1.8rem; font-weight: bold; }
        /* Alerts */
        .alert { padding: 0.9rem 1.2rem; border-radius: 6px; margin-bottom: 1.5rem; font-size: 0.88rem; font-weight: 600; }
        .alert-success { background: #e5ffe5; color: #2d7a2d; border-left: 4px solid #2d7a2d; }
        .alert-error   { background: #ffe5e5; color: #d32f2f; border-left: 4px solid #d32f2f; }
        /* User detail panel */
        .user-detail-panel { background: white; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); padding: 1.5rem; margin-bottom: 1.5rem; border-left: 4px solid #2563eb; }
        .user-detail-panel .panel-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1rem; gap: 1rem; }
        .user-detail-panel h3 { color: #2c3e50; font-size: 1.1rem; margin-bottom: 0.4rem; }
        .user-detail-panel .meta { color: #5a6c7d; font-size: 0.82rem; display: flex; gap: 1.2rem; flex-wrap: wrap; }
        .user-detail-panel .meta strong { color: #2c3e50; }
        .user-badge { display: inline-flex; align-items: center; gap: 0.4rem; background: #e5f0ff; color: #2563eb; border-radius: 6px; padding: 0.25rem 0.7rem; font-size: 0.8rem; font-weight: 700; }
        .btn-close-panel { background: #e8e8e8; color: #5a6c7d; border: none; border-radius: 5px; padding: 0.45rem 1rem; cursor: pointer; font-size: 0.82rem; font-weight: 600; white-space: nowrap; text-decoration: none; display: inline-block; }
        .btn-close-panel:hover { background: #d0d0d0; }
        .panel-table-wrap { overflow-x: auto; }
        /* Debug info box */
        .debug-box { background:#fff8e1; border-left:4px solid #f59e0b; padding:0.8rem 1.2rem; border-radius:6px; margin-bottom:1rem; font-size:0.82rem; color:#92400e; }
        @media (max-width: 768px) {
            .action-bar { flex-direction: column; align-items: stretch; }
            .action-bar-left { flex-direction: column; }
            .search-box { max-width: 100%; }
            .form-row { grid-template-columns: 1fr; }
            table { font-size: 0.75rem; }
            th, td { padding: 0.5rem; }
        }
    </style>
</head>
<body>

<header>
    <nav>
        <div class="logo">Ocean View Resort</div>
        <div class="user-info">
            <span class="username">Admin</span>
            <button class="btn-logout" onclick="logout()">Logout</button>
        </div>
    </nav>
</header>

<div class="container">
    <div class="dashboard-header">
        <h1>Admin Dashboard</h1>
        <p>Manage reservations, rooms, and guests</p>
    </div>

    <!-- Flash Message -->
    <% if (msgText != null) { %>
    <div class="alert alert-<%= msgType %>"><%= msgText %></div>
    <% } %>

    <!-- Debug info: shows if guests list is empty so you know what to fix in DB -->
    <% if (guests != null && guests.isEmpty()) { %>
    <div class="debug-box">
        ⚠️ <strong>No guests found.</strong> Make sure registered users have <code>role = 'GUEST'</code> (uppercase) in the <code>users</code> table.
        Run this in MySQL Workbench to check: <code>SELECT user_id, username, role FROM users;</code>
    </div>
    <% } %>

    <!-- Stats -->
    <div class="stats-grid">
        <div class="stat-card"><h3>Total Rooms</h3><p><%= totalRooms %></p></div>
        <div class="stat-card"><h3>Available Rooms</h3><p><%= availableCount %></p></div>
        <div class="stat-card"><h3>Total Reservations</h3><p><%= totalReservations %></p></div>
        <div class="stat-card"><h3>Total Guests</h3><p><%= totalGuests %></p></div>
    </div>

    <!-- Tabs -->
    <div class="tabs">
        <button class="tab <%= "rooms".equals(activeTab) ? "active" : "" %>"        onclick="openTab('rooms', event)">Rooms</button>
        <button class="tab <%= "reservations".equals(activeTab) ? "active" : "" %>" onclick="openTab('reservations', event)">Reservations</button>
        <button class="tab <%= "guests".equals(activeTab) ? "active" : "" %>"       onclick="openTab('guests', event)">Guests</button>
    </div>

    <!-- ══ RESERVATIONS TAB ════════════════════════════════════════════════════ -->
    <div id="reservations" class="tab-content <%= "reservations".equals(activeTab) ? "active" : "" %>">

        <!-- User-specific reservation panel -->
        <% if (viewUser != null && userReservations != null) { %>
        <div class="user-detail-panel">
            <div class="panel-header">
                <div>
                    <h3>Reservations for &nbsp;<span class="user-badge">👤 <%= viewUser.getUsername() %></span></h3>
                    <div class="meta" style="margin-top:0.5rem;">
                        <span>User ID: <strong>#<%= viewUser.getUserId() %></strong></span>
                        <% if (viewUser.getContactNumber() != null && !viewUser.getContactNumber().isEmpty()) { %>
                        <span>Contact: <strong><%= viewUser.getContactNumber() %></strong></span>
                        <% } %>
                        <% if (viewUser.getNic() != null && !viewUser.getNic().isEmpty()) { %>
                        <span>NIC: <strong><%= viewUser.getNic() %></strong></span>
                        <% } %>
                        <span>Total Bookings: <strong><%= userReservations.size() %></strong></span>
                    </div>
                </div>
                <a href="<%= request.getContextPath() %>/ReservationServlet" class="btn-close-panel">✕ Clear Filter</a>
            </div>
            <% if (!userReservations.isEmpty()) { %>
            <div class="panel-table-wrap">
                <table>
                    <thead><tr><th>ID</th><th>Room</th><th>Check-In</th><th>Check-Out</th><th>Nights</th><th>Amount</th><th>Status</th><th>Actions</th></tr></thead>
                    <tbody>
                        <%
                            for (Reservation ur : userReservations) {
                                String ub = "status-pending";
                                if ("Paid".equalsIgnoreCase(ur.getPaymentStatus()))           ub = "status-paid";
                                else if ("Cancelled".equalsIgnoreCase(ur.getPaymentStatus())) ub = "status-cancelled";
                        %>
                        <tr>
                            <td><%= ur.getReservationId() %></td>
                            <td><%= ur.getRoomNumber() %> – <%= ur.getRoomType() %></td>
                            <td><%= ur.getCheckInDate() %></td>
                            <td><%= ur.getCheckOutDate() %></td>
                            <td><%= ur.getNumberOfNights() %></td>
                            <td><%= String.format("%,.2f", ur.getTotalAmount()) %></td>
                            <td><span class="status-badge <%= ub %>"><%= ur.getPaymentStatus() %></span></td>
                            <td>
                                <div class="action-buttons">
                                    <button class="btn-edit" onclick="openEditResModal(<%= ur.getReservationId() %>,<%= ur.getRoomId() %>,'<%= ur.getCheckInDate() %>','<%= ur.getCheckOutDate() %>','<%= ur.getPaymentStatus() %>')">Edit</button>
                                    <button class="btn-delete" onclick="confirmDeleteReservation(<%= ur.getReservationId() %>)">Delete</button>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            <% } else { %>
            <p style="color:#999;padding:1rem 0;text-align:center;">This guest has no reservations yet.</p>
            <% } %>
        </div>
        <% } %>

        <!-- Action bar -->
        <div class="action-bar">
            <div class="action-bar-left">
                <div class="search-box">
                    <input type="text" id="resSearch" placeholder="Search by guest or room..." onkeyup="searchReservations()">
                </div>
                <div class="user-filter-wrap">
                    <form method="GET" action="<%= request.getContextPath() %>/ReservationServlet" style="display:flex;gap:0.5rem;align-items:center;flex-wrap:wrap;">
                        <input type="hidden" name="action" value="viewUser">
                        <select name="userId">
                            <option value="">— Filter by guest —</option>
                            <%
                                for (User g : guests) {
                                    String sel = (viewUser != null && viewUser.getUserId() == g.getUserId()) ? "selected" : "";
                            %>
                            <option value="<%= g.getUserId() %>" <%= sel %>>#<%= g.getUserId() %> – <%= g.getUsername() %><% if (g.getContactNumber()!=null&&!g.getContactNumber().isEmpty()){%> (<%= g.getContactNumber() %>)<%}%></option>
                            <% } %>
                        </select>
                        <button type="submit" class="btn-filter">View</button>
                        <% if (viewUser != null) { %><a href="<%= request.getContextPath() %>/ReservationServlet" class="btn-filter-clear">Show All</a><% } %>
                    </form>
                </div>
            </div>
            <button class="btn-add" onclick="openModal('addReservation')">+ Add Reservation</button>
        </div>

        <!-- All Reservations table -->
        <div class="table-container">
            <table id="reservationsTable">
                <thead>
                    <tr><th>ID</th><th>Guest</th><th>Room</th><th>Check-In</th><th>Check-Out</th><th>Nights</th><th>Amount</th><th>Status</th><th>Actions</th></tr>
                </thead>
                <tbody>
                    <%
                        if (reservations != null && !reservations.isEmpty()) {
                            for (Reservation res : reservations) {
                                String bc = "status-pending";
                                if ("Paid".equalsIgnoreCase(res.getPaymentStatus()))           bc = "status-paid";
                                else if ("Cancelled".equalsIgnoreCase(res.getPaymentStatus())) bc = "status-cancelled";
                    %>
                    <tr>
                        <td><%= res.getReservationId() %></td>
                        <td><%= res.getUsername() %><br><small style="color:#aaa;">UID #<%= res.getUserId() %></small></td>
                        <td><%= res.getRoomNumber() %> – <%= res.getRoomType() %></td>
                        <td><%= res.getCheckInDate() %></td>
                        <td><%= res.getCheckOutDate() %></td>
                        <td><%= res.getNumberOfNights() %></td>
                        <td><%= String.format("%,.2f", res.getTotalAmount()) %></td>
                        <td><span class="status-badge <%= bc %>"><%= res.getPaymentStatus() %></span></td>
                        <td>
                            <div class="action-buttons">
                                <button class="btn-view-user" onclick="viewUserReservations(<%= res.getUserId() %>)">Guest ↗</button>
                                <button class="btn-edit" onclick="openEditResModal(<%= res.getReservationId() %>,<%= res.getRoomId() %>,'<%= res.getCheckInDate() %>','<%= res.getCheckOutDate() %>','<%= res.getPaymentStatus() %>')">Edit</button>
                                <button class="btn-delete" onclick="confirmDeleteReservation(<%= res.getReservationId() %>)">Delete</button>
                            </div>
                        </td>
                    </tr>
                    <% } } else { %>
                    <tr><td colspan="9" style="text-align:center;padding:2rem;color:#999;">No reservations found.</td></tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <!-- ══ ROOMS TAB ══════════════════════════════════════════════════════════ -->
    <div id="rooms" class="tab-content <%= "rooms".equals(activeTab) ? "active" : "" %>">
        <div class="action-bar">
            <button class="btn-add" onclick="openModal('addRoom')">+ Add Room</button>
        </div>
        <div class="table-container">
            <table>
                <thead><tr><th>ID</th><th>Room Number</th><th>Type</th><th>Price/Night</th><th>Status</th><th>Description</th><th>Actions</th></tr></thead>
                <tbody>
                    <% for (Room room : rooms) {
                        String avail = room.getAvailability();
                        String bc = "status-available";
                        if ("Occupied".equalsIgnoreCase(avail))         bc = "status-occupied";
                        else if ("Maintenance".equalsIgnoreCase(avail)) bc = "status-maintenance";
                        String safeDesc   = room.getDescription()!=null ? room.getDescription().replace("\\","\\\\").replace("'","\\'") : "";
                        String displayDesc= room.getDescription()!=null ? room.getDescription() : "";
                    %>
                    <tr>
                        <td><%= room.getRoomId() %></td>
                        <td><%= room.getRoomNumber() %></td>
                        <td><%= room.getRoomType() %></td>
                        <td><%= String.format("%,.2f", room.getPricePerNight()) %></td>
                        <td><span class="status-badge <%= bc %>"><%= avail %></span></td>
                        <td><%= displayDesc %></td>
                        <td>
                            <div class="action-buttons">
                                <button class="btn-edit" onclick="openEditModal(<%= room.getRoomId() %>,'<%= room.getRoomNumber() %>','<%= room.getRoomType() %>','<%= room.getPricePerNight() %>','<%= avail %>','<%= safeDesc %>')">Edit</button>
                                <button class="btn-delete" onclick="confirmDelete(<%= room.getRoomId() %>)">Delete</button>
                            </div>
                        </td>
                    </tr>
                    <% } if (rooms.isEmpty()) { %>
                    <tr><td colspan="7" style="text-align:center;padding:2rem;color:#999;">No rooms found.</td></tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <!-- ══ GUESTS TAB ══════════════════════════════════════════════════════════ -->
    <div id="guests" class="tab-content <%= "guests".equals(activeTab) ? "active" : "" %>">
        <div class="action-bar">
            <div class="search-box">
                <input type="text" id="guestSearch" placeholder="Search guests..." onkeyup="searchGuests()">
            </div>
        </div>
        <div class="table-container">
            <table id="guestsTable">
                <thead><tr><th>User ID</th><th>Username</th><th>Contact Number</th><th>NIC</th><th>Registered</th><th>Actions</th></tr></thead>
                <tbody>
                    <% if (guests!=null && !guests.isEmpty()) { for (User g : guests) { %>
                    <tr>
                        <td>#<%= g.getUserId() %></td>
                        <td><strong><%= g.getUsername() %></strong></td>
                        <td><%= g.getContactNumber()!=null ? g.getContactNumber() : "—" %></td>
                        <td><%= g.getNic()!=null ? g.getNic() : "—" %></td>
                        <td><%= g.getCreatedAt()!=null ? g.getCreatedAt().toString().substring(0,10) : "—" %></td>
                        <td>
                            <div class="action-buttons">
                                <button class="btn-view-user" onclick="viewUserReservations(<%= g.getUserId() %>)">View Reservations</button>
                                <button class="btn-add" style="font-size:0.75rem;padding:0.4rem 0.8rem;" onclick="prefillAddModal(<%= g.getUserId() %>)">+ Add Booking</button>
                            </div>
                        </td>
                    </tr>
                    <% } } else { %>
                    <tr><td colspan="6" style="text-align:center;padding:2rem;color:#999;">No guests found. Ensure users are registered with role = 'GUEST'.</td></tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>

</div><!-- /container -->

<!-- ══ Add Reservation Modal ══════════════════════════════════════════════════ -->
<div id="addReservation" class="modal">
    <div class="modal-content">
        <span class="close" onclick="closeModal('addReservation')">&times;</span>
        <div class="modal-header">
            <h2>Add New Reservation</h2>
            <p>Select a registered guest and fill in the booking details.</p>
        </div>
        <form id="addResForm" action="<%= request.getContextPath() %>/ReservationServlet" method="POST" onsubmit="return syncAddPrice()">
            <input type="hidden" name="action" value="add">

            <div class="form-group">
                <label>Guest <span style="color:#ff6b35;">*</span></label>
                <% if (guests == null || guests.isEmpty()) { %>
                <p style="color:#d32f2f;font-size:0.85rem;padding:0.5rem;background:#ffe5e5;border-radius:6px;">
                    ⚠ No guests found. Users must be registered with <strong>role = 'GUEST'</strong> in the database.
                </p>
                <input type="hidden" name="userId" value="">
                <% } else { %>
                <select name="userId" id="addUserSelect" required>
                    <option value="">— Select a guest —</option>
                    <% for (User g : guests) { %>
                    <option value="<%= g.getUserId() %>">
                        #<%= g.getUserId() %> – <%= g.getUsername() %><% if(g.getContactNumber()!=null&&!g.getContactNumber().isEmpty()){%> (<%= g.getContactNumber() %>)<%}%>
                    </option>
                    <% } %>
                </select>
                <% } %>
            </div>

            <div class="form-group">
                <label>Room <span style="color:#ff6b35;">*</span></label>
                <select name="roomId" id="addRoomSelect" onchange="updateRoomPrice()" required>
                    <option value="">— Select a room —</option>
                    <% for (Room room : rooms) {
                        if ("Available".equalsIgnoreCase(room.getAvailability())) { %>
                    <option value="<%= room.getRoomId() %>" data-price="<%= room.getPricePerNight() %>">
                        <%= room.getRoomNumber() %> – <%= room.getRoomType() %> (<%= String.format("%,.2f", room.getPricePerNight()) %>/night)
                    </option>
                    <% } } %>
                </select>
            </div>

            <!-- Price is now a visible read-only display AND a hidden field synced on submit -->
            <input type="hidden" name="pricePerNight" id="addPriceHidden" value="0">

            <div class="form-row">
                <div class="form-group">
                    <label>Check-In Date <span style="color:#ff6b35;">*</span></label>
                    <input type="date" name="checkIn" id="addCheckIn" required>
                </div>
                <div class="form-group">
                    <label>Check-Out Date <span style="color:#ff6b35;">*</span></label>
                    <input type="date" name="checkOut" id="addCheckOut" required>
                </div>
            </div>

            <div class="form-group">
                <label>Payment Status</label>
                <select name="paymentStatus" required>
                    <option value="Pending">Pending</option>
                    <option value="Paid">Paid</option>
                </select>
            </div>

            <button type="submit" class="btn-submit">Add Reservation</button>
        </form>
    </div>
</div>

<!-- ══ Edit Reservation Modal ═════════════════════════════════════════════════ -->
<div id="editReservation" class="modal">
    <div class="modal-content">
        <span class="close" onclick="closeModal('editReservation')">&times;</span>
        <div class="modal-header"><h2>Edit Reservation</h2></div>
        <form action="<%= request.getContextPath() %>/ReservationServlet" method="POST" onsubmit="return syncEditPrice()">
            <input type="hidden" name="action" value="edit">
            <input type="hidden" name="reservationId" id="editResId">
            <div class="form-group">
                <label>Room</label>
                <select name="roomId" id="editResRoomId" onchange="updateEditRoomPrice()" required>
                    <% for (Room room : rooms) { %>
                    <option value="<%= room.getRoomId() %>" data-price="<%= room.getPricePerNight() %>">
                        <%= room.getRoomNumber() %> – <%= room.getRoomType() %> (<%= String.format("%,.2f", room.getPricePerNight()) %>/night)
                    </option>
                    <% } %>
                </select>
            </div>
            <input type="hidden" name="pricePerNight" id="editResPriceHidden" value="0">
            <div class="form-row">
                <div class="form-group">
                    <label>Check-In Date</label>
                    <input type="date" name="checkIn" id="editResCheckIn" required>
                </div>
                <div class="form-group">
                    <label>Check-Out Date</label>
                    <input type="date" name="checkOut" id="editResCheckOut" required>
                </div>
            </div>
            <div class="form-group">
                <label>Payment Status</label>
                <select name="paymentStatus" id="editResStatus" required>
                    <option value="Pending">Pending</option>
                    <option value="Paid">Paid</option>
                    <option value="Cancelled">Cancelled</option>
                </select>
            </div>
            <button type="submit" class="btn-submit">Update Reservation</button>
        </form>
    </div>
</div>

<!-- ══ Add Room Modal ════════════════════════════════════════════════════════ -->
<div id="addRoom" class="modal">
    <div class="modal-content">
        <span class="close" onclick="closeModal('addRoom')">&times;</span>
        <div class="modal-header"><h2>Add New Room</h2></div>
        <form action="<%= request.getContextPath() %>/RoomServlet" method="POST">
            <input type="hidden" name="action" value="add">
            <div class="form-row">
                <div class="form-group"><label>Room Number</label><input type="text" name="roomNumber" placeholder="e.g., 105" required></div>
                <div class="form-group"><label>Room Type</label>
                    <select name="roomType" required>
                        <option value="">Select Type</option>
                        <option value="Standard">Standard</option><option value="Deluxe">Deluxe</option>
                        <option value="Luxury">Luxury</option><option value="Suite">Suite</option>
                    </select>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group"><label>Price Per Night</label><input type="number" name="pricePerNight" placeholder="0.00" step="0.01" min="1" required></div>
                <div class="form-group"><label>Availability</label>
                    <select name="availability" required>
                        <option value="Available">Available</option><option value="Occupied">Occupied</option><option value="Maintenance">Maintenance</option>
                    </select>
                </div>
            </div>
            <div class="form-group"><label>Description</label><textarea rows="3" name="description" placeholder="Room description..."></textarea></div>
            <button type="submit" class="btn-submit">Add Room</button>
        </form>
    </div>
</div>

<!-- ══ Edit Room Modal ════════════════════════════════════════════════════════ -->
<div id="editRoom" class="modal">
    <div class="modal-content">
        <span class="close" onclick="closeModal('editRoom')">&times;</span>
        <div class="modal-header"><h2>Edit Room</h2></div>
        <form action="<%= request.getContextPath() %>/RoomServlet" method="POST">
            <input type="hidden" name="action" value="edit">
            <input type="hidden" name="roomId" id="editRoomId">
            <div class="form-row">
                <div class="form-group"><label>Room Number</label><input type="text" name="roomNumber" id="editRoomNumber" required></div>
                <div class="form-group"><label>Room Type</label>
                    <select name="roomType" id="editRoomType" required>
                        <option value="Standard">Standard</option><option value="Deluxe">Deluxe</option>
                        <option value="Luxury">Luxury</option><option value="Suite">Suite</option>
                    </select>
                </div>
            </div>
            <div class="form-row">
                <div class="form-group"><label>Price Per Night</label><input type="number" name="pricePerNight" id="editPricePerNight" step="0.01" min="1" required></div>
                <div class="form-group"><label>Availability</label>
                    <select name="availability" id="editAvailability" required>
                        <option value="Available">Available</option><option value="Occupied">Occupied</option><option value="Maintenance">Maintenance</option>
                    </select>
                </div>
            </div>
            <div class="form-group"><label>Description</label><textarea rows="3" name="description" id="editDescription"></textarea></div>
            <button type="submit" class="btn-submit">Update Room</button>
        </form>
    </div>
</div>

<!-- Hidden delete forms -->
<form id="deleteRoomForm" action="<%= request.getContextPath() %>/RoomServlet" method="POST" style="display:none;">
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="roomId" id="deleteRoomId">
</form>
<form id="deleteResForm" action="<%= request.getContextPath() %>/ReservationServlet" method="POST" style="display:none;">
    <input type="hidden" name="action" value="delete">
    <input type="hidden" name="reservationId" id="deleteResId">
</form>

<script>
    // ── Tabs ──────────────────────────────────────────────────────────────────
    function openTab(tabName, event) {
        document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
        document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
        document.getElementById(tabName).classList.add('active');
        if (event && event.target) event.target.classList.add('active');
    }
    function openModal(id)  { document.getElementById(id).style.display = 'block'; }
    function closeModal(id) { document.getElementById(id).style.display = 'none';  }
    window.onclick = e => { if (e.target.classList.contains('modal')) e.target.style.display = 'none'; }

    // ── Room price sync ───────────────────────────────────────────────────────
    function updateRoomPrice() {
        const sel = document.getElementById('addRoomSelect');
        const opt = sel.options[sel.selectedIndex];
        document.getElementById('addPriceHidden').value = opt ? (opt.dataset.price || '0') : '0';
    }
    function updateEditRoomPrice() {
        const sel = document.getElementById('editResRoomId');
        const opt = sel.options[sel.selectedIndex];
        document.getElementById('editResPriceHidden').value = opt ? (opt.dataset.price || '0') : '0';
    }

    // ── Sync price on form submit (safety net) ────────────────────────────────
    function syncAddPrice() {
        const sel = document.getElementById('addRoomSelect');
        if (!sel || !sel.value) { alert('Please select a room.'); return false; }
        const opt = sel.options[sel.selectedIndex];
        document.getElementById('addPriceHidden').value = opt.dataset.price || '0';
        return true;
    }
    function syncEditPrice() {
        const sel = document.getElementById('editResRoomId');
        if (!sel || !sel.value) { alert('Please select a room.'); return false; }
        const opt = sel.options[sel.selectedIndex];
        document.getElementById('editResPriceHidden').value = opt.dataset.price || '0';
        return true;
    }

    // ── Edit reservation modal ────────────────────────────────────────────────
    function openEditResModal(resId, roomId, checkIn, checkOut, status) {
        document.getElementById('editResId').value       = resId;
        document.getElementById('editResRoomId').value   = roomId;
        document.getElementById('editResCheckIn').value  = checkIn;
        document.getElementById('editResCheckOut').value = checkOut;
        document.getElementById('editResStatus').value   = status;
        updateEditRoomPrice();
        openModal('editReservation');
    }

    // ── Room edit modal ───────────────────────────────────────────────────────
    function openEditModal(id, roomNumber, roomType, price, availability, description) {
        document.getElementById('editRoomId').value        = id;
        document.getElementById('editRoomNumber').value    = roomNumber;
        document.getElementById('editRoomType').value      = roomType;
        document.getElementById('editPricePerNight').value = price;
        document.getElementById('editAvailability').value  = availability;
        document.getElementById('editDescription').value   = description;
        openModal('editRoom');
    }

    // ── Delete confirmations ──────────────────────────────────────────────────
    function confirmDelete(id) {
        if (confirm('Delete this room?')) {
            document.getElementById('deleteRoomId').value = id;
            document.getElementById('deleteRoomForm').submit();
        }
    }
    function confirmDeleteReservation(id) {
        if (confirm('Delete reservation #' + id + '?')) {
            document.getElementById('deleteResId').value = id;
            document.getElementById('deleteResForm').submit();
        }
    }

    // ── Navigation ────────────────────────────────────────────────────────────
    function viewUserReservations(userId) {
        window.location.href = '<%= request.getContextPath() %>/ReservationServlet?action=viewUser&userId=' + userId;
    }
    function prefillAddModal(userId) {
        const sel = document.getElementById('addUserSelect');
        if (sel) {
            for (let i = 0; i < sel.options.length; i++) {
                if (parseInt(sel.options[i].value) === userId) { sel.selectedIndex = i; break; }
            }
        }
        // Switch to reservations tab
        document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
        document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
        document.getElementById('reservations').classList.add('active');
        document.querySelectorAll('.tab')[1].classList.add('active');
        openModal('addReservation');
    }

    // ── Search ────────────────────────────────────────────────────────────────
    function searchReservations() {
        const q = document.getElementById('resSearch').value.toLowerCase();
        document.querySelectorAll('#reservationsTable tbody tr').forEach(r => {
            r.style.display = r.textContent.toLowerCase().includes(q) ? '' : 'none';
        });
    }
    function searchGuests() {
        const q = document.getElementById('guestSearch').value.toLowerCase();
        document.querySelectorAll('#guestsTable tbody tr').forEach(r => {
            r.style.display = r.textContent.toLowerCase().includes(q) ? '' : 'none';
        });
    }

    function logout() {
    if (confirm('Are you sure you want to logout?')) 
        window.location.href = '<%= request.getContextPath() %>/LogoutServlet';
}

    setTimeout(() => { const a = document.querySelector('.alert'); if (a) a.style.display = 'none'; }, 5000);
</script>
</body>
</html>
