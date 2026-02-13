package SERVELETS;

import MODELS.User;
import SERVICES.AuthService;
import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
//this is for testing purpose
@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private AuthService authService;
    
    @Override
    public void init() {
        authService = new AuthService();
        System.out.println("LoginServlet initialized");
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect GET requests to login page
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Get parameters from request
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        
        System.out.println("Login attempt for username: " + username);
        
        // Validate input - check for null or empty
        if (username == null || password == null || 
            username.trim().isEmpty() || password.trim().isEmpty()) {
            System.err.println("Login failed: Empty credentials");
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=empty");
            return;
        }
        
        // Attempt login
        User user = authService.login(username.trim(), password);
        
        if (user != null) {
            // Login successful - create session
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            session.setAttribute("userId", user.getUserId());
            session.setAttribute("username", user.getUsername());
            session.setAttribute("role", user.getRole());
            
            // Set session timeout (30 minutes)
            session.setMaxInactiveInterval(30 * 60);
            
            System.out.println("Login successful for user: " + username + " (Role: " + user.getRole() + ")");
            
            // Redirect based on role
            if ("ADMIN".equalsIgnoreCase(user.getRole())) {
                response.sendRedirect(request.getContextPath() + "/admin-dashboard.jsp");
            } else if ("GUEST".equalsIgnoreCase(user.getRole())) {
                response.sendRedirect(request.getContextPath() + "/customer-dashboard.jsp");
            } else {
                // Unknown role - redirect to login
                System.err.println("Unknown role: " + user.getRole());
                response.sendRedirect(request.getContextPath() + "/login.jsp?error=invalid");
            }
        } else {
            // Login failed
            System.err.println("Login failed: Invalid credentials for username: " + username);
            response.sendRedirect(request.getContextPath() + "/login.jsp?error=invalid");
        }
    }
    
    @Override
    public void destroy() {
        System.out.println("LoginServlet destroyed");
    }
}
