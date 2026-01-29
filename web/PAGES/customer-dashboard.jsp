<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Guest Dashboard - Ocean View Resort</title>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }

            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background-color: #f8f9fa;
                font-size: 14px;
            }

            /* Header */
          header {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    z-index: 1000;
    background: rgba(255, 255, 255, 0.98);
    backdrop-filter: blur(10px);
    box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
    padding: 1rem 0;
}

nav {
    max-width: 1400px;
    margin: 0 auto;
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 0 2rem;
}

.logo {
    font-size: 1.6rem;
    font-weight: bold;
    color: #ff6b35;
    text-decoration: none;
    transition: color 0.3s ease;
}

.logo:hover {
    color: #e55a2b;
}

/* Navigation Menu */
.nav-menu {
    display: flex;
    align-items: center;
    gap: 2rem;
}

.nav-links {
    display: flex;
    gap: 2rem;
    align-items: center;
}

.nav-links a {
    color: #2c3e50;
    text-decoration: none;
    font-weight: 600;
    font-size: 0.95rem;
    transition: color 0.3s ease;
    position: relative;
}

.nav-links a:hover {
    color: #ff6b35;
}

.nav-links a.active {
    color: #ff6b35;
}

.nav-links a::after {
    content: '';
    position: absolute;
    width: 0;
    height: 2px;
    bottom: -5px;
    left: 0;
    background-color: #ff6b35;
    transition: width 0.3s ease;
}

.nav-links a:hover::after,
.nav-links a.active::after {
    width: 100%;
}

/* Navigation Buttons */
.nav-buttons {
    display: flex;
    gap: 1rem;
}

.btn {
    padding: 0.6rem 1.5rem;
    border: none;
    border-radius: 8px;
    font-size: 0.9rem;
    cursor: pointer;
    transition: all 0.3s ease;
    font-weight: 600;
    text-decoration: none;
    display: inline-block;
}

.btn-login {
    background: transparent;
    color: #ff6b35;
    border: 2px solid #ff6b35;
}

.btn-login:hover {
    background: #ff6b35;
    color: white;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(255, 107, 53, 0.3);
}

.btn-register {
    background: #ff6b35;
    color: white;
    border: 2px solid #ff6b35;
}

.btn-register:hover {
    background: #e55a2b;
    border-color: #e55a2b;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(255, 107, 53, 0.4);
}

      .btn-logout {
                padding: 0.5rem 1.2rem;
                background: #ff6b35;
                color: white;
                border: none;
                border-radius: 6px;
                cursor: pointer;
                font-size: 0.85rem;
                font-weight: 600;
                transition: all 0.3s ease;
            }

.btn-logout:hover {
    background: #e55a2b;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(255, 107, 53, 0.4);
}

/* User Info (for Guest Dashboard) */
.user-info {
    display: flex;
    align-items: center;
    gap: 1.5rem;
}

.username {
    color: #2c3e50;
    font-weight: 600;
    font-size: 0.9rem;
    padding: 0.5rem 1rem;
    background: #fff5f2;
    border-radius: 6px;
}

/* Mobile Menu Button */
.mobile-menu-btn {
    display: none;
    background: none;
    border: none;
    font-size: 1.5rem;
    color: #ff6b35;
    cursor: pointer;
    padding: 0.5rem;
}

.mobile-menu-btn:hover {
    color: #e55a2b;
}

/* Mobile Navigation */
.mobile-nav {
    display: none;
    position: fixed;
    top: 70px;
    left: 0;
    right: 0;
    background: white;
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
    padding: 1rem 2rem;
    flex-direction: column;
    gap: 1rem;
}

.mobile-nav.active {
    display: flex;
}

.mobile-nav a {
    color: #2c3e50;
    text-decoration: none;
    font-weight: 600;
    padding: 0.8rem;
    border-radius: 6px;
    transition: all 0.3s ease;
}

.mobile-nav a:hover {
    background: #fff5f2;
    color: #ff6b35;
}

/* Responsive Design */
@media (max-width: 968px) {
    nav {
        padding: 0 1.5rem;
    }

    .logo {
        font-size: 1.4rem;
    }

    .nav-menu {
        display: none;
    }

    .mobile-menu-btn {
        display: block;
    }

    .user-info {
        gap: 1rem;
    }

    .username {
        display: none;
    }
}

@media (max-width: 480px) {
    .logo {
        font-size: 1.2rem;
    }

    .btn {
        padding: 0.5rem 1rem;
        font-size: 0.85rem;
    }
}

            /* Main Container */
            .container {
                max-width: 1400px;
                margin: 2rem auto;
                padding: 0 2rem;
            }

            .dashboard-header {
                margin-bottom: 2rem;
            }

            .dashboard-header h1 {
                color: #2c3e50;
                font-size: 1.8rem;
                margin-bottom: 0.5rem;
            }

            .dashboard-header p {
                color: #5a6c7d;
                font-size: 0.9rem;
            }

            /* Tabs */
            .tabs {
                display: flex;
                gap: 0.5rem;
                margin-bottom: 2rem;
                border-bottom: 2px solid #e8e8e8;
            }

            .tab {
                padding: 0.8rem 1.5rem;
                background: transparent;
                border: none;
                cursor: pointer;
                font-size: 0.9rem;
                font-weight: 600;
                color: #5a6c7d;
                border-bottom: 3px solid transparent;
                transition: all 0.3s ease;
            }

            .tab.active {
                color: #ff6b35;
                border-bottom-color: #ff6b35;
            }

            .tab:hover {
                color: #ff6b35;
            }

            /* Content Panels */
            .tab-content {
                display: none;
            }

            .tab-content.active {
                display: block;
            }

            /* Room Cards Grid */
            .rooms-grid {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
                gap: 1.5rem;
                margin-top: 1.5rem;
            }

            .room-card {
                background: white;
                border-radius: 8px;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
                overflow: hidden;
                transition: all 0.3s ease;
                border: 2px solid #f5f5f5;
            }

            .room-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 5px 20px rgba(255, 107, 53, 0.15);
                border-color: #ff6b35;
            }

            .room-image {
                width: 100%;
                height: 180px;
                background: linear-gradient(135deg, #fff5f2 0%, #ffe8e0 100%);
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 3rem;
                color: #ff6b35;
            }

            .room-details {
                padding: 1.2rem;
            }

            .room-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 0.8rem;
            }

            .room-number {
                font-size: 1.2rem;
                font-weight: bold;
                color: #2c3e50;
            }

            .room-type {
                font-size: 0.75rem;
                padding: 0.3rem 0.8rem;
                background: #fff5f2;
                color: #ff6b35;
                border-radius: 12px;
                font-weight: 600;
            }

            .room-description {
                color: #5a6c7d;
                font-size: 0.85rem;
                margin-bottom: 1rem;
                line-height: 1.5;
            }

            .room-price {
                font-size: 1.3rem;
                color: #ff6b35;
                font-weight: bold;
                margin-bottom: 0.8rem;
            }

            .room-price span {
                font-size: 0.75rem;
                color: #5a6c7d;
                font-weight: normal;
            }

            .btn-book {
                width: 100%;
                padding: 0.7rem;
                background: #ff6b35;
                color: white;
                border: none;
                border-radius: 6px;
                cursor: pointer;
                font-size: 0.85rem;
                font-weight: 600;
                transition: all 0.3s ease;
            }

            .btn-book:hover {
                background: #e55a2b;
            }

            .btn-book:disabled {
                background: #ccc;
                cursor: not-allowed;
            }

            /* Table */
            .table-container {
                background: white;
                border-radius: 8px;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
                overflow: hidden;
            }

            table {
                width: 100%;
                border-collapse: collapse;
            }

            thead {
                background: #f8f9fa;
            }

            th {
                padding: 0.8rem 1rem;
                text-align: left;
                font-weight: 600;
                color: #2c3e50;
                font-size: 0.8rem;
                text-transform: uppercase;
                border-bottom: 2px solid #e8e8e8;
            }

            td {
                padding: 0.8rem 1rem;
                color: #5a6c7d;
                font-size: 0.85rem;
                border-bottom: 1px solid #f0f0f0;
            }

            tbody tr:hover {
                background: #f8f9fa;
            }

            .status-badge {
                padding: 0.3rem 0.8rem;
                border-radius: 12px;
                font-size: 0.75rem;
                font-weight: 600;
            }

            .status-paid {
                background: #e5ffe5;
                color: #2d7a2d;
            }

            .status-pending {
                background: #fff5e5;
                color: #e67e22;
            }

            .status-cancelled {
                background: #ffe5e5;
                color: #d32f2f;
            }

            /* Action Buttons */
            .action-buttons {
                display: flex;
                gap: 0.5rem;
            }

            .btn-view, .btn-cancel {
                padding: 0.4rem 0.8rem;
                border: none;
                border-radius: 4px;
                cursor: pointer;
                font-size: 0.75rem;
                font-weight: 600;
                transition: all 0.3s ease;
            }

            .btn-view {
                background: #e5f5ff;
                color: #0066cc;
                border: 1px solid #0066cc;
            }

            .btn-view:hover {
                background: #0066cc;
                color: white;
            }

            .btn-cancel {
                background: #ffe5e5;
                color: #d32f2f;
                border: 1px solid #d32f2f;
            }

            .btn-cancel:hover {
                background: #d32f2f;
                color: white;
            }

            /* Modal */
            .modal {
                display: none;
                position: fixed;
                z-index: 1000;
                left: 0;
                top: 0;
                width: 100%;
                height: 100%;
                background: rgba(0, 0, 0, 0.5);
                overflow-y: auto;
            }

            .modal-content {
                background: white;
                margin: 3% auto;
                padding: 2rem;
                border-radius: 8px;
                max-width: 600px;
                position: relative;
            }

            .modal-header {
                margin-bottom: 1.5rem;
            }

            .modal-header h2 {
                color: #2c3e50;
                font-size: 1.4rem;
            }

            .close {
                position: absolute;
                right: 1.5rem;
                top: 1.5rem;
                font-size: 1.8rem;
                cursor: pointer;
                color: #999;
            }

            .close:hover {
                color: #ff6b35;
            }

            .form-group {
                margin-bottom: 1.2rem;
            }

            .form-group label {
                display: block;
                margin-bottom: 0.4rem;
                color: #2c3e50;
                font-weight: 600;
                font-size: 0.85rem;
            }

            .form-group input,
            .form-group select {
                width: 100%;
                padding: 0.6rem;
                border: 2px solid #e8e8e8;
                border-radius: 6px;
                font-size: 0.85rem;
            }

            .form-group input:focus,
            .form-group select:focus {
                outline: none;
                border-color: #ff6b35;
            }

            .form-row {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 1rem;
            }

            .btn-submit {
                width: 100%;
                padding: 0.8rem;
                background: #ff6b35;
                color: white;
                border: none;
                border-radius: 6px;
                font-size: 0.9rem;
                font-weight: 600;
                cursor: pointer;
                margin-top: 1rem;
            }

            .btn-submit:hover {
                background: #e55a2b;
            }

            .booking-summary {
                background: #f8f9fa;
                padding: 1rem;
                border-radius: 6px;
                margin-top: 1rem;
            }

            .booking-summary h3 {
                color: #2c3e50;
                font-size: 1rem;
                margin-bottom: 0.8rem;
            }

            .summary-row {
                display: flex;
                justify-content: space-between;
                margin-bottom: 0.5rem;
                font-size: 0.85rem;
            }

            .summary-row.total {
                font-weight: bold;
                font-size: 1.1rem;
                color: #ff6b35;
                padding-top: 0.5rem;
                border-top: 2px solid #e8e8e8;
                margin-top: 0.5rem;
            }

            /* Filter Section */
            .filter-bar {
                background: white;
                padding: 1.2rem;
                border-radius: 8px;
                margin-bottom: 1.5rem;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            }

            .filter-row {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                gap: 1rem;
            }

            .empty-state {
                text-align: center;
                padding: 3rem;
                color: #5a6c7d;
            }

            .empty-state h3 {
                font-size: 1.2rem;
                margin-bottom: 0.5rem;
            }

            @media (max-width: 768px) {
                .rooms-grid {
                    grid-template-columns: 1fr;
                }

                .form-row, .filter-row {
                    grid-template-columns: 1fr;
                }

                table {
                    font-size: 0.75rem;
                }

                th, td {
                    padding: 0.5rem;
                }
            }
        </style>
    </head>
    <body>
        <!-- Header -->
        <header>
            <nav>
                <div class="logo">Ocean View Resort</div>
                <div class="user-info">
                    <a href="./home.jsp" class="btn btn-login">Home</a>
                    <a href="./contact-us.jsp" class="btn btn-login">Contact Us</a>
                    <a href="./customer-dashboard.jsp" class="btn btn-login">Bookings</a>
                    <span class="username">Guest</span>
                    <button class="btn-logout" onclick="logout()">Logout</button>
                </div>
            </nav>
        </header>

        <!-- Main Container -->
        <div class="container" style="margin-top: 100px">
          

            <!-- Tabs -->
            <div class="tabs">
                <button class="tab active" onclick="openTab('available-rooms')">Available Rooms</button>
                <button class="tab" onclick="openTab('my-reservations')">My Reservations</button>
            </div>

            <!-- Available Rooms Tab -->
            <div id="available-rooms" class="tab-content active">
                <div class="filter-bar">
                    <div class="filter-row">
                        <div class="form-group">
                            <label>Room Type</label>
                            <select>
                                <option value="">All Types</option>
                                <option value="Standard">Standard</option>
                                <option value="Deluxe">Deluxe</option>
                                <option value="Luxury">Luxury</option>
                                <option value="Suite">Suite</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Check-In Date</label>
                            <input type="date">
                        </div>
                        <div class="form-group">
                            <label>Check-Out Date</label>
                            <input type="date">
                        </div>
                    </div>
                </div>

                <div class="rooms-grid">
                    <!-- Room Card 1 -->
                    <div class="room-card">
                        <div class="room-image">ROOM</div>
                        <div class="room-details">
                            <div class="room-header">
                                <div class="room-number">Room 101</div>
                                <div class="room-type">Standard</div>
                            </div>
                            <div class="room-description">
                                Standard room with sea view and single bed. Perfect for solo travelers.
                            </div>
                            <div class="room-price">
                                5,000.00 LKR <span>/ night</span>
                            </div>
                            <button class="btn-book" onclick="openBookingModal(1, '101', 'Standard', 5000)">Book Now</button>
                        </div>
                    </div>

                    <!-- Room Card 2 -->
                    <div class="room-card">
                        <div class="room-image">ROOM</div>
                        <div class="room-details">
                            <div class="room-header">
                                <div class="room-number">Room 102</div>
                                <div class="room-type">Standard</div>
                            </div>
                            <div class="room-description">
                                Standard room with garden view and double bed. Comfortable and cozy.
                            </div>
                            <div class="room-price">
                                5,000.00 LKR <span>/ night</span>
                            </div>
                            <button class="btn-book" onclick="openBookingModal(2, '102', 'Standard', 5000)">Book Now</button>
                        </div>
                    </div>

                    <!-- Room Card 3 -->
                    <div class="room-card">
                        <div class="room-image">ROOM</div>
                        <div class="room-details">
                            <div class="room-header">
                                <div class="room-number">Room 201</div>
                                <div class="room-type">Deluxe</div>
                            </div>
                            <div class="room-description">
                                Deluxe room with balcony and sea view. Spacious and elegant.
                            </div>
                            <div class="room-price">
                                8,000.00 LKR <span>/ night</span>
                            </div>
                            <button class="btn-book" onclick="openBookingModal(5, '201', 'Deluxe', 8000)">Book Now</button>
                        </div>
                    </div>

                    <!-- Room Card 4 -->
                    <div class="room-card">
                        <div class="room-image">ROOM</div>
                        <div class="room-details">
                            <div class="room-header">
                                <div class="room-number">Room 301</div>
                                <div class="room-type">Luxury</div>
                            </div>
                            <div class="room-description">
                                Luxury room with king bed and ocean view. Premium comfort.
                            </div>
                            <div class="room-price">
                                12,000.00 LKR <span>/ night</span>
                            </div>
                            <button class="btn-book" onclick="openBookingModal(9, '301', 'Luxury', 12000)">Book Now</button>
                        </div>
                    </div>

                    <!-- Room Card 5 -->
                    <div class="room-card">
                        <div class="room-image">ROOM</div>
                        <div class="room-details">
                            <div class="room-header">
                                <div class="room-number">Room 401</div>
                                <div class="room-type">Suite</div>
                            </div>
                            <div class="room-description">
                                Presidential suite with private pool and ocean view. Ultimate luxury.
                            </div>
                            <div class="room-price">
                                20,000.00 LKR <span>/ night</span>
                            </div>
                            <button class="btn-book" onclick="openBookingModal(13, '401', 'Suite', 20000)">Book Now</button>
                        </div>
                    </div>
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
                            <tr>
                                <td>#001</td>
                                <td>101 - Standard</td>
                                <td>2026-01-15</td>
                                <td>2026-01-19</td>
                                <td>4</td>
                                <td>20,000.00 LKR</td>
                                <td><span class="status-badge status-paid">Paid</span></td>
                                <td>
                                    <div class="action-buttons">
                                        <button class="btn-view" onclick="viewReservation(1)">View Bill</button>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td>#005</td>
                                <td>301 - Luxury</td>
                                <td>2026-02-05</td>
                                <td>2026-02-10</td>
                                <td>5</td>
                                <td>60,000.00 LKR</td>
                                <td><span class="status-badge status-pending">Pending</span></td>
                                <td>
                                    <div class="action-buttons">
                                        <button class="btn-view" onclick="viewReservation(5)">View Bill</button>
                                        <button class="btn-cancel" onclick="cancelReservation(5)">Cancel</button>
                                    </div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>


        </div>

        <!-- Booking Modal -->
        <div id="bookingModal" class="modal">
            <div class="modal-content">
                <span class="close" onclick="closeModal('bookingModal')">&times;</span>
                <div class="modal-header">
                    <h2>Book Room <span id="modalRoomNumber"></span></h2>
                </div>
                <form onsubmit="submitBooking(event)">
                    <input type="hidden" id="roomId">
                    <input type="hidden" id="roomPrice">

                    <div class="form-row">
                        <div class="form-group">
                            <label>Check-In Date</label>
                            <input type="date" id="checkIn" required onchange="calculateTotal()">
                        </div>
                        <div class="form-group">
                            <label>Check-Out Date</label>
                            <input type="date" id="checkOut" required onchange="calculateTotal()">
                        </div>
                    </div>

                    <div class="booking-summary">
                        <h3>Booking Summary</h3>
                        <div class="summary-row">
                            <span>Room Type:</span>
                            <span id="summaryRoomType"></span>
                        </div>
                        <div class="summary-row">
                            <span>Price per Night:</span>
                            <span id="summaryPricePerNight"></span>
                        </div>
                        <div class="summary-row">
                            <span>Number of Nights:</span>
                            <span id="summaryNights">0</span>
                        </div>
                        <div class="summary-row total">
                            <span>Total Amount:</span>
                            <span id="summaryTotal">0.00 LKR</span>
                        </div>
                    </div>

                    <button type="submit" class="btn-submit">Confirm Booking</button>
                </form>
            </div>
        </div>

        <!-- View Bill Modal -->
        <div id="billModal" class="modal">
            <div class="modal-content">
                <span class="close" onclick="closeModal('billModal')">&times;</span>
                <div class="modal-header">
                    <h2>Reservation Bill</h2>
                </div>
                <div class="booking-summary">
                    <h3>Bill Details</h3>
                    <div class="summary-row">
                        <span>Reservation ID:</span>
                        <span>#001</span>
                    </div>
                    <div class="summary-row">
                        <span>Room:</span>
                        <span>101 - Standard</span>
                    </div>
                    <div class="summary-row">
                        <span>Check-In:</span>
                        <span>2026-01-15</span>
                    </div>
                    <div class="summary-row">
                        <span>Check-Out:</span>
                        <span>2026-01-19</span>
                    </div>
                    <div class="summary-row">
                        <span>Number of Nights:</span>
                        <span>4</span>
                    </div>
                    <div class="summary-row">
                        <span>Price per Night:</span>
                        <span>5,000.00 LKR</span>
                    </div>
                    <div class="summary-row total">
                        <span>Total Amount:</span>
                        <span>20,000.00 LKR</span>
                    </div>
                    <div class="summary-row">
                        <span>Payment Status:</span>
                        <span class="status-badge status-paid">Paid</span>
                    </div>
                </div>
                <button class="btn-submit" onclick="window.print()">Print Bill</button>
            </div>
        </div>

        <script>
            // Tab functionality
            function openTab(tabName) {
                const contents = document.querySelectorAll('.tab-content');
                const tabs = document.querySelectorAll('.tab');

                contents.forEach(content => content.classList.remove('active'));
                tabs.forEach(tab => tab.classList.remove('active'));

                document.getElementById(tabName).classList.add('active');
                event.target.classList.add('active');
            }

            // Modal functions
            function openModal(modalId) {
                document.getElementById(modalId).style.display = 'block';
            }

            function closeModal(modalId) {
                document.getElementById(modalId).style.display = 'none';
            }

            window.onclick = function (event) {
                if (event.target.classList.contains('modal')) {
                    event.target.style.display = 'none';
                }
            }

            // Booking Modal
            function openBookingModal(roomId, roomNumber, roomType, price) {
                document.getElementById('roomId').value = roomId;
                document.getElementById('roomPrice').value = price;
                document.getElementById('modalRoomNumber').textContent = roomNumber;
                document.getElementById('summaryRoomType').textContent = roomType;
                document.getElementById('summaryPricePerNight').textContent = price.toLocaleString() + '.00 LKR';

                // Set minimum date to today
                const today = new Date().toISOString().split('T')[0];
                document.getElementById('checkIn').min = today;
                document.getElementById('checkOut').min = today;

                openModal('bookingModal');
            }

            // Calculate total amount
            function calculateTotal() {
                const checkIn = new Date(document.getElementById('checkIn').value);
                const checkOut = new Date(document.getElementById('checkOut').value);
                const price = parseFloat(document.getElementById('roomPrice').value);

                if (checkIn && checkOut && checkOut > checkIn) {
                    const nights = Math.ceil((checkOut - checkIn) / (1000 * 60 * 60 * 24));
                    const total = nights * price;

                    document.getElementById('summaryNights').textContent = nights;
                    document.getElementById('summaryTotal').textContent = total.toLocaleString() + '.00 LKR';
                }
            }

            // Submit booking
            function submitBooking(event) {
                event.preventDefault();
                alert('Booking submitted successfully!');
                closeModal('bookingModal');
                // Implement booking logic here
            }

            // View reservation bill
            function viewReservation(id) {
                openModal('billModal');
                // Load reservation details
            }

            // Cancel reservation
            function cancelReservation(id) {
                if (confirm('Are you sure you want to cancel this reservation?')) {
                    alert('Reservation cancelled successfully!');
                    // Implement cancellation logic
                }
            }

            // Logout
            function logout() {
                if (confirm('Are you sure you want to logout?')) {
                    window.location.href = 'LogoutServlet';
                }
            }
        </script>
    </body>
</html>