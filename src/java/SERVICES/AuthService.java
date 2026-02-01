package SERVICES;

import DAO.UserDAO;
import MODELS.User;

public class AuthService {
    private final UserDAO userDAO = new UserDAO();
    
    /**
     * Login user with username and password
     * @param username Username
     * @param password Password (plain text)
     * @return User object if login successful, null otherwise
     */
    public User login(String username, String password) {
        // Validate input
        if (username == null || password == null || username.trim().isEmpty() || password.trim().isEmpty()) {
            System.err.println("Login failed: Empty username or password");
            return null;
        }
        
        // Get user from database
        User user = userDAO.getUserByUsername(username);
        
        // Check if user exists and password matches
        if (user != null && user.getPassword().equals(password)) {
            System.out.println("Login successful for user: " + username);
            return user;
        }
        
        System.err.println("Login failed: Invalid credentials for user: " + username);
        return null;
    }
    
    /**
     * Register new guest user
     * ADMIN CANNOT REGISTER - Only GUEST role allowed
     * @param username Username
     * @param password Password (plain text)
     * @param contactNumber Contact number (10 digits)
     * @param nic NIC number (12 digits)
     * @return true if registration successful, false otherwise
     */
    public boolean register(String username, String password, String contactNumber, String nic) {
        // Validate input
        if (!validateRegistrationInput(username, password, contactNumber, nic)) {
            return false;
        }
        
        // Check if username already exists
        if (userDAO.usernameExists(username)) {
            System.err.println("Registration failed: Username already exists: " + username);
            return false;
        }
        
        // Create new user object
        User user = new User();
        user.setUsername(username.trim());
        user.setPassword(password); // Storing plain text as per requirement
        user.setContactNumber(contactNumber.trim());
        user.setNic(nic.trim());
        user.setRole("GUEST"); // Only GUEST role allowed for registration
        
        // Save user to database
        boolean success = userDAO.createUser(user);
        
        if (success) {
            System.out.println("Registration successful for user: " + username);
        } else {
            System.err.println("Registration failed for user: " + username);
        }
        
        return success;
    }
    
    /**
     * Validate registration input
     * @param username Username
     * @param password Password
     * @param contactNumber Contact number
     * @param nic NIC number
     * @return true if valid, false otherwise
     */
    private boolean validateRegistrationInput(String username, String password, String contactNumber, String nic) {
        // Check for null or empty values
        if (username == null || password == null || contactNumber == null || nic == null) {
            System.err.println("Registration validation failed: Null values");
            return false;
        }
        
        if (username.trim().isEmpty() || password.trim().isEmpty() || 
            contactNumber.trim().isEmpty() || nic.trim().isEmpty()) {
            System.err.println("Registration validation failed: Empty values");
            return false;
        }
        
        // Validate password length (minimum 6 characters)
        if (password.length() < 6) {
            System.err.println("Registration validation failed: Password too short");
            return false;
        }
        
        // Validate contact number (must be 10 digits)
        if (!contactNumber.matches("\\d{10}")) {
            System.err.println("Registration validation failed: Invalid contact number format");
            return false;
        }
        
        // Validate NIC (must be 12 digits)
        if (!nic.matches("\\d{12}")) {
            System.err.println("Registration validation failed: Invalid NIC format");
            return false;
        }
        
        return true;
    }
    
    /**
     * Check if user is admin
     * @param user User object
     * @return true if admin, false otherwise
     */
    public boolean isAdmin(User user) {
        return user != null && "ADMIN".equalsIgnoreCase(user.getRole());
    }
    
    /**
     * Check if user is guest
     * @param user User object
     * @return true if guest, false otherwise
     */
    public boolean isGuest(User user) {
        return user != null && "GUEST".equalsIgnoreCase(user.getRole());
    }
}