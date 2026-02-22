package SERVELETS;

import MODELS.Reservation;
import MODELS.Room;
import SERVICES.ReservationService;
import SERVICES.RoomService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet(name = "ReservationServlet", urlPatterns = {"/ReservationServlet"})
public class ReservationServlet extends HttpServlet {

    private final ReservationService reservationService = new ReservationService();
    private final RoomService roomService = new RoomService();

    // ── GET: load dashboards with reservation data ────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/PAGES/login.jsp");
            return;
        }

        String role = (String) session.getAttribute("role");
        String action = request.getParameter("action");

        if ("ADMIN".equalsIgnoreCase(role)) {
            handleAdminGet(request, response, action);
        } else {
            handleGuestGet(request, response, action);
        }
    }

    // ── POST: create / update / delete / cancel ───────────────────────────────
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
            case "book":
                handleBook(request, response, session);
                break;
            case "cancel":
                handleCancel(request, response, session, role);
                break;
            case "add":
                handleAdminAdd(request, response, session);
                break;
            case "edit":
                handleAdminEdit(request, response, session);
                break;
            case "delete":
                handleAdminDelete(request, response, session);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/PAGES/login.jsp");
        }
    }

    // ── Guest: load rooms + their reservations ────────────────────────────────
    private void handleGuestGet(HttpServletRequest request, HttpServletResponse response,
                                String action) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/PAGES/login.jsp");
            return;
        }
        List<Room> rooms = roomService.getAllRooms();
        List<Reservation> myReservations = reservationService.getReservationsByUserId(userId);
        request.setAttribute("rooms", rooms);
        request.setAttribute("myReservations", myReservations);
        request.getRequestDispatcher("/PAGES/customer-dashboard.jsp").forward(request, response);
    }

    // ── Admin: load all reservations + rooms ──────────────────────────────────
    private void handleAdminGet(HttpServletRequest request, HttpServletResponse response,
                                String action) throws ServletException, IOException {
        List<Reservation> reservations = reservationService.getAllReservations();
        List<Room> rooms = roomService.getAllRooms();
        int totalReservations = reservationService.getTotalReservationCount();
        int totalGuests = reservationService.getTotalGuestCount();

        request.setAttribute("reservations", reservations);
        request.setAttribute("rooms", rooms);
        request.setAttribute("totalReservations", totalReservations);
        request.setAttribute("totalGuests", totalGuests);
        request.setAttribute("activeTab", "reservations");
        request.getRequestDispatcher("/PAGES/admin-dashboard.jsp").forward(request, response);
    }

    // ── Guest: book a room ────────────────────────────────────────────────────
    private void handleBook(HttpServletRequest request, HttpServletResponse response,
                            HttpSession session) throws IOException {
        Integer userId = (Integer) session.getAttribute("userId");
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/PAGES/login.jsp");
            return;
        }
        try {
            int roomId            = Integer.parseInt(request.getParameter("roomId"));
            String checkIn        = request.getParameter("checkIn");
            String checkOut       = request.getParameter("checkOut");
            BigDecimal price      = new BigDecimal(request.getParameter("pricePerNight"));

            boolean success = reservationService.createReservation(userId, roomId, checkIn, checkOut, price);
            if (success) {
                session.setAttribute("msgType", "success");
                session.setAttribute("msgText", "Booking confirmed! Your reservation has been created.");
            } else {
                session.setAttribute("msgType", "error");
                session.setAttribute("msgText", "Booking failed. Please check your dates and try again.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("msgType", "error");
            session.setAttribute("msgText", "Booking failed due to an error: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/ReservationServlet");
    }

    // ── Cancel (guest cancels own; admin can cancel any) ─────────────────────
    private void handleCancel(HttpServletRequest request, HttpServletResponse response,
                              HttpSession session, String role) throws IOException {
        try {
            int reservationId = Integer.parseInt(request.getParameter("reservationId"));
            boolean success   = reservationService.cancelReservation(reservationId);
            if (success) {
                session.setAttribute("msgType", "success");
                session.setAttribute("msgText", "Reservation #" + reservationId + " has been cancelled.");
            } else {
                session.setAttribute("msgType", "error");
                session.setAttribute("msgText", "Cancellation failed.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("msgType", "error");
            session.setAttribute("msgText", "Error during cancellation.");
        }

        if ("ADMIN".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/ReservationServlet?role=admin");
        } else {
            response.sendRedirect(request.getContextPath() + "/ReservationServlet");
        }
    }

    // ── Admin: add reservation manually ──────────────────────────────────────
    private void handleAdminAdd(HttpServletRequest request, HttpServletResponse response,
                                HttpSession session) throws IOException {
        try {
            int userId        = Integer.parseInt(request.getParameter("userId"));
            int roomId        = Integer.parseInt(request.getParameter("roomId"));
            String checkIn    = request.getParameter("checkIn");
            String checkOut   = request.getParameter("checkOut");
            BigDecimal price  = new BigDecimal(request.getParameter("pricePerNight"));
            String status     = request.getParameter("paymentStatus");

            boolean success = reservationService.createReservation(userId, roomId, checkIn, checkOut, price);
            // update status if Paid
            if (success && "Paid".equals(status)) {
                List<Reservation> all = reservationService.getAllReservations();
                if (!all.isEmpty()) {
                    int newId = all.get(0).getReservationId();
                    reservationService.updateReservation(newId, roomId, checkIn, checkOut, price, "Paid");
                }
            }
            session.setAttribute("msgType", success ? "success" : "error");
            session.setAttribute("msgText", success ? "Reservation added successfully." : "Failed to add reservation.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("msgType", "error");
            session.setAttribute("msgText", "Error: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/ReservationServlet");
    }

    // ── Admin: edit reservation ───────────────────────────────────────────────
    private void handleAdminEdit(HttpServletRequest request, HttpServletResponse response,
                                 HttpSession session) throws IOException {
        try {
            int reservationId = Integer.parseInt(request.getParameter("reservationId"));
            int roomId        = Integer.parseInt(request.getParameter("roomId"));
            String checkIn    = request.getParameter("checkIn");
            String checkOut   = request.getParameter("checkOut");
            BigDecimal price  = new BigDecimal(request.getParameter("pricePerNight"));
            String status     = request.getParameter("paymentStatus");

            boolean success = reservationService.updateReservation(reservationId, roomId, checkIn, checkOut, price, status);
            session.setAttribute("msgType", success ? "success" : "error");
            session.setAttribute("msgText", success ? "Reservation updated successfully." : "Update failed.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("msgType", "error");
            session.setAttribute("msgText", "Error: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/ReservationServlet");
    }

    // ── Admin: delete reservation ─────────────────────────────────────────────
    private void handleAdminDelete(HttpServletRequest request, HttpServletResponse response,
                                   HttpSession session) throws IOException {
        try {
            int reservationId = Integer.parseInt(request.getParameter("reservationId"));
            boolean success   = reservationService.deleteReservation(reservationId);
            session.setAttribute("msgType", success ? "success" : "error");
            session.setAttribute("msgText", success ? "Reservation deleted." : "Delete failed.");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("msgType", "error");
            session.setAttribute("msgText", "Error: " + e.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/ReservationServlet");
    }
}