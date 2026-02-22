package DAO;

import MODELS.Reservation;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReservationDAO {

    private Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL Driver not found", e);
        }
        return DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/hotel_db", "root", "");
    }

    // ── Create ────────────────────────────────────────────────────────────────
    public boolean createReservation(Reservation r) {
        String sql = "INSERT INTO reservations (user_id, room_id, check_in_date, check_out_date, " +
                     "number_of_nights, total_amount, payment_status) VALUES (?,?,?,?,?,?,?)";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, r.getUserId());
            ps.setInt(2, r.getRoomId());
            ps.setDate(3, r.getCheckInDate());
            ps.setDate(4, r.getCheckOutDate());
            ps.setInt(5, r.getNumberOfNights());
            ps.setBigDecimal(6, r.getTotalAmount());
            ps.setString(7, r.getPaymentStatus());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
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
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
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
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
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
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, reservationId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    // ── Update ────────────────────────────────────────────────────────────────
    public boolean updateReservation(Reservation r) {
        String sql = "UPDATE reservations SET room_id=?, check_in_date=?, check_out_date=?, " +
                     "number_of_nights=?, total_amount=?, payment_status=? " +
                     "WHERE reservation_id=?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, r.getRoomId());
            ps.setDate(2, r.getCheckInDate());
            ps.setDate(3, r.getCheckOutDate());
            ps.setInt(4, r.getNumberOfNights());
            ps.setBigDecimal(5, r.getTotalAmount());
            ps.setString(6, r.getPaymentStatus());
            ps.setInt(7, r.getReservationId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ── Update Payment Status only ────────────────────────────────────────────
    public boolean updatePaymentStatus(int reservationId, String status) {
        String sql = "UPDATE reservations SET payment_status=? WHERE reservation_id=?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, reservationId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ── Delete ────────────────────────────────────────────────────────────────
    public boolean deleteReservation(int reservationId) {
        String sql = "DELETE FROM reservations WHERE reservation_id=?";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, reservationId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // ── Count helpers (for admin stats) ──────────────────────────────────────
    public int getTotalReservationCount() {
        String sql = "SELECT COUNT(*) FROM reservations";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public int getTotalGuestCount() {
        String sql = "SELECT COUNT(*) FROM users WHERE role='GUEST'";
        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
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
}