package DAO;

import MODELS.User;
import UTILS.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    public User getUserByUsername(String username) {
        String sql = "SELECT * FROM users WHERE username = ?";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            rs = ps.executeQuery();
            if (rs.next()) return mapUser(rs);
        } catch (SQLException e) {
            System.err.println("Error getting user by username: " + username);
            e.printStackTrace();
        } finally { closeResources(conn, ps, rs); }
        return null;
    }

    public boolean createUser(User user) {
        String sql = "INSERT INTO users (username, password, contact_number, nic, role) VALUES (?, ?, ?, ?, ?)";
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPassword());
            ps.setString(3, user.getContactNumber());
            ps.setString(4, user.getNic());
            ps.setString(5, user.getRole());
            int rows = ps.executeUpdate();
            System.out.println("User created: " + user.getUsername());
            return rows > 0;
        } catch (SQLException e) {
            System.err.println("Error creating user: " + user.getUsername());
            e.printStackTrace();
            return false;
        } finally { closeResources(conn, ps, null); }
    }

    public User getUserById(int userId) {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            if (rs.next()) return mapUser(rs);
        } catch (SQLException e) {
            System.err.println("Error getting user by ID: " + userId);
            e.printStackTrace();
        } finally { closeResources(conn, ps, rs); }
        return null;
    }

    public boolean usernameExists(String username) {
        return getUserByUsername(username) != null;
    }

    // ── Get all GUEST users ───────────────────────────────────────────────────
    // UPPER(role) handles any casing: 'GUEST', 'Guest', 'guest' all work
    public List<User> getAllGuests() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE UPPER(role) = 'GUEST' ORDER BY username ASC";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapUser(rs));
            System.out.println("getAllGuests() found: " + list.size() + " users");
        } catch (SQLException e) {
            System.err.println("Error getAllGuests: " + e.getMessage());
            e.printStackTrace();
        } finally { closeResources(conn, ps, rs); }
        return list;
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getInt("user_id"));
        user.setUsername(rs.getString("username"));
        user.setPassword(rs.getString("password"));
        user.setContactNumber(rs.getString("contact_number"));
        user.setNic(rs.getString("nic"));
        user.setRole(rs.getString("role"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        return user;
    }

    private void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        try { if (rs   != null) rs.close();  } catch (SQLException ignored) {}
        try { if (ps   != null) ps.close();  } catch (SQLException ignored) {}
        try { if (conn != null) conn.close(); } catch (SQLException ignored) {}
    }
}