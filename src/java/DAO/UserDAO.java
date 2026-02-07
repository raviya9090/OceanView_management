package DAO;

import MODELS.User;
import UTILS.DBConnection;
import java.sql.*;

public class UserDAO {
    
    /**
     * Get user by username
     * @param username Username to search for
     * @return User object if found, null otherwise
     */
    public User getUserByUsername(String username) {
        String sql = "SELECT * FROM users WHERE username = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapUser(rs);
            }
        } catch (SQLException e) {
            System.err.println("Error getting user by username: " + username);
            e.printStackTrace();
        } finally {
            closeResources(conn, ps, rs);
        }
        
        return null;
    }
    
    /**
     * Create new user in database
     * @param user User object to create
     * @return true if creation successful, false otherwise
     */
    public boolean createUser(User user) {
        String sql = "INSERT INTO users (username, password, contact_number, nic, role) VALUES (?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPassword());
            ps.setString(3, user.getContactNumber());
            ps.setString(4, user.getNic());
            ps.setString(5, user.getRole());
            
            int rowsAffected = ps.executeUpdate();
            System.out.println("User created successfully: " + user.getUsername());
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("Error creating user: " + user.getUsername());
            e.printStackTrace();
            return false;
        } finally {
            closeResources(conn, ps, null);
        }
    }
    
    /**
     * Get user by ID
     * @param userId User ID to search for
     * @return User object if found, null otherwise
     */
    public User getUserById(int userId) {
        String sql = "SELECT * FROM users WHERE user_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return mapUser(rs);
            }
        } catch (SQLException e) {
            System.err.println("Error getting user by ID: " + userId);
            e.printStackTrace();
        } finally {
            closeResources(conn, ps, rs);
        }
        
        return null;
    }
    
    /**
     * Check if username exists
     * @param username Username to check
     * @return true if exists, false otherwise
     */
    public boolean usernameExists(String username) {
        return getUserByUsername(username) != null;
    }
    
    /**
     * Map ResultSet to User object
     * @param rs ResultSet containing user data
     * @return User object
     * @throws SQLException if mapping fails
     */
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
    
    /**
     * Close database resources
     * @param conn Connection to close
     * @param ps PreparedStatement to close
     * @param rs ResultSet to close
     */
    private void closeResources(Connection conn, PreparedStatement ps, ResultSet rs) {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            System.err.println("Error closing database resources");
            e.printStackTrace();
        }
    }
}
