package DAO;

import MODELS.Room;
import UTILS.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * RoomDAO - Data Access Object for Room CRUD operations
 * @author Ashen Samarasekera
 */
public class RoomDAO {

    // ─────────────────────────────────────────────
    // CREATE
    // ─────────────────────────────────────────────

    /**
     * Add a new room to the database
     * @param room Room object to insert
     * @return true if inserted successfully
     */
    public boolean addRoom(Room room) {
        String sql = "INSERT INTO rooms (room_number, room_type, price_per_night, availability, description) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, room.getRoomNumber());
            ps.setString(2, room.getRoomType());
            ps.setBigDecimal(3, room.getPricePerNight());
            ps.setString(4, room.getAvailability());
            ps.setString(5, room.getDescription());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("Error adding room: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // ─────────────────────────────────────────────
    // READ - Get All Rooms
    // ─────────────────────────────────────────────

    /**
     * Retrieve all rooms from the database
     * @return List of all Room objects
     */
    public List<Room> getAllRooms() {
        List<Room> rooms = new ArrayList<>();
        String sql = "SELECT * FROM rooms ORDER BY room_id ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                rooms.add(mapResultSetToRoom(rs));
            }

        } catch (SQLException e) {
            System.err.println("Error fetching all rooms: " + e.getMessage());
            e.printStackTrace();
        }
        return rooms;
    }

    // ─────────────────────────────────────────────
    // READ - Get All Available Rooms (for Guest)
    // ─────────────────────────────────────────────

    /**
     * Retrieve only available rooms (for Guest dashboard)
     * @return List of available Room objects
     */
    public List<Room> getAvailableRooms() {
        List<Room> rooms = new ArrayList<>();
        String sql = "SELECT * FROM rooms WHERE availability = 'Available' ORDER BY room_type ASC, room_number ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                rooms.add(mapResultSetToRoom(rs));
            }

        } catch (SQLException e) {
            System.err.println("Error fetching available rooms: " + e.getMessage());
            e.printStackTrace();
        }
        return rooms;
    }

    // ─────────────────────────────────────────────
    // READ - Get Room By ID
    // ─────────────────────────────────────────────

    /**
     * Retrieve a single room by its ID
     * @param roomId the ID to look up
     * @return Room object or null if not found
     */
    public Room getRoomById(int roomId) {
        String sql = "SELECT * FROM rooms WHERE room_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToRoom(rs);
                }
            }

        } catch (SQLException e) {
            System.err.println("Error fetching room by ID: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    // ─────────────────────────────────────────────
    // READ - Get Rooms By Type (optional filter)
    // ─────────────────────────────────────────────

    /**
     * Retrieve available rooms filtered by type
     * @param roomType e.g. "Standard", "Deluxe", "Luxury", "Suite"
     * @return filtered list of Room objects
     */
    public List<Room> getAvailableRoomsByType(String roomType) {
        List<Room> rooms = new ArrayList<>();
        String sql = "SELECT * FROM rooms WHERE availability = 'Available' AND room_type = ? ORDER BY room_number ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, roomType);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    rooms.add(mapResultSetToRoom(rs));
                }
            }

        } catch (SQLException e) {
            System.err.println("Error fetching rooms by type: " + e.getMessage());
            e.printStackTrace();
        }
        return rooms;
    }

    // ─────────────────────────────────────────────
    // UPDATE
    // ─────────────────────────────────────────────

    /**
     * Update an existing room record
     * @param room Room object with updated data (must have roomId set)
     * @return true if updated successfully
     */
    public boolean updateRoom(Room room) {
        String sql = "UPDATE rooms SET room_number = ?, room_type = ?, price_per_night = ?, availability = ?, description = ? WHERE room_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, room.getRoomNumber());
            ps.setString(2, room.getRoomType());
            ps.setBigDecimal(3, room.getPricePerNight());
            ps.setString(4, room.getAvailability());
            ps.setString(5, room.getDescription());
            ps.setInt(6, room.getRoomId());

            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("Error updating room: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Update only the availability status of a room
     * @param roomId   the room to update
     * @param status   "Available", "Occupied", or "Maintenance"
     * @return true if updated successfully
     */
    public boolean updateRoomAvailability(int roomId, String status) {
        String sql = "UPDATE rooms SET availability = ? WHERE room_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setInt(2, roomId);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("Error updating room availability: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // ─────────────────────────────────────────────
    // DELETE
    // ─────────────────────────────────────────────

    /**
     * Delete a room by its ID
     * @param roomId the room to delete
     * @return true if deleted successfully
     */
    public boolean deleteRoom(int roomId) {
        String sql = "DELETE FROM rooms WHERE room_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, roomId);
            return ps.executeUpdate() > 0;

        } catch (SQLException e) {
            System.err.println("Error deleting room: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    // ─────────────────────────────────────────────
    // HELPER
    // ─────────────────────────────────────────────

    /**
     * Map a ResultSet row to a Room object
     */
    private Room mapResultSetToRoom(ResultSet rs) throws SQLException {
        Room room = new Room();
        room.setRoomId(rs.getInt("room_id"));
        room.setRoomNumber(rs.getString("room_number"));
        room.setRoomType(rs.getString("room_type"));
        room.setPricePerNight(rs.getBigDecimal("price_per_night"));
        room.setAvailability(rs.getString("availability"));
        room.setDescription(rs.getString("description"));
        room.setCreatedAt(rs.getTimestamp("created_at"));
        return room;
    }
}