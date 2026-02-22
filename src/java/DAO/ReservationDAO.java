package DAO;

import MODELS.Reservation;
import UTILS.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * ReservationDAO - Data Access Object for all Reservation DB operations
 * @author Ashen Samarasekera
 */
public class ReservationDAO {

    // ─────────────────────────────────────────────
    // CREATE
    // ─────────────────────────────────────────────

    public boolean addReservation(Reservation reservation) {
        String sql = "INSERT INTO reservations (user_id, room_id, check_in_date, check_out_date, "
                   + "number_of_nights, total_amount, payment_status) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reservation.getUserId());
            ps.setInt(2, reservation.getRoomId());
            ps.setDate(3, reservation.getCheckInDate());
            ps.setDate(4, reservation.getCheckOutDate());
            ps.setInt(5, reservation.getNumberOfNights());
            ps.setBigDecimal(6, reservation.getTotalAmount());
            ps.setString(7, reservation.getPaymentStatus());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("ReservationDAO.addReservation: " + e.getMessage());
            return false;
        }
    }

    // ─────────────────────────────────────────────
    // READ - All (Admin)
    // ─────────────────────────────────────────────

    public List<Reservation> getAllReservations() {
        List<Reservation> list = new ArrayList<>();
        String sql = "SELECT r.*, u.username, rm.room_number, rm.room_type "
                   + "FROM reservations r "
                   + "JOIN users u  ON r.user_id = u.user_id "
                   + "JOIN rooms rm ON r.room_id  = rm.room_id "
                   + "ORDER BY r.reservation_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(map(rs));
        } catch (SQLException e) {
            System.err.println("ReservationDAO.getAllReservations: " + e.getMessage());
        }
        return list;
    }

    // ─────────────────────────────────────────────
    // READ - By User (Guest - own bookings only)
    // ─────────────────────────────────────────────

    public List<Reservation> getReservationsByUserId(int userId) {
        List<Reservation> list = new ArrayList<>();
        String sql = "SELECT r.*, u.username, rm.room_number, rm.room_type "
                   + "FROM reservations r "
                   + "JOIN users u  ON r.user_id = u.user_id "
                   + "JOIN rooms rm ON r.room_id  = rm.room_id "
                   + "WHERE r.user_id = ? "
                   + "ORDER BY r.reservation_id DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(map(rs));
            }
        } catch (SQLException e) {
            System.err.println("ReservationDAO.getReservationsByUserId: " + e.getMessage());
        }
        return list;
    }

    // ─────────────────────────────────────────────
    // READ - By ID
    // ─────────────────────────────────────────────

    public Reservation getReservationById(int reservationId) {
        String sql = "SELECT r.*, u.username, rm.room_number, rm.room_type "
                   + "FROM reservations r "
                   + "JOIN users u  ON r.user_id = u.user_id "
                   + "JOIN rooms rm ON r.room_id  = rm.room_id "
                   + "WHERE r.reservation_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reservationId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
            }
        } catch (SQLException e) {
            System.err.println("ReservationDAO.getReservationById: " + e.getMessage());
        }
        return null;
    }

    // ─────────────────────────────────────────────
    // UPDATE - Full update (Admin)
    // ─────────────────────────────────────────────

    public boolean updateReservation(Reservation reservation) {
        String sql = "UPDATE reservations SET user_id=?, room_id=?, check_in_date=?, check_out_date=?, "
                   + "number_of_nights=?, total_amount=?, payment_status=? WHERE reservation_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reservation.getUserId());
            ps.setInt(2, reservation.getRoomId());
            ps.setDate(3, reservation.getCheckInDate());
            ps.setDate(4, reservation.getCheckOutDate());
            ps.setInt(5, reservation.getNumberOfNights());
            ps.setBigDecimal(6, reservation.getTotalAmount());
            ps.setString(7, reservation.getPaymentStatus());
            ps.setInt(8, reservation.getReservationId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("ReservationDAO.updateReservation: " + e.getMessage());
            return false;
        }
    }

    // ─────────────────────────────────────────────
    // UPDATE - Status only (Admin quick-update)
    // ─────────────────────────────────────────────

    public boolean updatePaymentStatus(int reservationId, String status) {
        String sql = "UPDATE reservations SET payment_status=? WHERE reservation_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, reservationId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("ReservationDAO.updatePaymentStatus: " + e.getMessage());
            return false;
        }
    }

    // ─────────────────────────────────────────────
    // DELETE (Admin)
    // ─────────────────────────────────────────────

    public boolean deleteReservation(int reservationId) {
        String sql = "DELETE FROM reservations WHERE reservation_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reservationId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("ReservationDAO.deleteReservation: " + e.getMessage());
            return false;
        }
    }

    // ─────────────────────────────────────────────
    // CANCEL - Guest cancels own PENDING reservation
    // ─────────────────────────────────────────────

    public boolean cancelReservation(int reservationId, int userId) {
        // Only allow cancel if it belongs to this user AND is still Pending
        String sql = "UPDATE reservations SET payment_status='Cancelled' "
                   + "WHERE reservation_id=? AND user_id=? AND payment_status='Pending'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reservationId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("ReservationDAO.cancelReservation: " + e.getMessage());
            return false;
        }
    }

    // ─────────────────────────────────────────────
    // MAPPER
    // ─────────────────────────────────────────────

    private Reservation map(ResultSet rs) throws SQLException {
        Reservation res = new Reservation();
        res.setReservationId(rs.getInt("reservation_id"));
        res.setUserId(rs.getInt("user_id"));
        res.setRoomId(rs.getInt("room_id"));
        res.setCheckInDate(rs.getDate("check_in_date"));
        res.setCheckOutDate(rs.getDate("check_out_date"));
        res.setNumberOfNights(rs.getInt("number_of_nights"));
        res.setTotalAmount(rs.getBigDecimal("total_amount"));
        res.setPaymentStatus(rs.getString("payment_status"));
        res.setCreatedAt(rs.getTimestamp("created_at"));
        res.setUsername(rs.getString("username"));
        res.setRoomNumber(rs.getString("room_number"));
        res.setRoomType(rs.getString("room_type"));
        return res;
    }
}