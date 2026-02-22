<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // If already logged in, redirect to appropriate dashboard
    HttpSession userSession = request.getSession(false);
    if (userSession != null && userSession.getAttribute("userId") != null) {
        String role = (String) userSession.getAttribute("role");
        if ("ADMIN".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/PAGES/admin-dashboard.jsp");
            return;
        } else {
            response.sendRedirect(request.getContextPath() + "/PAGES/customer-dashboard.jsp");
            return;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Ocean View Resort</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #ffffff;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* Header */
        header {
            background: #ffffff;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            padding: 1rem 0;
        }

        nav {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0 2rem;
        }

        .logo {
            font-size: 1.8rem;
            font-weight: bold;
            color: #ff6b35;
            text-decoration: none;
        }

        /* Main Content */
        .login-container {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem;
            background: linear-gradient(135deg, #ffffff 0%, #fff5f2 100%);
        }

        .login-box {
            background: #ffffff;
            padding: 3rem;
            border-radius: 12px;
            box-shadow: 0 5px 30px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 450px;
            border: 2px solid #f5f5f5;
        }

        .login-header {
            text-align: center;
            margin-bottom: 2rem;
        }

        .login-header h1 {
            color: #2c3e50;
            font-size: 2rem;
            margin-bottom: 0.5rem;
        }

        .login-header p {
            color: #5a6c7d;
            font-size: 1rem;
        }

        .form-group {
            margin-bottom: 1.5rem;
        }

        .form-group label {
            display: block;
            margin-bottom: 0.5rem;
            color: #2c3e50;
            font-weight: 600;
            font-size: 0.95rem;
        }

        .form-group input {
            width: 100%;
            padding: 0.9rem;
            border: 2px solid #e8e8e8;
            border-radius: 8px;
            font-size: 1rem;
            transition: all 0.3s ease;
        }

        .form-group input:focus {
            outline: none;
            border-color: #ff6b35;
            box-shadow: 0 0 0 3px rgba(255, 107, 53, 0.1);
        }

        .btn-login {
            width: 100%;
            padding: 1rem;
            background: #ff6b35;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 1.1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .btn-login:hover {
            background: #e55a2b;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(255, 107, 53, 0.3);
        }

        .form-footer {
            text-align: center;
            margin-top: 2rem;
            padding-top: 1.5rem;
            border-top: 1px solid #e8e8e8;
        }

        .form-footer p {
            color: #5a6c7d;
            margin-bottom: 0.5rem;
        }

        .form-footer a {
            color: #ff6b35;
            text-decoration: none;
            font-weight: 600;
            transition: color 0.3s ease;
        }

        .form-footer a:hover {
            color: #e55a2b;
            text-decoration: underline;
        }

        .error-message {
            background: #ffe5e5;
            color: #d32f2f;
            padding: 0.8rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
            border-left: 4px solid #d32f2f;
            display: none;
        }

        .success-message {
            background: #e5ffe5;
            color: #2d7a2d;
            padding: 0.8rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
            border-left: 4px solid #2d7a2d;
            display: none;
        }

        .back-home {
            display: inline-block;
            color: #ff6b35;
            text-decoration: none;
            font-weight: 600;
            transition: color 0.3s ease;
        }

        .back-home:hover {
            color: #e55a2b;
        }

        /* Footer */
        footer {
            background: #2c3e50;
            color: white;
            padding: 1.5rem;
            text-align: center;
        }

        @media (max-width: 768px) {
            .login-box {
                padding: 2rem;
            }

            .login-header h1 {
                font-size: 1.5rem;
            }
        }
    </style>
</head>
<body>
    <!-- Login Form -->
    <div class="login-container">
        <div class="login-box">
            <div class="login-header">
                <h1>Login</h1>
                <p>Enter your credentials to access the system</p>
            </div>

            <div id="errorMessage" class="error-message"></div>
            <div id="successMessage" class="success-message"></div>

            <form action="<%= request.getContextPath() %>/LoginServlet" method="POST">
                <div class="form-group">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username" required 
                           placeholder="Enter your username" autocomplete="username">
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" required 
                           placeholder="Enter your password" autocomplete="current-password">
                </div>

                <button type="submit" class="btn-login">Login</button>
            </form>

            <div class="form-footer">
                <p>Don't have an account?</p>
                <a href="./register.jsp">Register as Guest</a>
            </div>
        </div>
    </div>

    <script>
        // Display error or success message if passed from servlet
        const urlParams = new URLSearchParams(window.location.search);
        const error = urlParams.get('error');
        const success = urlParams.get('success');
        
        if (error) {
            const errorDiv = document.getElementById('errorMessage');
            errorDiv.style.display = 'block';
            
            if (error === 'invalid') {
                errorDiv.textContent = 'Invalid username or password. Please try again.';
            } else if (error === 'empty') {
                errorDiv.textContent = 'Please fill in all fields.';
            } else if (error === 'system') {
                errorDiv.textContent = 'System error occurred. Please try again later.';
            } else if (error === 'unauthorized') {
                errorDiv.textContent = 'You are not authorized to access that page.';
            } else {
                errorDiv.textContent = 'An error occurred. Please try again.';
            }
        }
        
        if (success === 'true') {
            const successDiv = document.getElementById('successMessage');
            successDiv.style.display = 'block';
            successDiv.textContent = 'Registration successful! Please login with your credentials.';
        }
    </script>
</body>
</html>
