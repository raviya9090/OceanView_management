package DAO;

import MODELS.Reservation;
import UTILS.DBConnection;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReservationDAO {

    // ── Create ────────────────────────────────────────────────────────────────
    public boolean createReservation(Reservation r) {
        String sql = "INSERT INTO reservations (user_id, room_id, check_in_date, check_out_date, " +
                     "number_of_nights, total_amount, payment_status) VALUES (?,?,?,?,?,?,?)";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, r.getUserId());
            ps.setInt(2, r.getRoomId());
            ps.setDate(3, r.getCheckInDate());
            ps.setDate(4, r.getCheckOutDate());
            ps.setInt(5, r.getNumberOfNights());
            ps.setBigDecimal(6, r.getTotalAmount());
            ps.setString(7, r.getPaymentStatus());

            System.out.println("ReservationDAO.createReservation → executing INSERT:");
            System.out.println("  user_id=" + r.getUserId() + " room_id=" + r.getRoomId()
                + " checkIn=" + r.getCheckInDate() + " checkOut=" + r.getCheckOutDate()
                + " nights=" + r.getNumberOfNights() + " total=" + r.getTotalAmount()
                + " status=" + r.getPaymentStatus());

            int rows = ps.executeUpdate();
            System.out.println("  Rows inserted: " + rows);
            return rows > 0;

        } catch (SQLException e) {
            // Print full SQL error with error code so it shows in server log
            System.err.println("=== ReservationDAO INSERT FAILED ===");
            System.err.println("SQLState  : " + e.getSQLState());
            System.err.println("ErrorCode : " + e.getErrorCode());
            System.err.println("Message   : " + e.getMessage());
            e.printStackTrace();
            // Re-throw as RuntimeException so the Servlet can catch and display it
            throw new RuntimeException("[SQL " + e.getErrorCode() + "] " + e.getMessage(), e);
        } finally {
            closeResources(conn, ps, null);
        }
    }

    // ── Read All (admin) ──────────────────────────────────────────────────────
    public List<Reservation> getAllReservations() {
        List<Reservation> list = new ArrayList<>();
        String sql = "SELECT r.*, u.username, rm.room_number, rm.room_type " +
                     "FROM reservations r " +
                     "JOIN users u ON r.user_id = u.user_id " +
                     "JOIN rooms rm ON r.room_id = rm.room_id " +
                     "ORDER BY r.created_at DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            System.err.println("getAllReservations error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    // ── Read by User (guest) ──────────────────────────────────────────────────
    public List<Reservation> getReservationsByUserId(int userId) {
        List<Reservation> list = new ArrayList<>();
        String sql = "SELECT r.*, u.username, rm.room_number, rm.room_type " +
                     "FROM reservations r " +
                     "JOIN users u ON r.user_id = u.user_id " +
                     "JOIN rooms rm ON r.room_id = rm.room_id " +
                     "WHERE r.user_id = ? ORDER BY r.created_at DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            System.err.println("getReservationsByUserId error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(conn, ps, rs);
        }
        return list;
    }

    // ── Read by ID ────────────────────────────────────────────────────────────
    public Reservation getReservationById(int reservationId) {
        String sql = "SELECT r.*, u.username, rm.room_number, rm.room_type " +
                     "FROM reservations r " +
                     "JOIN users u ON r.user_id = u.user_id " +
                     "JOIN rooms rm ON r.room_id = rm.room_id " +
                     "WHERE r.reservation_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, reservationId);
            rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) {
            System.err.println("getReservationById error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(conn, ps, rs);
        }
        return null;
    }

    // ── Update ────────────────────────────────────────────────────────────────
    public boolean updateReservation(Reservation r) {
        String sql = "UPDATE reservations SET room_id=?, check_in_date=?, check_out_date=?, " +
                     "number_of_nights=?, total_amount=?, payment_status=? " +
                     "WHERE reservation_id=?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, r.getRoomId());
            ps.setDate(2, r.getCheckInDate());
            ps.setDate(3, r.getCheckOutDate());
            ps.setInt(4, r.getNumberOfNights());
            ps.setBigDecimal(5, r.getTotalAmount());
            ps.setString(6, r.getPaymentStatus());
            ps.setInt(7, r.getReservationId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("updateReservation error: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    // ── Update Payment Status ─────────────────────────────────────────────────
    public boolean updatePaymentStatus(int reservationId, String status) {
        String sql = "UPDATE reservations SET payment_status=? WHERE reservation_id=?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, status);
            ps.setInt(2, reservationId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("updatePaymentStatus error: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    // ── Delete ────────────────────────────────────────────────────────────────
    public boolean deleteReservation(int reservationId) {
        String sql = "DELETE FROM reservations WHERE reservation_id=?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, reservationId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("deleteReservation error: " + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }

    // ── Count helpers ─────────────────────────────────────────────────────────
    public int getTotalReservationCount() {
        String sql = "SELECT COUNT(*) FROM reservations";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    public int getTotalGuestCount() {
        // ── counts all users that are NOT admin ───────────────────────────────
        // Using UPPER() so it works regardless of how role is stored (GUEST/Guest/guest)
        String sql = "SELECT COUNT(*) FROM users WHERE UPPER(role) = 'GUEST'";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, ps, rs);
        }
        return 0;
    }

    // ── Row mapper ────────────────────────────────────────────────────────────
    private Reservation mapRow(ResultSet rs) throws SQLException {
        Reservation r = new Reservation();
        r.setReservationId(rs.getInt("reservation_id"));
        r.setUserId(rs.getInt("user_id"));
        r.setRoomId(rs.getInt("room_id"));
        r.setCheckInDate(rs.getDate("check_in_date"));
        r.setCheckOutDate(rs.getDate("check_out_date"));
        r.setNumberOfNights(rs.getInt("number_of_nights"));
        r.setTotalAmount(rs.getBigDecimal("total_amount"));
        r.setPaymentStatus(rs.getString("payment_status"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        r.setUsername(rs.getString("username"));
        r.setRoomNumber(rs.getString("room_number"));
        r.setRoomType(rs.getString("room_type"));
        return r;
    }

    // ── Close resources ───────────────────────────────────────────────────────
    private void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        try { if (rs   != null) rs.close();   } catch (SQLException ignored) {}
        try { if (ps   != null) ps.close();   } catch (SQLException ignored) {}
        try { if (conn != null) conn.close();  } catch (SQLException ignored) {}
    }
}