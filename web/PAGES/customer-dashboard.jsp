<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="MODELS.Room" %>
<%@ page import="MODELS.Reservation" %>
<%@ page import="SERVICES.RoomService" %>
<%@ page import="SERVICES.ReservationService" %>
<%
    // ── Auth guard ────────────────────────────────────────────────────────────
    String username = (String) session.getAttribute("username");
    Integer userId  = (Integer) session.getAttribute("userId");
    if (username == null || userId == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    // ── Load rooms ────────────────────────────────────────────────────────────
    List<Room> rooms = (List<Room>) request.getAttribute("rooms");
    if (rooms == null) {
        RoomService roomService = new RoomService();
        rooms = roomService.getAllRooms();
    }

    // ── Load this guest's reservations ────────────────────────────────────────
    List<Reservation> myReservations = (List<Reservation>) request.getAttribute("myReservations");
    if (myReservations == null) {
        ReservationService resSvc = new ReservationService();
        myReservations = resSvc.getReservationsByUserId(userId);
    }

    // ── Flash messages ────────────────────────────────────────────────────────
    String msgType = (String) session.getAttribute("msgType");
    String msgText = (String) session.getAttribute("msgText");
    session.removeAttribute("msgType");
    session.removeAttribute("msgText");

    // ── Context path for JS (avoids repeated scriptlet calls inside script) ───
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Guest Dashboard - Ocean View Resort</title>
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f8f9fa; font-size: 14px; }
            header { position: fixed; top: 0; left: 0; right: 0; z-index: 1000; background: rgba(255,255,255,0.98); backdrop-filter: blur(10px); box-shadow: 0 2px 10px rgba(0,0,0,0.05); padding: 1rem 0; }
            nav { max-width: 1400px; margin: 0 auto; display: flex; justify-content: space-between; align-items: center; padding: 0 2rem; }
            .logo { font-size: 1.6rem; font-weight: bold; color: #ff6b35; text-decoration: none; }
            .nav-menu { display: flex; align-items: center; gap: 2rem; }
            .nav-links { display: flex; gap: 2rem; align-items: center; }
            .nav-links a { color: #2c3e50; text-decoration: none; font-weight: 600; font-size: 0.95rem; transition: color 0.3s ease; }
            .nav-links a:hover { color: #ff6b35; }
            .btn { padding: 0.6rem 1.5rem; border: none; border-radius: 8px; font-size: 0.9rem; cursor: pointer; transition: all 0.3s ease; font-weight: 600; text-decoration: none; display: inline-block; }
            .btn-login { background: transparent; color: #ff6b35; border: 2px solid #ff6b35; }
            .btn-login:hover { background: #ff6b35; color: white; }
            .btn-logout { padding: 0.5rem 1.2rem; background: #ff6b35; color: white; border: none; border-radius: 6px; cursor: pointer; font-size: 0.85rem; font-weight: 600; transition: all 0.3s ease; }
            .btn-logout:hover { background: #e55a2b; }
            .user-info { display: flex; align-items: center; gap: 1.5rem; }
            .username { color: #2c3e50; font-weight: 600; font-size: 0.9rem; padding: 0.5rem 1rem; background: #fff5f2; border-radius: 6px; }
            .container { max-width: 1400px; margin: 2rem auto; padding: 0 2rem; }
            .tabs { display: flex; gap: 0.5rem; margin-bottom: 2rem; border-bottom: 2px solid #e8e8e8; }
            .tab { padding: 0.8rem 1.5rem; background: transparent; border: none; cursor: pointer; font-size: 0.9rem; font-weight: 600; color: #5a6c7d; border-bottom: 3px solid transparent; transition: all 0.3s ease; }
            .tab.active { color: #ff6b35; border-bottom-color: #ff6b35; }
            .tab:hover { color: #ff6b35; }
            .tab-content { display: none; }
            .tab-content.active { display: block; }
            .rooms-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 1.5rem; margin-top: 1.5rem; }
            .room-card { background: white; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); overflow: hidden; transition: all 0.3s ease; border: 2px solid #f5f5f5; }
            .room-card:hover { transform: translateY(-5px); box-shadow: 0 5px 20px rgba(255,107,53,0.15); border-color: #ff6b35; }
            .room-card.unavailable { opacity: 0.6; background: #fafafa; border-color: #e0e0e0; }
            .room-card.unavailable:hover { transform: none; box-shadow: 0 2px 10px rgba(0,0,0,0.05); border-color: #e0e0e0; cursor: default; }
            .room-image { width: 100%; height: 180px; background: linear-gradient(135deg, #fff5f2 0%, #ffe8e0 100%); display: flex; align-items: center; justify-content: center; font-size: 3rem; color: #ff6b35; }
            .room-card.unavailable .room-image { background: linear-gradient(135deg, #f0f0f0 0%, #e0e0e0 100%); color: #aaa; }
            .room-details { padding: 1.2rem; }
            .room-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.8rem; }
            .room-number { font-size: 1.2rem; font-weight: bold; color: #2c3e50; }
            .room-type { font-size: 0.75rem; padding: 0.3rem 0.8rem; background: #fff5f2; color: #ff6b35; border-radius: 12px; font-weight: 600; }
            .room-status-badge { font-size: 0.72rem; padding: 0.25rem 0.7rem; border-radius: 12px; font-weight: 600; display: inline-block; margin-bottom: 0.6rem; }
            .room-status-occupied { background: #ffe5e5; color: #d32f2f; }
            .room-status-maintenance { background: #fff5e5; color: #e67e22; }
            .room-description { color: #5a6c7d; font-size: 0.85rem; margin-bottom: 1rem; line-height: 1.5; }
            .room-price { font-size: 1.3rem; color: #ff6b35; font-weight: bold; margin-bottom: 0.8rem; }
            .room-price span { font-size: 0.75rem; color: #5a6c7d; font-weight: normal; }
            .btn-book { width: 100%; padding: 0.7rem; background: #ff6b35; color: white; border: none; border-radius: 6px; cursor: pointer; font-size: 0.85rem; font-weight: 600; transition: all 0.3s ease; }
            .btn-book:hover { background: #e55a2b; }
            .btn-book:disabled { background: #ccc; cursor: not-allowed; color: #888; }
            .table-container { background: white; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.05); overflow: hidden; }
            table { width: 100%; border-collapse: collapse; }
            thead { background: #f8f9fa; }
            th { padding: 0.8rem 1rem; text-align: left; font-weight: 600; color: #2c3e50; font-size: 0.8rem; text-transform: uppercase; border-bottom: 2px solid #e8e8e8; }
            td { padding: 0.8rem 1rem; color: #5a6c7d; font-size: 0.85rem; border-bottom: 1px solid #f0f0f0; }
            tbody tr:hover { background: #f8f9fa; }
            .status-badge { padding: 0.3rem 0.8rem; border-radius: 12px; font-size: 0.75rem; font-weight: 600; }
            .status-paid { background: #e5ffe5; color: #2d7a2d; }
            .status-pending { background: #fff5e5; color: #e67e22; }
            .status-cancelled { background: #ffe5e5; color: #d32f2f; }
            .action-buttons { display: flex; gap: 0.5rem; }
            .btn-view, .btn-cancel { padding: 0.4rem 0.8rem; border: none; border-radius: 4px; cursor: pointer; font-size: 0.75rem; font-weight: 600; transition: all 0.3s ease; }
            .btn-view { background: #e5f5ff; color: #0066cc; border: 1px solid #0066cc; }
            .btn-view:hover { background: #0066cc; color: white; }
            .btn-cancel { background: #ffe5e5; color: #d32f2f; border: 1px solid #d32f2f; }
            .btn-cancel:hover { background: #d32f2f; color: white; }
            .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); overflow-y: auto; }
            .modal-content { background: white; margin: 3% auto; padding: 2rem; border-radius: 8px; max-width: 600px; position: relative; }
            .modal-header { margin-bottom: 1.5rem; }
            .modal-header h2 { color: #2c3e50; font-size: 1.4rem; }
            .close { position: absolute; right: 1.5rem; top: 1.5rem; font-size: 1.8rem; cursor: pointer; color: #999; }
            .close:hover { color: #ff6b35; }
            .form-group { margin-bottom: 1.2rem; }
            .form-group label { display: block; margin-bottom: 0.4rem; color: #2c3e50; font-weight: 600; font-size: 0.85rem; }
            .form-group input, .form-group select { width: 100%; padding: 0.6rem; border: 2px solid #e8e8e8; border-radius: 6px; font-size: 0.85rem; }
            .form-group input:focus, .form-group select:focus { outline: none; border-color: #ff6b35; }
            .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }
            .btn-submit { width: 100%; padding: 0.8rem; background: #ff6b35; color: white; border: none; border-radius: 6px; font-size: 0.9rem; font-weight: 600; cursor: pointer; margin-top: 1rem; }
            .btn-submit:hover { background: #e55a2b; }
            .booking-summary { background: #f8f9fa; padding: 1rem; border-radius: 6px; margin-top: 1rem; }
            .booking-summary h3 { color: #2c3e50; font-size: 1rem; margin-bottom: 0.8rem; }
            .summary-row { display: flex; justify-content: space-between; margin-bottom: 0.5rem; font-size: 0.85rem; }
            .summary-row.total { font-weight: bold; font-size: 1.1rem; color: #ff6b35; padding-top: 0.5rem; border-top: 2px solid #e8e8e8; margin-top: 0.5rem; }
            .filter-bar { background: white; padding: 1.2rem; border-radius: 8px; margin-bottom: 1.5rem; box-shadow: 0 2px 10px rgba(0,0,0,0.05); }
            .filter-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; }
            .empty-state { text-align: center; padding: 3rem; color: #5a6c7d; }
            .empty-state h3 { font-size: 1.2rem; margin-bottom: 0.5rem; }
            .alert { padding: 0.9rem 1.2rem; border-radius: 6px; margin-bottom: 1.5rem; font-size: 0.88rem; font-weight: 600; }
            .alert-success { background: #e5ffe5; color: #2d7a2d; border-left: 4px solid #2d7a2d; }
            .alert-error { background: #ffe5e5; color: #d32f2f; border-left: 4px solid #d32f2f; }
            @media (max-width: 768px) {
                .rooms-grid { grid-template-columns: 1fr; }
                .form-row, .filter-row { grid-template-columns: 1fr; }
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
                    <a href="<%= ctx %>/PAGES/home.jsp" class="btn btn-login">Home</a>
                    <a href="<%= ctx %>/PAGES/contact-us.jsp" class="btn btn-login">Contact Us</a>
                    <a href="<%= ctx %>/ReservationServlet" class="btn btn-login">Bookings</a>
                    <span class="username"><%= username %></span>
                    <button class="btn-logout" onclick="logout()">Logout</button>
                </div>
            </nav>
        </header>

        <!-- Main Container -->
        <div class="container" style="margin-top: 100px">

            <!-- Flash Message -->
            <% if (msgText != null) { %>
            <div class="alert alert-<%= msgType %>"><%= msgText %></div>
            <% } %>

            <!-- Tabs -->
            <div class="tabs">
                <button class="tab active" onclick="openTab('available-rooms', event)">Available Rooms</button>
                <button class="tab" onclick="openTab('my-reservations', event)">My Reservations</button>
            </div>

            <!-- Available Rooms Tab -->
            <div id="available-rooms" class="tab-content active">
                <div class="filter-bar">
                    <div class="filter-row">
                        <div class="form-group">
                            <label>Room Type</label>
                            <select id="filterType" onchange="filterRooms()">
                                <option value="">All Types</option>
                                <option value="Standard">Standard</option>
                                <option value="Deluxe">Deluxe</option>
                                <option value="Luxury">Luxury</option>
                                <option value="Suite">Suite</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Check-In Date</label>
                            <input type="date" id="filterCheckIn">
                        </div>
                        <div class="form-group">
                            <label>Check-Out Date</label>
                            <input type="date" id="filterCheckOut">
                        </div>
                    </div>
                </div>

                <div class="rooms-grid" id="roomsGrid">
                    <%
                        for (Room room : rooms) {
                            boolean isAvailable = "Available".equalsIgnoreCase(room.getAvailability());
                            String cardClass = isAvailable ? "room-card" : "room-card unavailable";
                            String icon = "🏨";
                            if ("Deluxe".equals(room.getRoomType()))      icon = "🌊";
                            else if ("Luxury".equals(room.getRoomType())) icon = "⭐";
                            else if ("Suite".equals(room.getRoomType()))  icon = "👑";
                            String statusBadgeClass = "room-status-occupied";
                            if ("Maintenance".equalsIgnoreCase(room.getAvailability()))
                                statusBadgeClass = "room-status-maintenance";
                            String desc = (room.getDescription() != null && !room.getDescription().isEmpty())
                                ? room.getDescription()
                                : room.getRoomType() + " room — comfortable and well-appointed.";
                    %>
                    <div class="<%= cardClass %>" data-type="<%= room.getRoomType() %>">
                        <div class="room-image"><%= icon %></div>
                        <div class="room-details">
                            <div class="room-header">
                                <div class="room-number">Room <%= room.getRoomNumber() %></div>
                                <div class="room-type"><%= room.getRoomType() %></div>
                            </div>
                            <% if (!isAvailable) { %>
                            <span class="room-status-badge <%= statusBadgeClass %>"><%= room.getAvailability() %></span>
                            <% } %>
                            <div class="room-description"><%= desc %></div>
                            <div class="room-price">
                                <%= String.format("%,.2f", room.getPricePerNight()) %> LKR <span>/ night</span>
                            </div>
                            <% if (isAvailable) { %>
                            <button class="btn-book" onclick="openBookingModal(
                                <%= room.getRoomId() %>,
                                '<%= room.getRoomNumber() %>',
                                '<%= room.getRoomType() %>',
                                <%= room.getPricePerNight() %>
                            )">Book Now</button>
                            <% } else { %>
                            <button class="btn-book" disabled>Not Available</button>
                            <% } %>
                        </div>
                    </div>
                    <% } %>

                    <% if (rooms.isEmpty()) { %>
                    <div class="empty-state" style="grid-column: 1/-1;">
                        <h3>No Rooms Found</h3>
                        <p>There are currently no rooms. Please check back later.</p>
                    </div>
                    <% } %>
                </div>
            </div>

            <!-- My Reservations Tab -->
            <div id="my-reservations" class="tab-content">
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Reservation ID</th>
                                <th>Room</th>
                                <th>Check-In</th>
                                <th>Check-Out</th>
                                <th>Nights</th>
                                <th>Total Amount</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (myReservations != null && !myReservations.isEmpty()) {
                                    for (Reservation res : myReservations) {
                                        String badgeClass = "status-pending";
                                        if ("Paid".equalsIgnoreCase(res.getPaymentStatus()))           badgeClass = "status-paid";
                                        else if ("Cancelled".equalsIgnoreCase(res.getPaymentStatus())) badgeClass = "status-cancelled";
                            %>
                            <tr>
                                <td>#<%= res.getReservationId() %></td>
                                <td><%= res.getRoomNumber() %> - <%= res.getRoomType() %></td>
                                <td><%= res.getCheckInDate() %></td>
                                <td><%= res.getCheckOutDate() %></td>
                                <td><%= res.getNumberOfNights() %></td>
                                <td><%= String.format("%,.2f", res.getTotalAmount()) %> LKR</td>
                                <td><span class="status-badge <%= badgeClass %>"><%= res.getPaymentStatus() %></span></td>
                                <td>
                                    <div class="action-buttons">
                                        <button class="btn-view" onclick="viewBill(
                                            <%= res.getReservationId() %>,
                                            '<%= res.getRoomNumber() %> - <%= res.getRoomType() %>',
                                            '<%= res.getCheckInDate() %>',
                                            '<%= res.getCheckOutDate() %>',
                                            <%= res.getNumberOfNights() %>,
                                            '<%= String.format("%,.2f", res.getTotalAmount()) %>',
                                            '<%= res.getPaymentStatus() %>'
                                        )">View Bill</button>
                                        <% if (!"Cancelled".equalsIgnoreCase(res.getPaymentStatus()) && !"Paid".equalsIgnoreCase(res.getPaymentStatus())) { %>
                                        <button class="btn-cancel" onclick="cancelReservation(<%= res.getReservationId() %>)">Cancel</button>
                                        <% } %>
                                    </div>
                                </td>
                            </tr>
                            <%
                                    }
                                } else {
                            %>
                            <tr>
                                <td colspan="8" style="text-align:center; padding:2rem; color:#999;">
                                    No reservations found. Book a room to get started!
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

        </div><!-- /container -->

        <!-- Booking Modal -->
        <div id="bookingModal" class="modal">
            <div class="modal-content">
                <span class="close" onclick="closeModal('bookingModal')">&times;</span>
                <div class="modal-header">
                    <h2>Book Room <span id="modalRoomNumber"></span></h2>
                </div>
                <form action="<%= ctx %>/ReservationServlet" method="POST">
                    <input type="hidden" name="action" value="book">
                    <input type="hidden" name="roomId"        id="roomId">
                    <input type="hidden" name="pricePerNight" id="roomPrice">

                    <div class="form-row">
                        <div class="form-group">
                            <label>Check-In Date</label>
                            <input type="date" name="checkIn" id="checkIn" required onchange="calculateTotal()">
                        </div>
                        <div class="form-group">
                            <label>Check-Out Date</label>
                            <input type="date" name="checkOut" id="checkOut" required onchange="calculateTotal()">
                        </div>
                    </div>

                    <div class="booking-summary">
                        <h3>Booking Summary</h3>
                        <div class="summary-row"><span>Room Type:</span><span id="summaryRoomType"></span></div>
                        <div class="summary-row"><span>Price per Night:</span><span id="summaryPricePerNight"></span></div>
                        <div class="summary-row"><span>Number of Nights:</span><span id="summaryNights">0</span></div>
                        <div class="summary-row total"><span>Total Amount:</span><span id="summaryTotal">0.00 LKR</span></div>
                    </div>

                    <button type="submit" class="btn-submit" onclick="return validateBooking()">Confirm Booking</button>
                </form>
            </div>
        </div>

        <!-- View Bill Modal -->
        <div id="billModal" class="modal">
            <div class="modal-content">
                <span class="close" onclick="closeModal('billModal')">&times;</span>
                <div class="modal-header"><h2>Reservation Bill</h2></div>
                <div class="booking-summary">
                    <h3>Bill Details</h3>
                    <div class="summary-row"><span>Reservation ID:</span><span id="billResId"></span></div>
                    <div class="summary-row"><span>Room:</span><span id="billRoom"></span></div>
                    <div class="summary-row"><span>Check-In:</span><span id="billCheckIn"></span></div>
                    <div class="summary-row"><span>Check-Out:</span><span id="billCheckOut"></span></div>
                    <div class="summary-row"><span>Number of Nights:</span><span id="billNights"></span></div>
                    <div class="summary-row total"><span>Total Amount:</span><span id="billTotal"></span></div>
                    <div class="summary-row"><span>Payment Status:</span><span id="billStatus"></span></div>
                </div>
                <button class="btn-submit" onclick="window.print()">Print Bill</button>
            </div>
        </div>

        <!-- Hidden cancel form -->
        <form id="cancelForm" action="<%= ctx %>/ReservationServlet" method="POST" style="display:none;">
            <input type="hidden" name="action" value="cancel">
            <input type="hidden" name="reservationId" id="cancelResId">
        </form>

        <script>
            // ── Context path from server (fixes all relative URL issues) ──────
            const CTX = '<%= ctx %>';

            function openTab(tabName, event) {
                document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
                document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
                document.getElementById(tabName).classList.add('active');
                if (event && event.target) event.target.classList.add('active');
            }

            function openModal(modalId)  { document.getElementById(modalId).style.display = 'block'; }
            function closeModal(modalId) { document.getElementById(modalId).style.display = 'none';  }

            window.onclick = function(event) {
                if (event.target.classList.contains('modal')) event.target.style.display = 'none';
            }

            function filterRooms() {
                const type = document.getElementById('filterType').value;
                document.querySelectorAll('.room-card').forEach(function(card) {
                    card.style.display = (!type || card.dataset.type === type) ? 'block' : 'none';
                });
            }

            function openBookingModal(roomId, roomNumber, roomType, price) {
                document.getElementById('roomId').value    = roomId;
                document.getElementById('roomPrice').value = price;
                document.getElementById('modalRoomNumber').textContent       = roomNumber;
                document.getElementById('summaryRoomType').textContent       = roomType;
                document.getElementById('summaryPricePerNight').textContent  = Number(price).toLocaleString() + '.00 LKR';
                document.getElementById('summaryNights').textContent = '0';
                document.getElementById('summaryTotal').textContent  = '0.00 LKR';
                document.getElementById('checkIn').value  = '';
                document.getElementById('checkOut').value = '';
                const today = new Date().toISOString().split('T')[0];
                document.getElementById('checkIn').min  = today;
                document.getElementById('checkOut').min = today;
                openModal('bookingModal');
            }

            function calculateTotal() {
                const checkIn  = new Date(document.getElementById('checkIn').value);
                const checkOut = new Date(document.getElementById('checkOut').value);
                const price    = parseFloat(document.getElementById('roomPrice').value);
                if (checkIn && checkOut && checkOut > checkIn) {
                    const nights = Math.ceil((checkOut - checkIn) / (1000 * 60 * 60 * 24));
                    const total  = nights * price;
                    document.getElementById('summaryNights').textContent = nights;
                    document.getElementById('summaryTotal').textContent  = total.toLocaleString() + '.00 LKR';
                    document.getElementById('checkOut').min = document.getElementById('checkIn').value;
                }
            }

            function validateBooking() {
                const checkIn  = new Date(document.getElementById('checkIn').value);
                const checkOut = new Date(document.getElementById('checkOut').value);
                if (!document.getElementById('checkIn').value ||
                    !document.getElementById('checkOut').value ||
                    checkOut <= checkIn) {
                    alert('Please select valid check-in and check-out dates.');
                    return false;
                }
                return true;
            }

            function viewBill(id, room, checkIn, checkOut, nights, total, status) {
                document.getElementById('billResId').textContent    = '#' + id;
                document.getElementById('billRoom').textContent     = room;
                document.getElementById('billCheckIn').textContent  = checkIn;
                document.getElementById('billCheckOut').textContent = checkOut;
                document.getElementById('billNights').textContent   = nights;
                document.getElementById('billTotal').textContent    = total + ' LKR';
                const statusEl = document.getElementById('billStatus');
                let cls = 'status-pending';
                if (status === 'Paid')      cls = 'status-paid';
                else if (status === 'Cancelled') cls = 'status-cancelled';
                statusEl.innerHTML = '<span class="status-badge ' + cls + '">' + status + '</span>';
                openModal('billModal');
            }

            function cancelReservation(id) {
                if (confirm('Are you sure you want to cancel reservation #' + id + '?')) {
                    document.getElementById('cancelResId').value = id;
                    document.getElementById('cancelForm').submit();
                }
            }

            // ── FIX: use CTX so logout always resolves correctly ──────────────
           function logout() {
    if (confirm('Are you sure you want to logout?')) {
        window.location.href = CTX + '/LogoutServlet';
    }
}

            setTimeout(function() {
                var alertEl = document.querySelector('.alert');
                if (alertEl) alertEl.style.display = 'none';
            }, 4000);
        </script>
    </body>
</html>
