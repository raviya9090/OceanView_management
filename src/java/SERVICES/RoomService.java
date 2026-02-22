package SERVICES;

import DAO.RoomDAO;
import MODELS.Room;

import java.math.BigDecimal;
import java.util.List;

/**
 * RoomService - Business logic layer for Room operations
 * @author Ashen Samarasekera
 */
public class RoomService {

    private final RoomDAO roomDAO;

    public RoomService() {
        this.roomDAO = new RoomDAO();
    }

    // ─────────────────────────────────────────────
    // CREATE
    // ─────────────────────────────────────────────

    /**
     * Add a new room after validating inputs
     * @return true if added successfully, false otherwise
     */
    public boolean addRoom(String roomNumber, String roomType, String priceStr,
                           String availability, String description) {

        if (roomNumber == null || roomNumber.trim().isEmpty()) return false;
        if (roomType == null || roomType.trim().isEmpty()) return false;
        if (priceStr == null || priceStr.trim().isEmpty()) return false;

        try {
            BigDecimal price = new BigDecimal(priceStr.trim());
            if (price.compareTo(BigDecimal.ZERO) <= 0) return false;

            Room room = new Room();
            room.setRoomNumber(roomNumber.trim());
            room.setRoomType(roomType.trim());
            room.setPricePerNight(price);
            room.setAvailability(availability != null ? availability.trim() : "Available");
            room.setDescription(description != null ? description.trim() : "");

            return roomDAO.addRoom(room);

        } catch (NumberFormatException e) {
            System.err.println("Invalid price format: " + priceStr);
            return false;
        }
    }

    // ─────────────────────────────────────────────
    // READ - Get All
    // ─────────────────────────────────────────────

    /**
     * Get all rooms (Admin use)
     */
    public List<Room> getAllRooms() {
        return roomDAO.getAllRooms();
    }

    // ─────────────────────────────────────────────
    // READ - Get Available (Guest use)
    // ─────────────────────────────────────────────

    /**
     * Get only available rooms (Guest dashboard)
     */
    public List<Room> getAvailableRooms() {
        return roomDAO.getAvailableRooms();
    }

    /**
     * Get available rooms filtered by type (Guest filter)
     */
    public List<Room> getAvailableRoomsByType(String roomType) {
        if (roomType == null || roomType.trim().isEmpty() || roomType.equals("All Types")) {
            return roomDAO.getAvailableRooms();
        }
        return roomDAO.getAvailableRoomsByType(roomType.trim());
    }

    // ─────────────────────────────────────────────
    // READ - Get By ID
    // ─────────────────────────────────────────────

    /**
     * Get a room by its ID
     */
    public Room getRoomById(int roomId) {
        return roomDAO.getRoomById(roomId);
    }

    /**
     * Get a room by its ID from a String (handles parse errors)
     */
    public Room getRoomById(String roomIdStr) {
        try {
            int roomId = Integer.parseInt(roomIdStr.trim());
            return roomDAO.getRoomById(roomId);
        } catch (NumberFormatException e) {
            System.err.println("Invalid roomId: " + roomIdStr);
            return null;
        }
    }

    // ─────────────────────────────────────────────
    // UPDATE
    // ─────────────────────────────────────────────

    /**
     * Update room details after validating inputs
     */
    public boolean updateRoom(String roomIdStr, String roomNumber, String roomType,
                              String priceStr, String availability, String description) {
        try {
            int roomId = Integer.parseInt(roomIdStr.trim());
            BigDecimal price = new BigDecimal(priceStr.trim());
            if (price.compareTo(BigDecimal.ZERO) <= 0) return false;

            Room room = new Room();
            room.setRoomId(roomId);
            room.setRoomNumber(roomNumber.trim());
            room.setRoomType(roomType.trim());
            room.setPricePerNight(price);
            room.setAvailability(availability.trim());
            room.setDescription(description != null ? description.trim() : "");

            return roomDAO.updateRoom(room);

        } catch (NumberFormatException e) {
            System.err.println("Invalid input for updateRoom: " + e.getMessage());
            return false;
        }
    }

    /**
     * Update only the availability status of a room
     */
    public boolean updateRoomAvailability(int roomId, String status) {
        return roomDAO.updateRoomAvailability(roomId, status);
    }

    // ─────────────────────────────────────────────
    // DELETE
    // ─────────────────────────────────────────────

    /**
     * Delete a room by ID
     */
    public boolean deleteRoom(int roomId) {
        return roomDAO.deleteRoom(roomId);
    }

    /**
     * Delete a room by ID from a String (handles parse errors)
     */
    public boolean deleteRoom(String roomIdStr) {
        try {
            int roomId = Integer.parseInt(roomIdStr.trim());
            return roomDAO.deleteRoom(roomId);
        } catch (NumberFormatException e) {
            System.err.println("Invalid roomId for delete: " + roomIdStr);
            return false;
        }
    }
}