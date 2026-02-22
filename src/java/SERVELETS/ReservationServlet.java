package SERVELETS;

import MODELS.Reservation;
import MODELS.Room;
import SERVICES.ReservationService;
import SERVICES.RoomService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * ReservationServlet - Handles all Reservation operations
 *
 * URL Patterns:
 *  GET  /ReservationServlet?action=getAll        → All reservations (Admin)
 *  GET  /ReservationServlet?action=getMyBookings → Logged-in user's reservations (Guest)
 *  POST /ReservationServlet?action=add           → Guest books a room
 *  POST /ReservationServlet?action=edit          → Admin edits reservation
 *  POST /ReservationServlet?action=delete        → Admin deletes reservation
 *  POST /ReservationServlet?action=cancel        → Guest cancels own pending reservation
 *
 * @author Ashen Samarasekera
 */
@WebServlet(name = "ReservationServlet", urlPatterns = {"/ReservationServlet"})
public class ReservationServlet extends HttpServlet {

    private ReservationService reservationService;
    private RoomService roomService;

    @Override
    public void init() throws ServletException {
        super.init();
        reservationService = new ReservationService();
        roomService        = new RoomService();
    }

    // ─────────────────────────────────────────────
    // GET
    // ─────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "";

        switch (action) {

            // Admin: all reservations → admin-dashboard.jsp on reservations tab
            case "getAll":
                if (!isAdmin(request, response)) return;
                List<Reservation> all = reservationService.getAllReservations();
                List<Room> allRooms   = roomService.getAllRooms();
                request.setAttribute("reservations", all);
                request.setAttribute("rooms", allRooms);
                request.setAttribute("activeTab", "reservations");
                request.getRequestDispatcher("/admin-dashboard.jsp").forward(request, response);
                break;

            // Guest: own reservations → customer-dashboard.jsp, opens My Reservations tab
            case "getMyBookings":
                if (!isLoggedIn(request, response)) return;
                int userId = (Integer) request.getSession().getAttribute("userId");
                List<Reservation> mine = reservationService.getReservationsByUserId(userId);
                List<Room> guestRooms  = roomService.getAllRooms();
                request.setAttribute("reservations", mine);
                request.setAttribute("rooms", guestRooms);
                request.setAttribute("activeTab", "my-reservations");
                request.getRequestDispatcher("/customer-dashboard.jsp").forward(request, response);
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/customer-dashboard.jsp");
                break;
        }
    }

    // ─────────────────────────────────────────────
    // POST
    // ─────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "";

        switch (action) {

            case "add":
                if (!isLoggedIn(request, response)) return;
                handleAdd(request, response);
                break;

            case "edit":
                if (!isAdmin(request, response)) return;
                handleEdit(request, response);
                break;

            case "delete":
                if (!isAdmin(request, response)) return;
                handleDelete(request, response);
                break;

            case "cancel":
                if (!isLoggedIn(request, response)) return;
                handleCancel(request, response);
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/customer-dashboard.jsp");
                break;
        }
    }

    // ─────────────────────────────────────────────
    // HANDLERS
    // ─────────────────────────────────────────────

    /** Guest books a room */
    private void handleAdd(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        String userIdStr = String.valueOf(session.getAttribute("userId"));
        String roomId    = request.getParameter("roomId");
        String checkIn   = request.getParameter("checkIn");
        String checkOut  = request.getParameter("checkOut");

        if (isNullOrEmpty(roomId) || isNullOrEmpty(checkIn) || isNullOrEmpty(checkOut)) {
            setMsg(request, "error", "All booking fields are required.");
            response.sendRedirect(request.getContextPath() + "/customer-dashboard.jsp");
            return;
        }

        boolean ok = reservationService.addReservation(userIdStr, roomId, checkIn, checkOut);
        setMsg(request, ok ? "success" : "error",
               ok ? "Room booked successfully! Your reservation is pending confirmation."
                  : "Booking failed. The room may no longer be available. Please try another room.");
        response.sendRedirect(request.getContextPath() + "/customer-dashboard.jsp");
    }

    /** Admin edits a reservation */
    private void handleEdit(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String reservationId = request.getParameter("reservationId");
        String userId        = request.getParameter("userId");
        String roomId        = request.getParameter("roomId");
        String checkIn       = request.getParameter("checkIn");
        String checkOut      = request.getParameter("checkOut");
        String paymentStatus = request.getParameter("paymentStatus");

        if (isNullOrEmpty(reservationId) || isNullOrEmpty(userId) || isNullOrEmpty(roomId)
                || isNullOrEmpty(checkIn) || isNullOrEmpty(checkOut)) {
            setMsg(request, "error", "All fields are required to update a reservation.");
            response.sendRedirect(request.getContextPath() + "/ReservationServlet?action=getAll");
            return;
        }

        boolean ok = reservationService.updateReservation(
                reservationId, userId, roomId, checkIn, checkOut, paymentStatus);
        setMsg(request, ok ? "success" : "error",
               ok ? "Reservation updated successfully!" : "Failed to update reservation.");
        response.sendRedirect(request.getContextPath() + "/ReservationServlet?action=getAll");
    }

    /** Admin deletes a reservation */
    private void handleDelete(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String reservationId = request.getParameter("reservationId");
        if (isNullOrEmpty(reservationId)) {
            setMsg(request, "error", "Reservation ID is required.");
            response.sendRedirect(request.getContextPath() + "/ReservationServlet?action=getAll");
            return;
        }
        boolean ok = reservationService.deleteReservation(reservationId);
        setMsg(request, ok ? "success" : "error",
               ok ? "Reservation deleted successfully!" : "Failed to delete reservation.");
        response.sendRedirect(request.getContextPath() + "/ReservationServlet?action=getAll");
    }

    /** Guest cancels own pending reservation */
    private void handleCancel(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session  = request.getSession(false);
        String userIdStr     = String.valueOf(session.getAttribute("userId"));
        String reservationId = request.getParameter("reservationId");

        if (isNullOrEmpty(reservationId)) {
            setMsg(request, "error", "Reservation ID is required.");
            response.sendRedirect(request.getContextPath() + "/customer-dashboard.jsp");
            return;
        }

        boolean ok = reservationService.cancelReservation(reservationId, userIdStr);
        setMsg(request, ok ? "success" : "error",
               ok ? "Reservation cancelled successfully. The room is now available again."
                  : "Cancellation failed. Only pending reservations can be cancelled.");
        response.sendRedirect(request.getContextPath() + "/customer-dashboard.jsp");
    }

    // ─────────────────────────────────────────────
    // UTILITY
    // ─────────────────────────────────────────────

    private boolean isAdmin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("role") == null
                || !session.getAttribute("role").toString().equalsIgnoreCase("ADMIN")) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return false;
        }
        return true;
    }

    private boolean isLoggedIn(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return false;
        }
        return true;
    }

    private void setMsg(HttpServletRequest request, String type, String text) {
        request.getSession().setAttribute("msgType", type);
        request.getSession().setAttribute("msgText", text);
    }

    private boolean isNullOrEmpty(String val) {
        return val == null || val.trim().isEmpty();
    }
}