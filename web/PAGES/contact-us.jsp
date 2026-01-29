<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Contact Us - Ocean View Resort</title>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }

            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background-color: #ffffff;
            }

            header {
                position: fixed;
                top: 0;
                left: 0;
                right: 0;
                z-index: 1000;
                background: rgba(255, 255, 255, 0.98);
                backdrop-filter: blur(10px);
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
                padding: 1rem 0;
            }

            nav {
                max-width: 1400px;
                margin: 0 auto;
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 0 2rem;
            }

            .logo {
                font-size: 1.6rem;
                font-weight: bold;
                color: #ff6b35;
                text-decoration: none;
                transition: color 0.3s ease;
            }

            .logo:hover {
                color: #e55a2b;
            }

            /* Navigation Menu */
            .nav-menu {
                display: flex;
                align-items: center;
                gap: 2rem;
            }

            .nav-links {
                display: flex;
                gap: 2rem;
                align-items: center;
            }

            .nav-links a {
                color: #2c3e50;
                text-decoration: none;
                font-weight: 600;
                font-size: 0.95rem;
                transition: color 0.3s ease;
                position: relative;
            }

            .nav-links a:hover {
                color: #ff6b35;
            }

            .nav-links a.active {
                color: #ff6b35;
            }

            .nav-links a::after {
                content: '';
                position: absolute;
                width: 0;
                height: 2px;
                bottom: -5px;
                left: 0;
                background-color: #ff6b35;
                transition: width 0.3s ease;
            }

            .nav-links a:hover::after,
            .nav-links a.active::after {
                width: 100%;
            }

            /* Navigation Buttons */
            .nav-buttons {
                display: flex;
                gap: 1rem;
            }

            .btn {
                padding: 0.6rem 1.5rem;
                border: none;
                border-radius: 8px;
                font-size: 0.9rem;
                cursor: pointer;
                transition: all 0.3s ease;
                font-weight: 600;
                text-decoration: none;
                display: inline-block;
            }

            .btn-login {
                background: transparent;
                color: #ff6b35;
                border: 2px solid #ff6b35;
            }

            .btn-login:hover {
                background: #ff6b35;
                color: white;
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(255, 107, 53, 0.3);
            }

            .btn-register {
                background: #ff6b35;
                color: white;
                border: 2px solid #ff6b35;
            }

            .btn-register:hover {
                background: #e55a2b;
                border-color: #e55a2b;
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(255, 107, 53, 0.4);
            }

            .btn-logout {
                padding: 0.6rem 1.5rem;
                background: #ff6b35;
                color: white;
                border: none;
                border-radius: 8px;
                cursor: pointer;
                font-size: 0.9rem;
                font-weight: 600;
                transition: all 0.3s ease;
            }

            .btn-logout:hover {
                background: #e55a2b;
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(255, 107, 53, 0.4);
            }

            /* User Info (for Guest Dashboard) */
            .user-info {
                display: flex;
                align-items: center;
                gap: 1.5rem;
            }

            .username {
                color: #2c3e50;
                font-weight: 600;
                font-size: 0.9rem;
                padding: 0.5rem 1rem;
                background: #fff5f2;
                border-radius: 6px;
            }

            /* Mobile Menu Button */
            .mobile-menu-btn {
                display: none;
                background: none;
                border: none;
                font-size: 1.5rem;
                color: #ff6b35;
                cursor: pointer;
                padding: 0.5rem;
            }

            .mobile-menu-btn:hover {
                color: #e55a2b;
            }

            /* Mobile Navigation */
            .mobile-nav {
                display: none;
                position: fixed;
                top: 70px;
                left: 0;
                right: 0;
                background: white;
                box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
                padding: 1rem 2rem;
                flex-direction: column;
                gap: 1rem;
            }

            .mobile-nav.active {
                display: flex;
            }

            .mobile-nav a {
                color: #2c3e50;
                text-decoration: none;
                font-weight: 600;
                padding: 0.8rem;
                border-radius: 6px;
                transition: all 0.3s ease;
            }

            .mobile-nav a:hover {
                background: #fff5f2;
                color: #ff6b35;
            }

            /* Responsive Design */
            @media (max-width: 968px) {
                nav {
                    padding: 0 1.5rem;
                }

                .logo {
                    font-size: 1.4rem;
                }

                .nav-menu {
                    display: none;
                }

                .mobile-menu-btn {
                    display: block;
                }

                .user-info {
                    gap: 1rem;
                }

                .username {
                    display: none;
                }
            }

            @media (max-width: 480px) {
                .logo {
                    font-size: 1.2rem;
                }

                .btn {
                    padding: 0.5rem 1rem;
                    font-size: 0.85rem;
                }
            }

            /* Hero Section */
            .hero {
                background: linear-gradient(135deg, #ffffff 0%, #fff5f2 100%);
                padding: 4rem 2rem 3rem;
                text-align: center;
            }

            .hero h1 {
                font-size: 2.5rem;
                color: #2c3e50;
                margin-bottom: 1rem;
            }

            .hero h1 span {
                color: #ff6b35;
            }

            .hero p {
                font-size: 1.1rem;
                color: #5a6c7d;
                max-width: 600px;
                margin: 0 auto;
            }

            /* Contact Container */
            .contact-container {
                max-width: 1200px;
                margin: 3rem auto;
                padding: 0 2rem 3rem;
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 3rem;
            }

            /* Contact Info */
            .contact-info {
                background: white;
                padding: 2rem;
                border-radius: 12px;
                box-shadow: 0 3px 15px rgba(0, 0, 0, 0.08);
            }

            .contact-info h2 {
                color: #2c3e50;
                font-size: 1.8rem;
                margin-bottom: 1.5rem;
            }

            .info-item {
                display: flex;
                align-items: start;
                gap: 1rem;
                margin-bottom: 1.5rem;
                padding: 1rem;
                background: #fff5f2;
                border-radius: 8px;
            }

            .info-icon {
                width: 50px;
                height: 50px;
                background: #ff6b35;
                border-radius: 8px;
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                font-weight: bold;
                font-size: 0.9rem;
                flex-shrink: 0;
            }

            .info-content h3 {
                color: #2c3e50;
                font-size: 1.1rem;
                margin-bottom: 0.3rem;
            }

            .info-content p {
                color: #5a6c7d;
                line-height: 1.6;
            }

            .info-content a {
                color: #ff6b35;
                text-decoration: none;
            }

            .info-content a:hover {
                text-decoration: underline;
            }

            /* Resort Image */
            .resort-image {
                background: white;
                padding: 2rem;
                border-radius: 12px;
                box-shadow: 0 3px 15px rgba(0, 0, 0, 0.08);
            }

            .resort-image h2 {
                color: #2c3e50;
                font-size: 1.8rem;
                margin-bottom: 1.5rem;
            }

            .image-container {
                width: 100%;
                height: 400px;
                border-radius: 8px;
                overflow: hidden;
            }

            .image-container img {
                width: 100%;
                height: 100%;
                object-fit: cover;
                display: block;
            }

            /* Footer */
            footer {
                background: #2c3e50;
                color: white;
                padding: 2rem;
                text-align: center;
            }

            /* Responsive */
            @media (max-width: 968px) {
                .contact-container {
                    grid-template-columns: 1fr;
                    gap: 2rem;
                }

                .image-container {
                    height: 300px;
                }
            }
        </style>
    </head>
    <body>
        <!-- Header -->
        <header>
            <nav>
                <div class="logo">Ocean View Resort</div>
                <div class="user-info">
                    <a href="./home.jsp" class="btn btn-login">Home</a>
                    <a href="./contact-us.jsp" class="btn btn-login">Contact Us</a>
                    <a href="./customer-dashboard.jsp" class="btn btn-login">Bookings</a>
                    <span class="username">Guest</span>
                    <button class="btn-logout" onclick="logout()">Logout</button>
                </div>
            </nav>
        </header>

        <!-- Hero Section -->
        <section class="hero" style="margin-top:80px">
            <h1>Get In <span>Touch</span></h1>
            <p>We're here to help and answer any questions you might have. We look forward to hearing from you!</p>
        </section>

        <!-- Contact Container -->
        <div class="contact-container">
            <!-- Contact Info -->
            <div>
                <div class="contact-info">
                    <h2>Contact Information</h2>

                    <div class="info-item">
                        <div class="info-icon">LOC</div>
                        <div class="info-content">
                            <h3>Address</h3>
                            <p>Beach Road, Galle Fort<br>Galle 80000<br>Sri Lanka</p>
                        </div>
                    </div>

                    <div class="info-item">
                        <div class="info-icon">TEL</div>
                        <div class="info-content">
                            <h3>Phone</h3>
                            <p><a href="tel:+94912234567">+94 91 223 4567</a><br>
                                <a href="tel:+94912234568">+94 91 223 4568</a></p>
                        </div>
                    </div>

                    <div class="info-item">
                        <div class="info-icon">MAIL</div>
                        <div class="info-content">
                            <h3>Email</h3>
                            <p><a href="mailto:info@oceanviewresort.lk">info@oceanviewresort.lk</a><br>
                                <a href="mailto:reservations@oceanviewresort.lk">reservations@oceanviewresort.lk</a></p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Resort Image -->
            <div class="resort-image">
                <h2>Our Beautiful Resort</h2>
                <div class="image-container">
                    <img src="https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800&q=80" alt="Ocean View Resort Pool">
                </div>
            </div>
        </div>

        <!-- Footer -->
        <footer>
            <p>&copy; 2026 Ocean View Resort, Galle. All rights reserved.</p>
        </footer>

        <script>
            function logout() {
                // Logout functionality
                alert('Logging out...');
            }
        </script>
    </body>
</html>