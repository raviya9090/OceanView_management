<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Ocean View Resort - Reservation System</title>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }

            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                overflow-x: hidden;
                background-color: #ffffff;
            }

            /* Header Styles */
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
                margin-top: 80px;
                min-height: calc(100vh - 80px);
                background: #ffffff;
                display: flex;
                align-items: center;
                justify-content: center;
                position: relative;
                padding: 4rem 2rem;
            }

            .hero::before {
                content: '';
                position: absolute;
                top: 0;
                right: 0;
                width: 50%;
                height: 100%;
                background: #fff5f2;
                z-index: 0;
                border-bottom-left-radius: 50% 20%;
            }

            .hero-content {
                max-width: 1200px;
                text-align: center;
                position: relative;
                z-index: 1;
                animation: fadeInUp 1s ease;
            }

            @keyframes fadeInUp {
                from {
                    opacity: 0;
                    transform: translateY(30px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            .hero h1 {
                font-size: 3.5rem;
                color: #2c3e50;
                margin-bottom: 1.5rem;
                font-weight: 700;
                line-height: 1.2;
            }

            .hero h1 span {
                color: #ff6b35;
            }

            .hero p {
                font-size: 1.3rem;
                color: #5a6c7d;
                margin-bottom: 3rem;
                max-width: 700px;
                margin-left: auto;
                margin-right: auto;
            }

            /* Features Section */
            .features {
                padding: 5rem 2rem;
                max-width: 1200px;
                margin: 0 auto;
                background: #ffffff;
            }

            .features h2 {
                text-align: center;
                font-size: 2.5rem;
                margin-bottom: 3rem;
                color: #2c3e50;
            }

            .features h2 span {
                color: #ff6b35;
            }

            .features-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
                gap: 2rem;
            }

            .feature-card {
                background: #ffffff;
                padding: 2rem;
                border-radius: 12px;
                box-shadow: 0 3px 15px rgba(0, 0, 0, 0.08);
                transition: all 0.3s ease;
                border: 2px solid #f5f5f5;
            }

            .user-info {
                display: flex;
                align-items: center;
                gap: 1.5rem;
            }

            .username {
                color: #2c3e50;
                font-weight: 600;
                font-size: 0.9rem;
            }

            .btn-logout {
                padding: 0.5rem 1.2rem;
                background: #ff6b35;
                color: white;
                border: none;
                border-radius: 6px;
                cursor: pointer;
                font-size: 0.85rem;
                font-weight: 600;
                transition: all 0.3s ease;
            }

            .btn-logout:hover {
                background: #e55a2b;
            }

            .feature-card:hover {
                transform: translateY(-8px);
                box-shadow: 0 8px 25px rgba(255, 107, 53, 0.15);
                border-color: #ff6b35;
            }

            .feature-icon {
                width: 60px;
                height: 60px;
                background: #fff5f2;
                border-radius: 10px;
                display: flex;
                align-items: center;
                justify-content: center;
                margin-bottom: 1.5rem;
                font-size: 1.2rem;
                font-weight: bold;
                color: #ff6b35;
            }

            .feature-card h3 {
                color: #2c3e50;
                margin-bottom: 1rem;
                font-size: 1.4rem;
            }

            .feature-card p {
                color: #5a6c7d;
                line-height: 1.6;
            }

            /* About Section */
            .about {
                background: #fff5f2;
                padding: 5rem 2rem;
            }

            .about-content {
                max-width: 1200px;
                margin: 0 auto;
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 3rem;
                align-items: center;
            }

            .about-text h2 {
                font-size: 2.5rem;
                color: #2c3e50;
                margin-bottom: 1.5rem;
            }

            .about-text h2 span {
                color: #ff6b35;
            }

            .about-text p {
                color: #5a6c7d;
                line-height: 1.8;
                margin-bottom: 1rem;
            }

            .about-image {
                width: 100%;
                height: 400px;
                background: linear-gradient(135deg, #ffe8e0 0%, #ffd5c8 100%);
                border-radius: 12px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 2rem;
                color: #ff6b35;
                font-weight: bold;
            }

            /* CTA Section */
            .cta {
                background: #fff5f2;
                padding: 5rem 2rem;
                text-align: center;
            }

            .cta h2 {
                font-size: 2.5rem;
                margin-bottom: 1.5rem;
                color: #2c3e50;
            }

            .cta h2 span {
                color: #ff6b35;
            }

            .cta p {
                font-size: 1.2rem;
                margin-bottom: 2rem;
                color: #5a6c7d;
            }

            .btn-large {
                padding: 1rem 3rem;
                font-size: 1.1rem;
                background: #ff6b35;
                color: white;
                border-radius: 8px;
            }

            .btn-large:hover {
                background: #e55a2b;
                transform: translateY(-3px);
                box-shadow: 0 8px 20px rgba(255, 107, 53, 0.3);
            }

            /* Footer */
            footer {
                background: #2c3e50;
                color: white;
                padding: 2rem;
                text-align: center;
            }

            /* Responsive Design */
            @media (max-width: 968px) {
                .nav-links,
                .nav-buttons {
                    display: none;
                }

                .mobile-menu-btn {
                    display: block;
                }

                .hero h1 {
                    font-size: 2.5rem;
                }

                .hero p {
                    font-size: 1.1rem;
                }

                .about-content {
                    grid-template-columns: 1fr;
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
        <section class="hero">
            <div class="hero-content">
                <h1>Welcome to <span>Ocean View Resort</span></h1>
                <p>Experience luxury beachside accommodation in Galle with our modern reservation management system. Book your perfect getaway today.</p>
                <a href="register.jsp" class="btn btn-large">Get Started</a>
            </div>
        </section>

        <!-- About Section -->
        <section class="about" id="about">
            <div class="about-content">
                <div class="about-text">
                    <h2>About <span>Ocean View Resort</span></h2>
                    <p>Nestled along the pristine beaches of Galle, Ocean View Resort offers an unforgettable beachside experience. Our resort combines traditional Sri Lankan hospitality with modern amenities to create the perfect vacation destination.</p>
                    <p>With our state-of-the-art reservation system, booking your dream getaway has never been easier. From cozy standard rooms to luxurious presidential suites, we have accommodation options to suit every traveler's needs and budget.</p>
                    <p>Our commitment to excellence ensures that every guest receives personalized service and enjoys a memorable stay at our beautiful beachfront property.</p>
                </div>
                <div class="about-image">
                    <img width="600px" src="https://images.unsplash.com/photo-1596436889106-be35e843f974?w=800&q=80" alt="Ocean View Resort Pool">
                </div>
            </div>
        </section>

        <!-- Features Section -->
        <section class="features" id="features">
            <h2>Our <span>Reservation System</span> Features</h2>
            <div class="features-grid">
                <div class="feature-card">
                    <div class="feature-icon">SEC</div>
                    <h3>Secure Access</h3>
                    <p>Protected login system ensures your reservation data is safe and accessible only to authorized staff.</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">BOOK</div>
                    <h3>Easy Booking</h3>
                    <p>Streamlined reservation process with instant confirmation and booking conflict prevention.</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">BILL</div>
                    <h3>Automated Billing</h3>
                    <p>Calculate total costs automatically based on room type and duration of stay.</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">MGMT</div>
                    <h3>Guest Management</h3>
                    <p>Comprehensive guest records with contact details and reservation history.</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">SRCH</div>
                    <h3>Quick Search</h3>
                    <p>Instantly retrieve reservation details using unique reservation numbers.</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon">UI</div>
                    <h3>User Friendly</h3>
                    <p>Intuitive interface designed for staff members of all technical levels.</p>
                </div>
            </div>
        </section>

        <!-- CTA Section -->
        <section class="cta">
            <h2>Ready to <span>Streamline</span> Your Operations?</h2>
            <p>Join Ocean View Resort's modern reservation management system</p>
            <a href="register.jsp" class="btn btn-large">Sign Up Now</a>
        </section>

        <!-- Footer -->
        <footer>
            <p>&copy; 2026 Ocean View Resort, Galle. All rights reserved.</p>
        </footer>
    </body>
</html>