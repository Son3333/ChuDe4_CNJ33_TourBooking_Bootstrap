<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập & Đăng ký | TourBooking</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root {
            --navy: #17324d;
            --orange: #e76f3c;
            --orange-hover: #c9572e;
            --bg-gray: #f5f7f5;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
            background: var(--bg-gray);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow-x: hidden;
        }

        /* Outer Shell & Sliding Container */
        .auth-container {
            position: relative;
            width: 100vw;
            min-height: 100vh;
            background: #fff;
            overflow: hidden;
            box-shadow: 0 20px 50px rgba(23, 50, 77, 0.15);
        }

        /* Form Containers */
        .form-container {
            position: absolute;
            top: 0;
            height: 100%;
            transition: all 0.7s cubic-bezier(0.77, 0, 0.175, 1);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2.5rem;
        }

        .sign-in-container {
            left: 0;
            width: 50%;
            z-index: 2;
        }

        .auth-container.right-panel-active .sign-in-container {
            transform: translateX(100%);
            opacity: 0;
            z-index: 1;
        }

        .sign-up-container {
            left: 0;
            width: 50%;
            opacity: 0;
            z-index: 1;
        }

        .auth-container.right-panel-active .sign-up-container {
            transform: translateX(100%);
            opacity: 1;
            z-index: 5;
            animation: show 0.7s;
        }

        @keyframes show {
            0%, 49.99% {
                opacity: 0;
                z-index: 1;
            }
            50%, 100% {
                opacity: 1;
                z-index: 5;
            }
        }

        .auth-card {
            width: min(440px, 100%);
        }

        .eyebrow {
            color: var(--orange);
            font-size: 0.8rem;
            font-weight: 800;
            letter-spacing: 0.12em;
            text-transform: uppercase;
        }

        .auth-card h2 {
            color: var(--navy);
            font-weight: 800;
            font-size: 2.1rem;
        }

        /* Floating Labels & Input Glow Effect */
        .form-floating > .form-control {
            border-radius: 10px;
            border: 1px solid #d7dee5;
            padding: 1rem 1rem;
            height: calc(3.5rem + 2px);
            transition: border-color 0.3s ease, box-shadow 0.3s ease;
        }

        .form-floating > .form-control:focus {
            border-color: var(--orange);
            box-shadow: 0 0 18px rgba(231, 111, 60, 0.25);
        }

        .form-floating > label {
            padding: 1rem 1rem;
            color: #64748b;
            transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
        }

        /* Buttons Hover & Active Effects */
        .btn-main {
            background: var(--orange);
            border-color: var(--orange);
            color: white;
            font-weight: 700;
            padding: 0.85rem;
            border-radius: 10px;
            font-size: 1rem;
            transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
            box-shadow: 0 4px 12px rgba(231, 111, 60, 0.2);
        }

        .btn-main:hover {
            background: var(--orange-hover);
            border-color: var(--orange-hover);
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 8px 22px rgba(231, 111, 60, 0.38);
        }

        .btn-main:active {
            transform: translateY(0);
            box-shadow: 0 2px 8px rgba(231, 111, 60, 0.2);
        }

        .btn-google {
            border: 1px solid #cbd5e1;
            border-radius: 10px;
            padding: 0.75rem;
            font-weight: 600;
            color: #334155;
            background: white;
            transition: all 0.25s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            text-decoration: none;
        }

        .btn-google:hover {
            background: #f8fafc;
            transform: translateY(-1.5px);
            box-shadow: 0 6px 16px rgba(0, 0, 0, 0.06);
            color: #0f172a;
        }

        .back-link {
            color: #64748b;
            text-decoration: none;
            font-size: 0.9rem;
            transition: color 0.2s ease;
        }

        .back-link:hover {
            color: var(--orange);
        }

        /* Overlay & Sliding Panel */
        .overlay-container {
            position: absolute;
            top: 0;
            left: 50%;
            width: 50%;
            height: 100%;
            overflow: hidden;
            transition: transform 0.7s cubic-bezier(0.77, 0, 0.175, 1);
            z-index: 100;
        }

        .auth-container.right-panel-active .overlay-container {
            transform: translateX(-100%);
        }

        .overlay {
            background: var(--navy);
            color: #FFFFFF;
            position: relative;
            left: -100%;
            height: 100%;
            width: 200%;
            transform: translateX(0);
            transition: transform 0.7s cubic-bezier(0.77, 0, 0.175, 1);
        }

        .auth-container.right-panel-active .overlay {
            transform: translateX(50%);
        }

        /* Ken Burns Background Slider */
        .bg-slider {
            position: absolute;
            inset: 0;
            z-index: 1;
        }

        .bg-slide {
            position: absolute;
            inset: 0;
            background-position: center;
            background-size: cover;
            opacity: 0;
            transition: opacity 1.5s ease-in-out;
            animation: kenburns 18s infinite alternate ease-in-out;
        }

        .bg-slide.active {
            opacity: 1;
        }

        @keyframes kenburns {
            0% { transform: scale(1); }
            100% { transform: scale(1.15); }
        }

        .overlay-dark {
            position: absolute;
            inset: 0;
            background: linear-gradient(135deg, rgba(17, 34, 55, 0.88), rgba(17, 34, 55, 0.55));
            z-index: 2;
        }

        .overlay-panel {
            position: absolute;
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            flex-direction: column;
            padding: 3.5rem 3rem;
            text-align: left;
            top: 0;
            height: 100%;
            width: 50%;
            transform: translateX(0);
            transition: transform 0.7s cubic-bezier(0.77, 0, 0.175, 1);
            z-index: 3;
        }

        .overlay-left {
            left: 0;
            transform: translateX(0);
        }

        .auth-container.right-panel-active .overlay-left {
            transform: translateX(0);
        }

        .overlay-right {
            right: 0;
            transform: translateX(0);
        }

        .auth-container.right-panel-active .overlay-right {
            transform: translateX(0);
        }

        .brand {
            font-size: 1.5rem;
            font-weight: 800;
            color: white;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .visual-copy {
            max-width: 480px;
        }

        .visual-copy h1 {
            font-family: Georgia, serif;
            font-size: clamp(2.4rem, 4vw, 3.8rem);
            line-height: 1.08;
            margin-bottom: 1rem;
        }

        /* Staggered Fade-up Text Animation */
        .fade-up {
            opacity: 0;
            transform: translateY(24px);
            animation: fadeUp 0.8s cubic-bezier(0.16, 1, 0.3, 1) forwards;
        }

        .delay-1 { animation-delay: 0.2s; }
        .delay-2 { animation-delay: 0.4s; }
        .delay-3 { animation-delay: 0.6s; }
        .delay-4 { animation-delay: 0.8s; }

        @keyframes fadeUp {
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .btn-pill-toggle {
            border-radius: 30px;
            padding: 0.6rem 1.4rem;
            font-weight: 600;
            border: 2px solid rgba(255, 255, 255, 0.8);
            color: white;
            background: transparent;
            transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
        }

        .btn-pill-toggle:hover {
            background: white;
            color: var(--navy);
            border-color: white;
            transform: translateY(-2px);
            box-shadow: 0 6px 18px rgba(255, 255, 255, 0.25);
        }

        /* Mobile Responsiveness */
        @media (max-width: 868px) {
            .auth-container {
                display: block;
                overflow-y: auto;
            }
            .form-container {
                width: 100%;
                position: relative;
                padding: 2rem 1.5rem;
            }
            .sign-in-container, .sign-up-container {
                width: 100%;
                opacity: 1;
                display: block;
            }
            .sign-up-container {
                display: none;
            }
            .auth-container.right-panel-active .sign-in-container {
                display: none;
            }
            .auth-container.right-panel-active .sign-up-container {
                display: block;
                transform: none;
            }
            .overlay-container {
                display: none;
            }
        }
    </style>
</head>
<body>

<div class="auth-container ${param.mode == 'register' || not empty requestScope.errorRegister ? 'right-panel-active' : ''}" id="authContainer">

    <!-- 1. FORM DANG NHAP -->
    <div class="form-container sign-in-container">
        <div class="auth-card">
            <p class="eyebrow mb-2">Tài khoản</p>
            <h2 class="mb-2">Đăng nhập</h2>
            <p class="text-secondary mb-4">Nhập thông tin để tiếp tục hành trình.</p>

            <c:if test="${not empty param.registered}">
                <div class="alert alert-success alert-dismissible fade show py-2 mb-3" role="alert">
                    <i class="bi bi-check-circle-fill me-1"></i> Đăng ký thành công! Vui lòng đăng nhập.
                </div>
            </c:if>

            <c:if test="${not empty requestScope.errorLogin || (not empty requestScope.error && empty requestScope.errorRegister)}">
                <div class="alert alert-danger alert-dismissible fade show py-2 mb-3" role="alert">
                    <i class="bi bi-exclamation-circle-fill me-1"></i> ${not empty requestScope.errorLogin ? requestScope.errorLogin : requestScope.error}
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/login" method="post">
                <div class="form-floating mb-3">
                    <input type="text" name="username" class="form-control" id="loginUser" placeholder="Tài khoản" autocomplete="username" required>
                    <label for="loginUser"><i class="bi bi-person me-1"></i> Tài khoản</label>
                </div>

                <div class="form-floating mb-4">
                    <input type="password" name="password" class="form-control" id="loginPass" placeholder="Mật khẩu" autocomplete="current-password" required>
                    <label for="loginPass"><i class="bi bi-lock me-1"></i> Mật khẩu</label>
                </div>

                <button type="submit" class="btn btn-main w-100 mb-3">
                    <i class="bi bi-box-arrow-in-right me-1"></i> Đăng nhập
                </button>
            </form>

            <a href="${pageContext.request.contextPath}/oauth/google" class="btn btn-google w-100 mb-4">
                <svg width="18" height="18" viewBox="0 0 18 18"><path fill="#4285F4" d="M17.64 9.2c0-.637-.057-1.251-.164-1.84H9v3.481h4.844c-.209 1.125-.843 2.078-1.796 2.717v2.258h2.908c1.702-1.567 2.684-3.874 2.684-6.616z"/><path fill="#34A853" d="M9 18c2.43 0 4.467-.806 5.956-2.18l-2.908-2.259c-.806.54-1.837.86-3.048.86-2.344 0-4.328-1.584-5.036-3.711H.957v2.332A8.997 8.997 0 0 0 9 18z"/><path fill="#FBBC05" d="M3.964 10.71A5.41 5.41 0 0 1 3.682 9c0-.593.102-1.17.282-1.71V4.958H.957A8.996 8.996 0 0 0 0 9c0 1.452.348 2.827.957 4.042l3.007-2.332z"/><path fill="#EA4335" d="M9 3.58c1.321 0 2.508.454 3.44 1.345l2.582-2.58C13.463.891 11.426 0 9 0A8.997 8.997 0 0 0 .957 4.958L3.964 7.29C4.672 5.163 6.656 3.58 9 3.58z"/></svg>
                Đăng nhập bằng Google
            </a>

            <div class="text-center">
                <p class="text-secondary mb-2">Chưa có tài khoản? <a href="${pageContext.request.contextPath}/register" id="toggleToRegister" class="fw-bold text-decoration-none" style="color:var(--orange)">Đăng ký ngay</a></p>
                <a href="${pageContext.request.contextPath}/index.jsp" class="back-link"><i class="bi bi-arrow-left me-1"></i> Về trang chủ</a>
            </div>
        </div>
    </div>

    <!-- 2. FORM DANG KY -->
    <div class="form-container sign-up-container">
        <div class="auth-card">
            <p class="eyebrow mb-2">Thành viên mới</p>
            <h2 class="mb-2">Tạo tài khoản</h2>
            <p class="text-secondary mb-4">Đăng ký nhanh để bắt đầu khám phá.</p>

            <c:if test="${not empty requestScope.errorRegister || (not empty requestScope.error && empty requestScope.errorLogin)}">
                <div class="alert alert-danger alert-dismissible fade show py-2 mb-3" role="alert">
                    <i class="bi bi-exclamation-circle-fill me-1"></i> ${not empty requestScope.errorRegister ? requestScope.errorRegister : requestScope.error}
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/register" method="post">
                <div class="form-floating mb-3">
                    <input type="text" name="fullName" class="form-control" id="regName" placeholder="Họ và tên" maxlength="100" required>
                    <label for="regName"><i class="bi bi-card-heading me-1"></i> Họ và tên</label>
                </div>

                <div class="form-floating mb-3">
                    <input type="text" name="username" class="form-control" id="regUser" placeholder="Tài khoản" maxlength="50" autocomplete="username" required>
                    <label for="regUser"><i class="bi bi-person me-1"></i> Tài khoản</label>
                </div>

                <div class="form-floating mb-3">
                    <input type="password" name="password" class="form-control" id="regPass" placeholder="Mật khẩu" minlength="8" maxlength="64" autocomplete="new-password" required>
                    <label for="regPass"><i class="bi bi-shield-lock me-1"></i> Mật khẩu</label>
                </div>

                <div class="form-floating mb-4">
                    <input type="password" name="confirmPassword" class="form-control" id="regConfirmPass" placeholder="Nhập lại mật khẩu" minlength="8" maxlength="64" autocomplete="new-password" required>
                    <label for="regConfirmPass"><i class="bi bi-check-shield me-1"></i> Nhập lại mật khẩu</label>
                </div>

                <button type="submit" class="btn btn-main w-100 mb-3">
                    <i class="bi bi-person-plus me-1"></i> Tạo tài khoản
                </button>
            </form>

            <div class="text-center">
                <p class="text-secondary mb-2">Đã có tài khoản? <a href="${pageContext.request.contextPath}/login" id="toggleToLogin" class="fw-bold text-decoration-none" style="color:var(--orange)">Đăng nhập</a></p>
                <a href="${pageContext.request.contextPath}/index.jsp" class="back-link"><i class="bi bi-arrow-left me-1"></i> Về trang chủ</a>
            </div>
        </div>
    </div>

    <!-- 3. OVERLAY SLIDING PANEL (DESKTOP) -->
    <div class="overlay-container">
        <div class="overlay">
            <!-- Ken Burns Background Slider -->
            <div class="bg-slider">
                <div class="bg-slide active" style="background-image: url('https://images.unsplash.com/photo-1570366583862-f91883984fde?auto=format&fit=crop&w=1800&q=85')"></div>
                <div class="bg-slide" style="background-image: url('https://images.unsplash.com/photo-1528127269322-539801943592?auto=format&fit=crop&w=1800&q=85')"></div>
                <div class="bg-slide" style="background-image: url('https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?auto=format&fit=crop&w=1800&q=85')"></div>
                <div class="overlay-dark"></div>
            </div>

            <!-- Overlay Panel Left (Hiển thị ở bên trái khi Đang ở trang ĐĂNG KÝ) -->
            <div class="overlay-panel overlay-left">
                <a class="brand" href="${pageContext.request.contextPath}/index.jsp">
                    <i class="bi bi-compass-fill text-warning"></i> TourBooking
                </a>
                <div class="visual-copy">
                    <p class="eyebrow text-warning fade-up delay-1">Đã có tài khoản?</p>
                    <h1 class="fade-up delay-2">Hành trình của bạn<br>đang chờ.</h1>
                    <p class="lead fade-up delay-3">Đăng nhập để tiếp tục quản lý chuyến đi và những đơn đặt của mình.</p>
                </div>
                <div class="fade-up delay-4 d-flex align-items-center justify-content-between w-100">
                    <small class="opacity-75">Đi xa hơn, sống trọn hơn.</small>
                    <button type="button" class="btn btn-pill-toggle" id="signInOverlayBtn">
                        <i class="bi bi-arrow-left me-1"></i> Đăng nhập
                    </button>
                </div>
            </div>

            <!-- Overlay Panel Right (Hiển thị ở bên phải khi Đang ở trang ĐĂNG NHẬP) -->
            <div class="overlay-panel overlay-right">
                <a class="brand" href="${pageContext.request.contextPath}/index.jsp">
                    <i class="bi bi-compass-fill text-warning"></i> TourBooking
                </a>
                <div class="visual-copy">
                    <p class="eyebrow text-warning fade-up delay-1">Thành viên mới?</p>
                    <h1 class="fade-up delay-2">Thêm một điểm đến<br>vào bản đồ.</h1>
                    <p class="lead fade-up delay-3">Tạo tài khoản để lưu hành trình và đặt những chuyến đi đáng nhớ.</p>
                </div>
                <div class="fade-up delay-4 d-flex align-items-center justify-content-between w-100">
                    <small class="opacity-75">Lịch trình hay bắt đầu từ một lựa chọn.</small>
                    <button type="button" class="btn btn-pill-toggle" id="signUpOverlayBtn">
                        Đăng ký ngay <i class="bi bi-arrow-right ms-1"></i>
                    </button>
                </div>
            </div>
        </div>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // 1. Sliding Panel Toggle Logic
    const authContainer = document.getElementById('authContainer');
    const signUpOverlayBtn = document.getElementById('signUpOverlayBtn');
    const signInOverlayBtn = document.getElementById('signInOverlayBtn');
    const toggleToRegister = document.getElementById('toggleToRegister');
    const toggleToLogin = document.getElementById('toggleToLogin');

    function switchToRegister(e) {
        if (e) e.preventDefault();
        authContainer.classList.add('right-panel-active');
        history.pushState(null, '', '${pageContext.request.contextPath}/register');
    }

    function switchToLogin(e) {
        if (e) e.preventDefault();
        authContainer.classList.remove('right-panel-active');
        history.pushState(null, '', '${pageContext.request.contextPath}/login');
    }

    if (signUpOverlayBtn) signUpOverlayBtn.addEventListener('click', switchToRegister);
    if (signInOverlayBtn) signInOverlayBtn.addEventListener('click', switchToLogin);
    if (toggleToRegister) toggleToRegister.addEventListener('click', switchToRegister);
    if (toggleToLogin) toggleToLogin.addEventListener('click', switchToLogin);

    // 2. Auto Crossfade Background Slider (Every 6.5s)
    const bgSlides = document.querySelectorAll('.bg-slide');
    let currentSlide = 0;

    if (bgSlides.length > 0) {
        setInterval(() => {
            bgSlides[currentSlide].classList.remove('active');
            currentSlide = (currentSlide + 1) % bgSlides.length;
            bgSlides[currentSlide].classList.add('active');
        }, 6500);
    }
</script>
</body>
</html>