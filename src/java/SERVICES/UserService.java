package SERVICES;

import DAO.UserDAO;
import MODELS.User;
import java.util.List;

public class UserService {
    private final UserDAO dao = new UserDAO();

    /**
     * Get all GUEST-role users for admin dropdowns
     */
    public List<User> getAllGuests() {
        return dao.getAllGuests();
    }

    /**
     * Get a single user by their ID
     */
    public User getUserById(int userId) {
        return dao.getUserById(userId);
    }
}