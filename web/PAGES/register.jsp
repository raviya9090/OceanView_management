<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - Ocean View Resort</title>
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
        .register-container {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem;
            background: linear-gradient(135deg, #ffffff 0%, #fff5f2 100%);
        }

        .register-box {
            background: #ffffff;
            padding: 3rem;
            border-radius: 12px;
            box-shadow: 0 5px 30px rgba(0, 0, 0, 0.1);
            width: 100%;
            max-width: 500px;
            border: 2px solid #f5f5f5;
        }

        .register-header {
            text-align: center;
            margin-bottom: 2rem;
        }

        .register-header h1 {
            color: #2c3e50;
            font-size: 2rem;
            margin-bottom: 0.5rem;
        }

        .register-header p {
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

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
        }

        .btn-register {
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
            margin-top: 0.5rem;
        }

        .btn-register:hover {
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

        .info-box {
            background: #fff5f2;
            padding: 1rem;
            border-radius: 8px;
            margin-bottom: 1.5rem;
            border-left: 4px solid #ff6b35;
        }

        .info-box p {
            color: #5a6c7d;
            font-size: 0.9rem;
            margin: 0;
        }

        /* Footer */
        footer {
            background: #2c3e50;
            color: white;
            padding: 1.5rem;
            text-align: center;
        }

        @media (max-width: 768px) {
            .register-box {
                padding: 2rem;
            }

            .register-header h1 {
                font-size: 1.5rem;
            }

            .form-row {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <!-- Register Form -->
    <div class="register-container">
        <div class="register-box">
            <div class="register-header">
                <h1>Register</h1>
                <p>Create your account to start booking</p>
            </div>

            <div id="errorMessage" class="error-message"></div>
            <div id="successMessage" class="success-message"></div>

            <form action="<%= request.getContextPath() %>/RegisterServlet" method="POST" onsubmit="return validateForm()">
                <div class="form-group">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username" required 
                           placeholder="Choose a unique username" autocomplete="username">
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password" required 
                           placeholder="Create a strong password (min 6 characters)" autocomplete="new-password">
                </div>

                <div class="form-group">
                    <label for="confirmPassword">Confirm Password</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" required 
                           placeholder="Re-enter your password" autocomplete="new-password">
                </div>

                <div class="form-group">
                    <label for="contactNumber">Contact Number</label>
                    <input type="tel" id="contactNumber" name="contactNumber" required 
                           placeholder="0771234567 (10 digits)" pattern="[0-9]{10}" maxlength="10">
                </div>

                <div class="form-group">
                    <label for="nic">NIC Number</label>
                    <input type="text" id="nic" name="nic" required 
                           placeholder="123456789012 (12 digits)" pattern="[0-9]{12}" maxlength="12">
                </div>

                <button type="submit" class="btn-register">Register</button>
            </form>

            <div class="form-footer">
                <p>Already have an account?</p>
                <a href="./login.jsp">Login Here</a>
            </div>
        </div>
    </div>

    <script>
        function validateForm() {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            const contactNumber = document.getElementById('contactNumber').value;
            const nic = document.getElementById('nic').value;
            const errorDiv = document.getElementById('errorMessage');
            
            // Hide previous errors
            errorDiv.style.display = 'none';
            
            // Validate password match
            if (password !== confirmPassword) {
                errorDiv.style.display = 'block';
                errorDiv.textContent = 'Passwords do not match. Please try again.';
                return false;
            }
            
            // Validate password length
            if (password.length < 6) {
                errorDiv.style.display = 'block';
                errorDiv.textContent = 'Password must be at least 6 characters long.';
                return false;
            }
            
            // Validate contact number
            if (!contactNumber.match(/^\d{10}$/)) {
                errorDiv.style.display = 'block';
                errorDiv.textContent = 'Contact number must be exactly 10 digits.';
                return false;
            }
            
            // Validate NIC
            if (!nic.match(/^\d{12}$/)) {
                errorDiv.style.display = 'block';
                errorDiv.textContent = 'NIC must be exactly 12 digits.';
                return false;
            }
            
            return true;
        }

        // Display error/success message if passed from servlet
        const urlParams = new URLSearchParams(window.location.search);
        const error = urlParams.get('error');
        const success = urlParams.get('success');
        
        if (error) {
            const errorDiv = document.getElementById('errorMessage');
            errorDiv.style.display = 'block';
            
            if (error === 'username') {
                errorDiv.textContent = 'Username already exists. Please choose another.';
            } else if (error === 'password') {
                errorDiv.textContent = 'Passwords do not match.';
            } else if (error === 'empty') {
                errorDiv.textContent = 'Please fill in all fields.';
            } else if (error === 'length') {
                errorDiv.textContent = 'Password must be at least 6 characters long.';
            } else if (error === 'contact') {
                errorDiv.textContent = 'Contact number must be exactly 10 digits.';
            } else if (error === 'nic') {
                errorDiv.textContent = 'NIC must be exactly 12 digits.';
            } else if (error === 'system') {
                errorDiv.textContent = 'System error occurred. Please try again later.';
            } else {
                errorDiv.textContent = 'Registration failed. Please try again.';
            }
        }
        
        if (success === 'true') {
            const successDiv = document.getElementById('successMessage');
            successDiv.style.display = 'block';
            successDiv.textContent = 'Registration successful! Redirecting to login...';
            
            setTimeout(() => {
                window.location.href = '<%= request.getContextPath() %>/login.jsp?success=true';
            }, 2000);
        }
    </script>
</body>
</html>
