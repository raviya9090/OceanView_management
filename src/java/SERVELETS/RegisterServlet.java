package SERVELETS;

import SERVICES.AuthService;
import java.io.IOException;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private AuthService authService;
    
    @Override
    public void init() {
        authService = new AuthService();
        System.out.println("RegisterServlet initialized");
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect GET requests to register page
        response.sendRedirect(request.getContextPath() + "/register.jsp");
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Get parameters from request
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String contactNumber = request.getParameter("contactNumber");
        String nic = request.getParameter("nic");
        
        System.out.println("Registration attempt for username: " + username);
        
        // Validate input - check for null or empty
        if (username == null || password == null || confirmPassword == null ||
            contactNumber == null || nic == null ||
            username.trim().isEmpty() || password.trim().isEmpty() || 
            confirmPassword.trim().isEmpty() || contactNumber.trim().isEmpty() || 
            nic.trim().isEmpty()) {
            
            System.err.println("Registration failed: Empty fields");
            response.sendRedirect(request.getContextPath() + "/register.jsp?error=empty");
            return;
        }
        
        // Validate password match
        if (!password.equals(confirmPassword)) {
            System.err.println("Registration failed: Passwords do not match");
            response.sendRedirect(request.getContextPath() + "/register.jsp?error=password");
            return;
        }
        
        // Validate password length
        if (password.length() < 6) {
            System.err.println("Registration failed: Password too short");
            response.sendRedirect(request.getContextPath() + "/register.jsp?error=length");
            return;
        }
        
        // Validate contact number (must be 10 digits)
        if (!contactNumber.matches("\\d{10}")) {
            System.err.println("Registration failed: Invalid contact number");
            response.sendRedirect(request.getContextPath() + "/register.jsp?error=contact");
            return;
        }
        
        // Validate NIC (must be 12 digits)
        if (!nic.matches("\\d{12}")) {
            System.err.println("Registration failed: Invalid NIC");
            response.sendRedirect(request.getContextPath() + "/register.jsp?error=nic");
            return;
        }
        
        // Attempt registration
        boolean success = authService.register(
            username.trim(), 
            password, 
            contactNumber.trim(), 
            nic.trim()
        );
        
        if (success) {
            // Registration successful - redirect to login with success message
            System.out.println("Registration successful for username: " + username);
            response.sendRedirect(request.getContextPath() + "/login.jsp?success=true");
        } else {
            // Registration failed - username already exists
            System.err.println("Registration failed: Username already exists: " + username);
            response.sendRedirect(request.getContextPath() + "/register.jsp?error=username");
        }
    }
    
    @Override
    public void destroy() {
        System.out.println("RegisterServlet destroyed");
    }
}