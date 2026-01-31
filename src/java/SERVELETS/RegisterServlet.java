package SERVELETS;

import SERVICES.AuthService;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    private AuthService authService;
    
    @Override
    public void init() {
        authService = new AuthService();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String contactNumber = request.getParameter("contactNumber");
        String nic = request.getParameter("nic");
        
        // Validation: Check if all fields are filled
        if (username == null || username.trim().isEmpty() ||
            password == null || password.trim().isEmpty() ||
            confirmPassword == null || confirmPassword.trim().isEmpty() ||
            contactNumber == null || contactNumber.trim().isEmpty() ||
            nic == null || nic.trim().isEmpty()) {
            
            response.sendRedirect(request.getContextPath() + "/register.jsp?error=empty");
            return;
        }
        
        // Validation: Check if passwords match
        if (!password.equals(confirmPassword)) {
            response.sendRedirect(request.getContextPath() + "/register.jsp?error=password");
            return;
        }
        
        // Validation: Check password length
        if (password.length() < 6) {
            response.sendRedirect(request.getContextPath() + "/register.jsp?error=length");
            return;
        }
        
        // Validation: Check contact number format (10 digits)
        if (!contactNumber.matches("\\d{10}")) {
            response.sendRedirect(request.getContextPath() + "/register.jsp?error=contact");
            return;
        }
        
        // Validation: Check NIC format (12 digits)
        if (!nic.matches("\\d{12}")) {
            response.sendRedirect(request.getContextPath() + "/register.jsp?error=nic");
            return;
        }
        
        try {
            // Attempt registration
            boolean success = authService.register(username, password, contactNumber, nic);
            
            if (success) {
                // Registration successful
                response.sendRedirect(request.getContextPath() + "/register.jsp?success=true");
            } else {
                // Username already exists
                response.sendRedirect(request.getContextPath() + "/register.jsp?error=username");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/register.jsp?error=system");
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/register.jsp");
    }
}