package SERVICES;

import DAO.UserDAO;
import MODELS.User;

public class AuthService {
    private UserDAO userDAO;
    
    public AuthService() {
        this.userDAO = new UserDAO();
    }
    
    public User login(String username, String password) {
        User user = userDAO.getUserByUsername(username);
        if (user != null && user.getPassword().equals(password)) {
            return user;
        }
        return null;
    }
    
    public boolean register(String username, String password, String contactNumber, String nic) {
        // Check if username already exists
        if (userDAO.getUserByUsername(username) != null) {
            return false;
        }
        
        User newUser = new User();
        newUser.setUsername(username);
        newUser.setPassword(password);
        newUser.setContactNumber(contactNumber);
        newUser.setNic(nic);
        newUser.setRole("GUEST");
        
        return userDAO.createUser(newUser);
    }
    
    public boolean isUsernameAvailable(String username) {
        return userDAO.getUserByUsername(username) == null;
    }
}