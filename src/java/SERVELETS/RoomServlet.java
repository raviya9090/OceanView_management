package SERVELETS;

import MODELS.Room;
import SERVICES.RoomService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * RoomServlet - Handles all Room CRUD operations for Admin and Guest
 *
 * URL Patterns:
 *  GET  /RoomServlet?action=getAll           - All rooms (Admin)
 *  GET  /RoomServlet?action=getAvailable     - Available rooms (Guest)
 *  GET  /RoomServlet?action=getById&id=1     - Single room by ID (JSON, no external library)
 *  POST /RoomServlet?action=add              - Add new room (Admin)
 *  POST /RoomServlet?action=edit             - Edit room (Admin)
 *  POST /RoomServlet?action=delete           - Delete room (Admin)
 *
 * @author Ashen Samarasekera
 */
@WebServlet(name = "RoomServlet", urlPatterns = {"/RoomServlet"})
public class RoomServlet extends HttpServlet {

    private RoomService roomService;

    @Override
    public void init() throws ServletException {
        super.init();
        roomService = new RoomService();
    }

    // ─────────────────────────────────────────────
    // GET - Read operations
    // ─────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) action = "";

        switch (action) {

            // Admin: get all rooms, forward to admin dashboard
            case "getAll":
                if (!isAdmin(request, response)) return;
                List<Room> allRooms = roomService.getAllRooms();
                request.setAttribute("rooms", allRooms);
                request.setAttribute("activeTab", "rooms");
                request.getRequestDispatcher("/PAGES/admin-dashboard.jsp").forward(request, response);
                break;

            // Guest: get only available rooms, forward to guest dashboard
            case "getAvailable":
                List<Room> availableRooms = roomService.getAvailableRooms();
                request.setAttribute("rooms", availableRooms);
                request.getRequestDispatcher("/PAGES/customer-dashboard.jsp").forward(request, response);
                break;

            // Get single room by ID - returns plain JSON, no external library needed
            case "getById":
                if (!isAdmin(request, response)) return;
                String idParam = request.getParameter("id");
                if (isNullOrEmpty(idParam)) {
                    sendJsonResponse(response, false, "Missing room ID", null);
                    return;
                }
                Room room = roomService.getRoomById(idParam);
                if (room != null) {
                    sendJsonResponse(response, true, "Room found", room);
                } else {
                    sendJsonResponse(response, false, "Room not found", null);
                }
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/admin-dashboard.jsp");
                break;
        }
    }

    // ─────────────────────────────────────────────
    // POST - Write operations (Add / Edit / Delete)
    // ─────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request, response)) return;

        String action = request.getParameter("action");
        if (action == null) action = "";

        switch (action) {
            case "add":
                handleAddRoom(request, response);
                break;
            case "edit":
                handleEditRoom(request, response);
                break;
            case "delete":
                handleDeleteRoom(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/RoomServlet?action=getAll");
                break;
        }
    }

    // ─────────────────────────────────────────────
    // HANDLERS
    // ─────────────────────────────────────────────

    private void handleAddRoom(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        String roomNumber    = request.getParameter("roomNumber");
        String roomType      = request.getParameter("roomType");
        String pricePerNight = request.getParameter("pricePerNight");
        String availability  = request.getParameter("availability");
        String description   = request.getParameter("description");

        if (isNullOrEmpty(roomNumber) || isNullOrEmpty(roomType) || isNullOrEmpty(pricePerNight)) {
            setSessionMessage(request, "error", "All required fields must be filled.");
            response.sendRedirect(request.getContextPath() + "/RoomServlet?action=getAll");
            return;
        }

        boolean success = roomService.addRoom(roomNumber, roomType, pricePerNight, availability, description);

        setSessionMessage(request,
                success ? "success" : "error",
                success ? "Room added successfully!" : "Failed to add room. Please try again.");
        response.sendRedirect(request.getContextPath() + "/RoomServlet?action=getAll");
    }

    private void handleEditRoom(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        String roomId        = request.getParameter("roomId");
        String roomNumber    = request.getParameter("roomNumber");
        String roomType      = request.getParameter("roomType");
        String pricePerNight = request.getParameter("pricePerNight");
        String availability  = request.getParameter("availability");
        String description   = request.getParameter("description");

        if (isNullOrEmpty(roomId) || isNullOrEmpty(roomNumber) || isNullOrEmpty(roomType) || isNullOrEmpty(pricePerNight)) {
            setSessionMessage(request, "error", "All required fields must be filled.");
            response.sendRedirect(request.getContextPath() + "/RoomServlet?action=getAll");
            return;
        }

        boolean success = roomService.updateRoom(roomId, roomNumber, roomType, pricePerNight, availability, description);

        setSessionMessage(request,
                success ? "success" : "error",
                success ? "Room updated successfully!" : "Failed to update room. Please try again.");
        response.sendRedirect(request.getContextPath() + "/RoomServlet?action=getAll");
    }

    private void handleDeleteRoom(HttpServletRequest request, HttpServletResponse response)
            throws IOException, ServletException {

        String roomId = request.getParameter("roomId");

        if (isNullOrEmpty(roomId)) {
            setSessionMessage(request, "error", "Room ID is required for deletion.");
            response.sendRedirect(request.getContextPath() + "/RoomServlet?action=getAll");
            return;
        }

        boolean success = roomService.deleteRoom(roomId);

        setSessionMessage(request,
                success ? "success" : "error",
                success ? "Room deleted successfully!" : "Failed to delete room. It may have existing reservations.");
        response.sendRedirect(request.getContextPath() + "/RoomServlet?action=getAll");
    }

    // ─────────────────────────────────────────────
    // UTILITY METHODS
    // ─────────────────────────────────────────────

    /**
     * Check if the current session belongs to an Admin.
     * Redirects to login if not.
     */
    private boolean isAdmin(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null
                || session.getAttribute("role") == null
                || !session.getAttribute("role").toString().equalsIgnoreCase("ADMIN")) {
            response.sendRedirect(request.getContextPath() + "/PAGES/login.jsp");
            return false;
        }
        return true;
    }

    /**
     * Build and write a JSON response manually.
     * No Gson or Jackson - uses only java.io.PrintWriter and StringBuilder.
     *
     * Response format:
     * {
     *   "success": true/false,
     *   "message": "...",
     *   "data": { room fields... }   // only when room != null
     * }
     */
    private void sendJsonResponse(HttpServletResponse response, boolean success,
                                  String message, Room room) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        StringBuilder json = new StringBuilder();
        json.append("{");
        json.append("\"success\":").append(success).append(",");
        json.append("\"message\":\"").append(escapeJson(message)).append("\"");

        if (room != null) {
            json.append(",\"data\":{");
            json.append("\"roomId\":").append(room.getRoomId()).append(",");
            json.append("\"roomNumber\":\"").append(escapeJson(room.getRoomNumber())).append("\",");
            json.append("\"roomType\":\"").append(escapeJson(room.getRoomType())).append("\",");
            json.append("\"pricePerNight\":").append(room.getPricePerNight()).append(",");
            json.append("\"availability\":\"").append(escapeJson(room.getAvailability())).append("\",");
            json.append("\"description\":\"").append(
                    escapeJson(room.getDescription() != null ? room.getDescription() : "")).append("\"");
            json.append("}");
        }

        json.append("}");
        out.print(json.toString());
        out.flush();
    }

    /**
     * Escape special characters so strings are safe inside JSON values.
     */
    private String escapeJson(String value) {
        if (value == null) return "";
        return value.replace("\\", "\\\\")
                    .replace("\"", "\\\"")
                    .replace("\n", "\\n")
                    .replace("\r", "\\r")
                    .replace("\t", "\\t");
    }

    /**
     * Store a flash message in the session so it survives the redirect.
     */
    private void setSessionMessage(HttpServletRequest request, String type, String message) {
        request.getSession().setAttribute("msgType", type);
        request.getSession().setAttribute("msgText", message);
    }

    private boolean isNullOrEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }
}