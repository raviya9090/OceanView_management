<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="MODELS.Room" %>
<%@ page import="MODELS.Reservation" %>
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

    // ── Load rooms ────────────────────────────────────────────────────────────
    List<Room> rooms = (List<Room>) request.getAttribute("rooms");
    if (rooms == null) {
        RoomService roomService = new RoomService();
        rooms = roomService.getAllRooms();
    }

    // ── Load reservations ─────────────────────────────────────────────────────
    List<Reservation> reservations = (List<Reservation>) request.getAttribute("reservations");
    if (reservations == null) {
        ReservationService resSvc = new ReservationService();
        reservations = resSvc.getAllReservations();
    }

    // ── Stats ─────────────────────────────────────────────────────────────────
    int totalRooms     = rooms.size();
    long availableCount = rooms.stream().filter(r -> "Available".equals(r.getAvailability())).count();

    Integer totalReservations = (Integer) request.getAttribute("totalReservations");
    if (totalReservations == null) {
        ReservationService resSvc2 = new ReservationService();
        totalReservations = resSvc2.getTotalReservationCount();
    }
    Integer totalGuests = (Integer) request.getAttribute("totalGuests");
    if (totalGuests == null) {
        ReservationService resSvc3 = new ReservationService();
        totalGuests = resSvc3.getTotalGuestCount();
    }

    // ── Active tab ────────────────────────────────────────────────────────────
    String activeTab = (String) request.getAttribute("activeTab");
    if (activeTab == null) activeTab = "reservations";

    // ── Flash messages ────────────────────────────────────────────────────────
    String msgType = (String) session.getAttribute("msgType");
    String msgText = (String) session.getAttribute("msgText");
    session.removeAttribute("msgType");
    session.removeAttribute("msgText");
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
        .btn-logout { padding: 0.5rem 1.2rem; background: #ff6b35; color: white; border: none; border-radius: 6px; cursor: pointer; font-size: 0.85rem; font-weight: 600; transition: all 0.3s ease; }
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
        .action-bar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; gap: 1rem; }
        .search-box { flex: 1; max-width: 400px; }
        .search-box input { width: 100%; padding: 0.6rem 1rem; border: 2px solid #e8e8e8; border-radius: 6px; font-size: 0.85rem; }
        .search-box input:focus { outline: none; border-color: #ff6b35; }
        .btn-add { padding: 0.6rem 1.5rem; background: #ff6b35; color: white; border: none; border-radius: 6px; cursor: pointer; font-size: 0.85rem; font-weight: 600; transition: all 0.3s ease; }
        .btn-add:hover { background: #e55a2b; }
        .table-container { background: white; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); overflow: hidden; }
        table { width: 100%; border-collapse: collapse; }
        thead { background: #f8f9fa; }
        th { padding: 0.8rem 1rem; text-align: left; font-weight: 600; color: #2c3e50; font-size: 0.8rem; text-transform: uppercase; border-bottom: 2px solid #e8e8e8; }
        td { padding: 0.8rem 1rem; color: #5a6c7d; font-size: 0.85rem; border-bottom: 1px solid #f0f0f0; }
        tbody tr:hover { background: #f8f9fa; }
        .status-badge { padding: 0.3rem 0.8rem; border-radius: 12px; font-size: 0.75rem; font-weight: 600; }
        .status-available { background: #e5ffe5; color: #2d7a2d; }
        .status-occupied { background: #ffe5e5; color: #d32f2f; }
        .status-maintenance { background: #fff5e5; color: #e67e22; }
        .status-paid { background: #e5ffe5; color: #2d7a2d; }
        .status-pending { background: #fff5e5; color: #e67e22; }
        .status-cancelled { background: #ffe5e5; color: #d32f2f; }
        .action-buttons { display: flex; gap: 0.5rem; }
        .btn-edit, .btn-delete, .btn-view { padding: 0.4rem 0.8rem; border: none; border-radius: 4px; cursor: pointer; font-size: 0.75rem; font-weight: 600; transition: all 0.3s ease; }
        .btn-edit { background: #fff5f2; color: #ff6b35; border: 1px solid #ff6b35; }
        .btn-edit:hover { background: #ff6b35; color: white; }
        .btn-delete { background: #ffe5e5; color: #d32f2f; border: 1px solid #d32f2f; }
        .btn-delete:hover { background: #d32f2f; color: white; }
        .btn-view { background: #e5f5ff; color: #0066cc; border: 1px solid #0066cc; }
        .btn-view:hover { background: #0066cc; color: white; }
        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); overflow-y: auto; }
        .modal-content { background: white; margin: 3% auto; padding: 2rem; border-radius: 8px; max-width: 600px; position: relative; }
        .modal-header { margin-bottom: 1.5rem; }
        .modal-header h2 { color: #2c3e50; font-size: 1.4rem; }
        .close { position: absolute; right: 1.5rem; top: 1.5rem; font-size: 1.8rem; cursor: pointer; color: #999; }
        .close:hover { color: #ff6b35; }
        .form-group { margin-bottom: 1.2rem; }
        .form-group label { display: block; margin-bottom: 0.4rem; color: #2c3e50; font-weight: 600; font-size: 0.85rem; }
        .form-group input, .form-group select, .form-group textarea { width: 100%; padding: 0.6rem; border: 2px solid #e8e8e8; border-radius: 6px; font-size: 0.85rem; }
        .form-group input:focus, .form-group select:focus, .form-group textarea:focus { outline: none; border-color: #ff6b35; }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }
        .btn-submit { width: 100%; padding: 0.8rem; background: #ff6b35; color: white; border: none; border-radius: 6px; font-size: 0.9rem; font-weight: 600; cursor: pointer; margin-top: 1rem; }
        .btn-submit:hover { background: #e55a2b; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; margin-bottom: 2rem; }
        .stat-card { background: white; padding: 1.5rem; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); border-left: 4px solid #ff6b35; }
        .stat-card h3 { color: #5a6c7d; font-size: 0.8rem; text-transform: uppercase; margin-bottom: 0.5rem; }
        .stat-card p { color: #2c3e50; font-size: 1.8rem; font-weight: bold; }
        .alert { padding: 0.9rem 1.2rem; border-radius: 6px; margin-bottom: 1.5rem; font-size: 0.88rem; font-weight: 600; }
        .alert-success { background: #e5ffe5; color: #2d7a2d; border-left: 4px solid #2d7a2d; }
        .alert-error { background: #ffe5e5; color: #d32f2f; border-left: 4px solid #d32f2f; }
        @media (max-width: 768px) {
            .action-bar { flex-direction: column; align-items: stretch; }
            .search-box { max-width: 100%; }
            .form-row { grid-template-columns: 1fr; }
            table { font-size: 0.75rem; }
            th, td { padding: 0.5rem; }
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header>
        <nav>
            <div class="logo">Ocean View Resort</div>
            <div class="user-info">
                <span class="username">Admin</span>
                <button class="btn-logout" onclick="logout()">Logout</button>
            </div>
        </nav>
    </header>

    <!-- Main Container -->
    <div class="container">
        <div class="dashboard-header">
            <h1>Admin Dashboard</h1>
            <p>Manage reservations, rooms</p>
        </div>

        <!-- Flash Message -->
        <% if (msgText != null) { %>
        <div class="alert alert-<%= msgType %>"><%= msgText %></div>
        <% } %>

        <!-- Stats Cards -->
        <div class="stats-grid">
            <div class="stat-card"><h3>Total Rooms</h3><p><%= totalRooms %></p></div>
            <div class="stat-card"><h3>Available Rooms</h3><p><%= availableCount %></p></div>
            <div class="stat-card"><h3>Total Reservations</h3><p><%= totalReservations %></p></div>
            <div class="stat-card"><h3>Total Guests</h3><p><%= totalGuests %></p></div>
        </div>

        <!-- Tabs -->
        <div class="tabs">
            <button class="tab <%= "rooms".equals(activeTab) ? "active" : "" %>" onclick="openTab('rooms', event)">Rooms</button>
            <button class="tab <%= "reservations".equals(activeTab) ? "active" : "" %>" onclick="openTab('reservations', event)">Reservations</button>
        </div>

        <!-- Reservations Tab -->
        <div id="reservations" class="tab-content <%= "reservations".equals(activeTab) ? "active" : "" %>">
            <div class="action-bar">
                <div class="search-box">
                    <input type="text" id="resSearch" placeholder="Search by guest or room..." onkeyup="searchReservations()">
                </div>
                <button class="btn-add" onclick="openModal('addReservation')">Add Reservation</button>
            </div>

            <div class="table-container">
                <table id="reservationsTable">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Guest Name</th>
                            <th>Room</th>
                            <th>Check-In</th>
                            <th>Check-Out</th>
                            <th>Nights</th>
                            <th>Amount</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            if (reservations != null && !reservations.isEmpty()) {
                                for (Reservation res : reservations) {
                                    String badgeClass = "status-pending";
                                    if ("Paid".equalsIgnoreCase(res.getPaymentStatus()))        badgeClass = "status-paid";
                                    else if ("Cancelled".equalsIgnoreCase(res.getPaymentStatus())) badgeClass = "status-cancelled";

                                    // Safe room string for JS
                                    String safeRoom = (res.getRoomNumber() + " - " + res.getRoomType())
                                        .replace("'", "\\'");
                        %>
                        <tr>
                            <td><%= res.getReservationId() %></td>
                            <td><%= res.getUsername() %></td>
                            <td><%= res.getRoomNumber() %> - <%= res.getRoomType() %></td>
                            <td><%= res.getCheckInDate() %></td>
                            <td><%= res.getCheckOutDate() %></td>
                            <td><%= res.getNumberOfNights() %></td>
                            <td><%= String.format("%,.2f", res.getTotalAmount()) %></td>
                            <td><span class="status-badge <%= badgeClass %>"><%= res.getPaymentStatus() %></span></td>
                            <td>
                                <div class="action-buttons">
                                    <button class="btn-edit" onclick="openEditResModal(
                                        <%= res.getReservationId() %>,
                                        <%= res.getRoomId() %>,
                                        '<%= res.getCheckInDate() %>',
                                        '<%= res.getCheckOutDate() %>',
                                        '<%= res.getPaymentStatus() %>'
                                    )">Edit</button>
                                    <button class="btn-delete" onclick="confirmDeleteReservation(<%= res.getReservationId() %>)">Delete</button>
                                </div>
                            </td>
                        </tr>
                        <%
                                }
                            } else {
                        %>
                        <tr>
                            <td colspan="9" style="text-align:center; padding:2rem; color:#999;">No reservations found.</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Rooms Tab -->
        <div id="rooms" class="tab-content <%= "rooms".equals(activeTab) ? "active" : "" %>">
            <div class="action-bar">
                <button class="btn-add" onclick="openModal('addRoom')">Add Room</button>
            </div>

            <div class="table-container">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Room Number</th>
                            <th>Type</th>
                            <th>Price/Night</th>
                            <th>Status</th>
                            <th>Description</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            for (Room room : rooms) {
                                String avail = room.getAvailability();
                                String badgeClass = "status-available";
                                if ("Occupied".equalsIgnoreCase(avail))         badgeClass = "status-occupied";
                                else if ("Maintenance".equalsIgnoreCase(avail)) badgeClass = "status-maintenance";
                                String safeDesc = room.getDescription() != null
                                    ? room.getDescription().replace("\\", "\\\\").replace("'", "\\'") : "";
                                String displayDesc = room.getDescription() != null ? room.getDescription() : "";
                        %>
                        <tr>
                            <td><%= room.getRoomId() %></td>
                            <td><%= room.getRoomNumber() %></td>
                            <td><%= room.getRoomType() %></td>
                            <td><%= String.format("%,.2f", room.getPricePerNight()) %></td>
                            <td><span class="status-badge <%= badgeClass %>"><%= avail %></span></td>
                            <td><%= displayDesc %></td>
                            <td>
                                <div class="action-buttons">
                                    <button class="btn-edit" onclick="openEditModal(
                                        <%= room.getRoomId() %>,
                                        '<%= room.getRoomNumber() %>',
                                        '<%= room.getRoomType() %>',
                                        '<%= room.getPricePerNight() %>',
                                        '<%= avail %>',
                                        '<%= safeDesc %>'
                                    )">Edit</button>
                                    <button class="btn-delete" onclick="confirmDelete(<%= room.getRoomId() %>)">Delete</button>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                        <% if (rooms.isEmpty()) { %>
                        <tr><td colspan="7" style="text-align:center; padding:2rem; color:#999;">No rooms found.</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>

    </div><!-- /container -->

    <!-- ══ Add Reservation Modal ══════════════════════════════════════════════ -->
    <div id="addReservation" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal('addReservation')">&times;</span>
            <div class="modal-header"><h2>Add New Reservation</h2></div>
            <form action="<%= request.getContextPath() %>/ReservationServlet" method="POST">
                <input type="hidden" name="action" value="add">
                <div class="form-group">
                    <label>Guest (User ID)</label>
                    <input type="number" name="userId" placeholder="Enter user ID" required min="1">
                </div>
                <div class="form-group">
                    <label>Room</label>
                    <select name="roomId" id="addRoomSelect" onchange="updateRoomPrice()" required>
                        <option value="">Select Room</option>
                        <%
                            for (Room room : rooms) {
                                if ("Available".equalsIgnoreCase(room.getAvailability())) {
                        %>
                        <option value="<%= room.getRoomId() %>" data-price="<%= room.getPricePerNight() %>">
                            <%= room.getRoomNumber() %> - <%= room.getRoomType() %> (<%= String.format("%,.2f", room.getPricePerNight()) %>/night)
                        </option>
                        <%
                                }
                            }
                        %>
                    </select>
                </div>
                <input type="hidden" name="pricePerNight" id="addPricePerNight" value="0">
                <div class="form-row">
                    <div class="form-group">
                        <label>Check-In Date</label>
                        <input type="date" name="checkIn" required>
                    </div>
                    <div class="form-group">
                        <label>Check-Out Date</label>
                        <input type="date" name="checkOut" required>
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

    <!-- ══ Edit Reservation Modal ═════════════════════════════════════════════ -->
    <div id="editReservation" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal('editReservation')">&times;</span>
            <div class="modal-header"><h2>Edit Reservation</h2></div>
            <form action="<%= request.getContextPath() %>/ReservationServlet" method="POST">
                <input type="hidden" name="action" value="edit">
                <input type="hidden" name="reservationId" id="editResId">
                <div class="form-group">
                    <label>Room</label>
                    <select name="roomId" id="editResRoomId" onchange="updateEditRoomPrice()" required>
                        <%
                            for (Room room : rooms) {
                        %>
                        <option value="<%= room.getRoomId() %>" data-price="<%= room.getPricePerNight() %>">
                            <%= room.getRoomNumber() %> - <%= room.getRoomType() %> (<%= String.format("%,.2f", room.getPricePerNight()) %>/night)
                        </option>
                        <%
                            }
                        %>
                    </select>
                </div>
                <input type="hidden" name="pricePerNight" id="editResPricePerNight" value="0">
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

    <!-- ══ Add Room Modal ════════════════════════════════════════════════════ -->
    <div id="addRoom" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal('addRoom')">&times;</span>
            <div class="modal-header"><h2>Add New Room</h2></div>
            <form action="<%= request.getContextPath() %>/RoomServlet" method="POST">
                <input type="hidden" name="action" value="add">
                <div class="form-row">
                    <div class="form-group">
                        <label>Room Number</label>
                        <input type="text" name="roomNumber" placeholder="e.g., 105" required>
                    </div>
                    <div class="form-group">
                        <label>Room Type</label>
                        <select name="roomType" required>
                            <option value="">Select Type</option>
                            <option value="Standard">Standard</option>
                            <option value="Deluxe">Deluxe</option>
                            <option value="Luxury">Luxury</option>
                            <option value="Suite">Suite</option>
                        </select>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label>Price Per Night</label>
                        <input type="number" name="pricePerNight" placeholder="0.00" step="0.01" min="1" required>
                    </div>
                    <div class="form-group">
                        <label>Availability</label>
                        <select name="availability" required>
                            <option value="Available">Available</option>
                            <option value="Occupied">Occupied</option>
                            <option value="Maintenance">Maintenance</option>
                        </select>
                    </div>
                </div>
                <div class="form-group">
                    <label>Description</label>
                    <textarea rows="3" name="description" placeholder="Room description..."></textarea>
                </div>
                <button type="submit" class="btn-submit">Add Room</button>
            </form>
        </div>
    </div>

    <!-- ══ Edit Room Modal ═══════════════════════════════════════════════════ -->
    <div id="editRoom" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal('editRoom')">&times;</span>
            <div class="modal-header"><h2>Edit Room</h2></div>
            <form action="<%= request.getContextPath() %>/RoomServlet" method="POST">
                <input type="hidden" name="action" value="edit">
                <input type="hidden" name="roomId" id="editRoomId">
                <div class="form-row">
                    <div class="form-group">
                        <label>Room Number</label>
                        <input type="text" name="roomNumber" id="editRoomNumber" required>
                    </div>
                    <div class="form-group">
                        <label>Room Type</label>
                        <select name="roomType" id="editRoomType" required>
                            <option value="Standard">Standard</option>
                            <option value="Deluxe">Deluxe</option>
                            <option value="Luxury">Luxury</option>
                            <option value="Suite">Suite</option>
                        </select>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label>Price Per Night</label>
                        <input type="number" name="pricePerNight" id="editPricePerNight" step="0.01" min="1" required>
                    </div>
                    <div class="form-group">
                        <label>Availability</label>
                        <select name="availability" id="editAvailability" required>
                            <option value="Available">Available</option>
                            <option value="Occupied">Occupied</option>
                            <option value="Maintenance">Maintenance</option>
                        </select>
                    </div>
                </div>
                <div class="form-group">
                    <label>Description</label>
                    <textarea rows="3" name="description" id="editDescription"></textarea>
                </div>
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
        // Tab functionality
        function openTab(tabName, event) {
            document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
            document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
            document.getElementById(tabName).classList.add('active');
            if (event && event.target) event.target.classList.add('active');
        }

        function openModal(modalId)  { document.getElementById(modalId).style.display = 'block'; }
        function closeModal(modalId) { document.getElementById(modalId).style.display = 'none'; }

        window.onclick = function(event) {
            if (event.target.classList.contains('modal')) event.target.style.display = 'none';
        }

        // ── Room edit modal ───────────────────────────────────────────────────
        function openEditModal(id, roomNumber, roomType, price, availability, description) {
            document.getElementById('editRoomId').value        = id;
            document.getElementById('editRoomNumber').value    = roomNumber;
            document.getElementById('editRoomType').value      = roomType;
            document.getElementById('editPricePerNight').value = price;
            document.getElementById('editAvailability').value  = availability;
            document.getElementById('editDescription').value   = description;
            openModal('editRoom');
        }

        function confirmDelete(id) {
            if (confirm('Are you sure you want to delete this room?')) {
                document.getElementById('deleteRoomId').value = id;
                document.getElementById('deleteRoomForm').submit();
            }
        }

        // ── Reservation edit modal ────────────────────────────────────────────
        function openEditResModal(resId, roomId, checkIn, checkOut, status) {
            document.getElementById('editResId').value       = resId;
            document.getElementById('editResRoomId').value   = roomId;
            document.getElementById('editResCheckIn').value  = checkIn;
            document.getElementById('editResCheckOut').value = checkOut;
            document.getElementById('editResStatus').value   = status;
            updateEditRoomPrice();
            openModal('editReservation');
        }

        function confirmDeleteReservation(id) {
            if (confirm('Are you sure you want to delete reservation #' + id + '?')) {
                document.getElementById('deleteResId').value = id;
                document.getElementById('deleteResForm').submit();
            }
        }

        // ── Auto-fill price from room dropdown (Add Reservation) ─────────────
        function updateRoomPrice() {
            const sel = document.getElementById('addRoomSelect');
            const opt = sel.options[sel.selectedIndex];
            document.getElementById('addPricePerNight').value = opt ? (opt.dataset.price || 0) : 0;
        }

        function updateEditRoomPrice() {
            const sel = document.getElementById('editResRoomId');
            const opt = sel.options[sel.selectedIndex];
            document.getElementById('editResPricePerNight').value = opt ? (opt.dataset.price || 0) : 0;
        }

        // ── Search reservations ───────────────────────────────────────────────
        function searchReservations() {
            const q = document.getElementById('resSearch').value.toLowerCase();
            document.querySelectorAll('#reservationsTable tbody tr').forEach(function(row) {
                const text = row.textContent.toLowerCase();
                row.style.display = text.includes(q) ? '' : 'none';
            });
        }

        function logout() {
            if (confirm('Are you sure you want to logout?')) {
                window.location.href = 'LogoutServlet';
            }
        }

        setTimeout(function() {
            var alertEl = document.querySelector('.alert');
            if (alertEl) alertEl.style.display = 'none';
        }, 4000);
    </script>
</body>
</html>
