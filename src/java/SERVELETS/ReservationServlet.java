package SERVELETS;

import MODELS.Reservation;
import MODELS.Room;
import MODELS.User;
import SERVICES.ReservationService;
import SERVICES.RoomService;
import SERVICES.UserService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet(name = "ReservationServlet", urlPatterns = {"/ReservationServlet"})
public class ReservationServlet extends HttpServlet {

    private final ReservationService reservationService = new ReservationService();
    private final RoomService        roomService        = new RoomService();
    private final UserService        userService        = new UserService();

    // ── GET ───────────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/PAGES/login.jsp");
            return;
        }

        String role   = (String) session.getAttribute("role");
        String action = request.getParameter("action");

        if ("ADMIN".equalsIgnoreCase(role)) {
            if ("viewUser".equalsIgnoreCase(action)) {
                handleViewUser(request, response);
            } else {
                handleAdminGet(request, response);
            }
        } else {
            handleGuestGet(request, response);
        }
    }

    // ── POST ──────────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/PAGES/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String role   = (String) session.getAttribute("role");

        switch (action == null ? "" : action) {
            case "book":   handleBook(request, response, session);         break;
            case "cancel": handleCancel(request, response, session, role); break;
            case "add":    handleAdminAdd(request, response, session);     break;
            case "edit":   handleAdminEdit(request, response, session);    break;
            case "delete": handleAdminDelete(request, response, session);  break;
            default:
                response.sendRedirect(request.getContextPath() + "/PAGES/login.jsp");
        }
    }

    // ── Guest GET ─────────────────────────────────────────────────────────────
    private void handleGuestGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/PAGES/login.jsp");
            return;
        }
        request.setAttribute("rooms",          roomService.getAllRooms());
        request.setAttribute("myReservations", reservationService.getReservationsByUserId(userId));
        request.getRequestDispatcher("/PAGES/customer-dashboard.jsp").forward(request, response);
    }

    // ── Admin GET ─────────────────────────────────────────────────────────────
    private void handleAdminGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("reservations",      reservationService.getAllReservations());
        request.setAttribute("rooms",             roomService.getAllRooms());
        request.setAttribute("guests",            userService.getAllGuests());
        request.setAttribute("totalReservations", reservationService.getTotalReservationCount());
        request.setAttribute("totalGuests",       reservationService.getTotalGuestCount());
        request.setAttribute("activeTab",         "reservations");
        request.getRequestDispatcher("/PAGES/admin-dashboard.jsp").forward(request, response);
    }

    // ── Admin: view a specific user's reservations ────────────────────────────
    private void handleViewUser(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int targetUserId = Integer.parseInt(request.getParameter("userId"));
            request.setAttribute("reservations",      reservationService.getAllReservations());
            request.setAttribute("rooms",             roomService.getAllRooms());
            request.setAttribute("guests",            userService.getAllGuests());
            request.setAttribute("totalReservations", reservationService.getTotalReservationCount());
            request.setAttribute("totalGuests",       reservationService.getTotalGuestCount());
            request.setAttribute("activeTab",         "reservations");
            request.setAttribute("viewUser",          userService.getUserById(targetUserId));
            request.setAttribute("userReservations",  reservationService.getReservationsByUserId(targetUserId));
            request.getRequestDispatcher("/PAGES/admin-dashboard.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/ReservationServlet");
        }
    }

    // ── Guest: book ───────────────────────────────────────────────────────────
    private void handleBook(HttpServletRequest request, HttpServletResponse response,
                            HttpSession session) throws IOException {
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/PAGES/login.jsp");
            return;
        }
        try {
            int        roomId   = Integer.parseInt(request.getParameter("roomId"));
            String     checkIn  = request.getParameter("checkIn");
            String     checkOut = request.getParameter("checkOut");
            BigDecimal price    = new BigDecimal(request.getParameter("pricePerNight"));

            boolean success = reservationService.createReservation(userId, roomId, checkIn, checkOut, price);
            session.setAttribute("msgType", success ? "success" : "error");
            session.setAttribute("msgText", success
                ? "Booking confirmed! Your reservation has been created."
                : "Booking failed. Please check your dates and try again.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("msgType", "error");
            session.setAttribute("msgText", "Booking failed: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/ReservationServlet");
    }

    // ── Cancel ────────────────────────────────────────────────────────────────
    private void handleCancel(HttpServletRequest request, HttpServletResponse response,
                              HttpSession session, String role) throws IOException {
        try {
            int     reservationId = Integer.parseInt(request.getParameter("reservationId"));
            boolean success       = reservationService.cancelReservation(reservationId);
            session.setAttribute("msgType", success ? "success" : "error");
            session.setAttribute("msgText", success
                ? "Reservation #" + reservationId + " has been cancelled."
                : "Cancellation failed.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("msgType", "error");
            session.setAttribute("msgText", "Error during cancellation: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/ReservationServlet");
    }

    // ── Admin: add reservation ────────────────────────────────────────────────
    private void handleAdminAdd(HttpServletRequest request, HttpServletResponse response,
                                HttpSession session) throws IOException {

        // ── Log ALL incoming parameters for debugging ─────────────────────────
        System.out.println("=== handleAdminAdd PARAMS ===");
        System.out.println("userId       = " + request.getParameter("userId"));
        System.out.println("roomId       = " + request.getParameter("roomId"));
        System.out.println("checkIn      = " + request.getParameter("checkIn"));
        System.out.println("checkOut     = " + request.getParameter("checkOut"));
        System.out.println("pricePerNight= " + request.getParameter("pricePerNight"));
        System.out.println("paymentStatus= " + request.getParameter("paymentStatus"));
        System.out.println("=============================");

        try {
            String userIdStr = request.getParameter("userId");
            String roomIdStr = request.getParameter("roomId");
            String checkIn   = request.getParameter("checkIn");
            String checkOut  = request.getParameter("checkOut");
            String priceStr  = request.getParameter("pricePerNight");
            String status    = request.getParameter("paymentStatus");

            // ── Validate ──────────────────────────────────────────────────────
            if (isBlank(userIdStr))
                throw new IllegalArgumentException("No guest selected. Please select a guest from the dropdown.");
            if (isBlank(roomIdStr))
                throw new IllegalArgumentException("No room selected. Please select a room.");
            if (isBlank(checkIn))
                throw new IllegalArgumentException("Check-in date is required.");
            if (isBlank(checkOut))
                throw new IllegalArgumentException("Check-out date is required.");

            int userId = Integer.parseInt(userIdStr.trim());
            int roomId = Integer.parseInt(roomIdStr.trim());

            if (userId <= 0)
                throw new IllegalArgumentException("Invalid guest ID: " + userId);
            if (roomId <= 0)
                throw new IllegalArgumentException("Invalid room ID: " + roomId);

            // ── Verify user exists ────────────────────────────────────────────
            User user = userService.getUserById(userId);
            if (user == null)
                throw new IllegalArgumentException("Guest with ID " + userId + " not found in database.");

            // ── Verify room exists and get price ──────────────────────────────
            Room room = roomService.getRoomById(roomId);
            if (room == null)
                throw new IllegalArgumentException("Room with ID " + roomId + " not found in database.");

            // ── Resolve price: use form value if valid, else use room's price ──
            BigDecimal price = BigDecimal.ZERO;
            if (!isBlank(priceStr) && !priceStr.trim().equals("0")) {
                try { price = new BigDecimal(priceStr.trim()); } catch (NumberFormatException ignored) {}
            }
            if (price.compareTo(BigDecimal.ZERO) <= 0) {
                price = room.getPricePerNight();
            }

            System.out.println("Resolved → userId=" + userId + " roomId=" + roomId
                + " checkIn=" + checkIn + " checkOut=" + checkOut + " price=" + price);

            // ── Create reservation ────────────────────────────────────────────
            boolean success = reservationService.createReservation(userId, roomId, checkIn, checkOut, price);

            System.out.println("createReservation returned: " + success);

            if (success && "Paid".equalsIgnoreCase(status)) {
                List<Reservation> all = reservationService.getAllReservations();
                if (!all.isEmpty()) {
                    int newId = all.get(0).getReservationId();
                    reservationService.updateReservation(newId, roomId, checkIn, checkOut, price, "Paid");
                }
            }

            session.setAttribute("msgType", success ? "success" : "error");
            session.setAttribute("msgText", success
                ? "Reservation added successfully for " + user.getUsername() + "."
                : "DB INSERT failed. Check Tomcat/GlassFish logs for the exact SQL error (look for SQLException).");

        } catch (IllegalArgumentException e) {
            session.setAttribute("msgType", "error");
            session.setAttribute("msgText", "Validation error: " + e.getMessage());
        
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("msgType", "error");
            session.setAttribute("msgText", "Server error: " + e.getClass().getSimpleName() + " – " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/ReservationServlet");
    }

    // ── Admin: edit reservation ───────────────────────────────────────────────
    private void handleAdminEdit(HttpServletRequest request, HttpServletResponse response,
                                 HttpSession session) throws IOException {
        try {
            int        reservationId = Integer.parseInt(request.getParameter("reservationId"));
            int        roomId        = Integer.parseInt(request.getParameter("roomId"));
            String     checkIn       = request.getParameter("checkIn");
            String     checkOut      = request.getParameter("checkOut");
            String     priceStr      = request.getParameter("pricePerNight");
            String     status        = request.getParameter("paymentStatus");

            BigDecimal price = BigDecimal.ZERO;
            if (!isBlank(priceStr) && !priceStr.trim().equals("0")) {
                try { price = new BigDecimal(priceStr.trim()); } catch (NumberFormatException ignored) {}
            }
            if (price.compareTo(BigDecimal.ZERO) <= 0) {
                Room room = roomService.getRoomById(roomId);
                if (room != null) price = room.getPricePerNight();
            }

            boolean success = reservationService.updateReservation(reservationId, roomId, checkIn, checkOut, price, status);
            session.setAttribute("msgType", success ? "success" : "error");
            session.setAttribute("msgText", success ? "Reservation updated successfully." : "Update failed.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("msgType", "error");
            session.setAttribute("msgText", "Error: " + e.getClass().getSimpleName() + " – " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/ReservationServlet");
    }

    // ── Admin: delete reservation ─────────────────────────────────────────────
    private void handleAdminDelete(HttpServletRequest request, HttpServletResponse response,
                                   HttpSession session) throws IOException {
        try {
            int     reservationId = Integer.parseInt(request.getParameter("reservationId"));
            boolean success       = reservationService.deleteReservation(reservationId);
            session.setAttribute("msgType", success ? "success" : "error");
            session.setAttribute("msgText", success ? "Reservation deleted." : "Delete failed.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("msgType", "error");
            session.setAttribute("msgText", "Error: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/ReservationServlet");
    }

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }
}