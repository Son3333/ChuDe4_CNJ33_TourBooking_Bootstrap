<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<footer class="bg-dark text-white pt-5 pb-4 mt-5 border-top border-secondary">
    <div class="container">
        <div class="row g-4 mb-4">
            <!-- Cột 1: Thông tin thương hiệu -->
            <div class="col-lg-4 col-md-6">
                <a class="navbar-brand fw-bold fs-4 d-inline-flex align-items-center gap-2 text-white mb-3" href="${pageContext.request.contextPath}/index.jsp">
                    <i class="bi bi-compass-fill text-warning fs-3"></i> TourBooking
                </a>
                <p class="small text-secondary mb-3">
                    Hệ thống đặt tour du lịch trọn gói uy tín hàng đầu Việt Nam. Cam kết giá tốt nhất, dịch vụ chất lượng cao và đồng hành cùng quý khách trên mọi hành trình.
                </p>
                <div class="d-flex gap-2">
                    <a href="https://www.facebook.com/kasa.pro.666/?locale=vi_VN" target="_blank" rel="noopener noreferrer" class="btn btn-outline-light btn-sm rounded-circle" style="width:36px;height:36px;" title="Facebook"><i class="bi bi-facebook"></i></a>
                    <a href="#" class="btn btn-outline-light btn-sm rounded-circle" style="width:36px;height:36px;" title="Youtube"><i class="bi bi-youtube"></i></a>
                    <a href="#" class="btn btn-outline-light btn-sm rounded-circle" style="width:36px;height:36px;" title="Instagram"><i class="bi bi-instagram"></i></a>
                    <a href="#" class="btn btn-outline-light btn-sm rounded-circle" style="width:36px;height:36px;" title="TikTok"><i class="bi bi-tiktok"></i></a>
                </div>
            </div>

            <!-- Cột 2: Điểm đến nổi bật -->
            <div class="col-lg-2 col-md-6">
                <h6 class="fw-bold text-warning text-uppercase mb-3">Điểm đến HOT</h6>
                <ul class="list-unstyled small text-secondary mb-0 d-flex flex-column gap-2">
                    <li><a href="${pageContext.request.contextPath}/tours?q=Sapa" class="text-secondary text-decoration-none hover-white"><i class="bi bi-geo-alt me-1"></i> Sapa</a></li>
                    <li><a href="${pageContext.request.contextPath}/tours?q=Đà Nẵng" class="text-secondary text-decoration-none hover-white"><i class="bi bi-geo-alt me-1"></i> Đà Nẵng - Hội An</a></li>
                    <li><a href="${pageContext.request.contextPath}/tours?q=Phú Quốc" class="text-secondary text-decoration-none hover-white"><i class="bi bi-geo-alt me-1"></i> Phú Quốc</a></li>
                    <li><a href="${pageContext.request.contextPath}/tours?q=Nha Trang" class="text-secondary text-decoration-none hover-white"><i class="bi bi-geo-alt me-1"></i> Nha Trang</a></li>
                    <li><a href="${pageContext.request.contextPath}/tours?q=Hạ Long" class="text-secondary text-decoration-none hover-white"><i class="bi bi-geo-alt me-1"></i> Vịnh Hạ Long</a></li>
                </ul>
            </div>

            <!-- Cột 3: Hỗ trợ & Liên hệ -->
            <div class="col-lg-3 col-md-6">
                <h6 class="fw-bold text-warning text-uppercase mb-3">Tổng đài hỗ trợ 24/7</h6>
                <ul class="list-unstyled small text-secondary mb-0 d-flex flex-column gap-2">
                    <li><i class="bi bi-telephone-fill text-warning me-2"></i> Hotline: <strong class="text-white fs-6">1900 6868</strong></li>
                    <li><i class="bi bi-envelope-fill text-warning me-2"></i> Email: <a href="mailto:support@tourbooking.vn" class="text-secondary text-decoration-none">support@tourbooking.vn</a></li>
                    <li><i class="bi bi-geo-alt-fill text-warning me-2"></i> Trụ sở: Tòa nhà EAUT, Nam Từ Liêm, Hà Nội</li>
                    <li><i class="bi bi-clock-fill text-warning me-2"></i> Giờ làm việc: 08:00 - 21:00 hàng ngày</li>
                </ul>
            </div>

            <!-- Cột 4: Đăng ký nhận khuyến mãi -->
            <div class="col-lg-3 col-md-6">
                <h6 class="fw-bold text-warning text-uppercase mb-3">Đăng ký nhận ưu đãi</h6>
                <p class="small text-secondary mb-3">Nhập email để nhận mã giảm giá đến <strong>30%</strong> cho chuyến đi tiếp theo!</p>
                <form action="#" method="post" onsubmit="alert('Cảm ơn bạn đã đăng ký nhận bản tin ưu đãi!'); return false;">
                    <div class="input-group input-group-sm mb-3">
                        <input type="email" class="form-control" placeholder="Email của bạn..." required>
                        <button class="btn btn-warning fw-bold text-dark" type="submit">Gửi ngay</button>
                    </div>
                </form>
                <div class="d-flex align-items-center gap-2 mt-2">
                    <span class="badge bg-secondary p-2"><i class="bi bi-shield-check text-warning me-1"></i> Thanh toán an toàn</span>
                    <span class="badge bg-secondary p-2"><i class="bi bi-patch-check text-success me-1"></i> Giá tốt nhất</span>
                </div>
            </div>
        </div>

        <hr class="border-secondary my-4">

        <!-- Dòng bản quyền & logo thanh toán -->
        <div class="d-flex flex-column flex-md-row justify-content-between align-items-center gap-3 small text-secondary">
            <div>
                &copy; <%= java.time.Year.now().getValue() %> <strong>TourBooking System</strong>. Tất cả quyền được bảo lưu.
            </div>
            <div class="d-flex align-items-center gap-2">
                <span class="text-secondary">Đối tác thanh toán:</span>
                <span class="badge text-bg-light fw-bold text-primary"><i class="bi bi-credit-card me-1"></i> VietQR / Banking</span>
                <span class="badge text-bg-danger fw-bold"><i class="bi bi-qr-code me-1"></i> VNPay / Momo</span>
            </div>
        </div>
    </div>
</footer>

<!-- Mobile Responsive Bottom Navigation Bar (< 768px) -->
<style>
    @media (max-width: 768px) {
        body { padding-bottom: 65px; }
        .live-chat-root { bottom: 72px !important; }
        .admin-bubbles-container { bottom: 72px !important; }
        .chat-panel { bottom: 130px !important; max-height: calc(100vh - 150px) !important; }
    }
    .mobile-nav-item {
        color: #64748b;
        text-decoration: none;
        transition: color 0.15s;
    }
    .mobile-nav-item:hover, .mobile-nav-item.active {
        color: #2563eb;
    }
</style>
<nav class="mobile-bottom-nav d-md-none fixed-bottom bg-white border-top shadow-lg py-1 px-2 d-flex justify-content-around align-items-center" style="z-index: 2000; height: 58px;">
    <a href="${pageContext.request.contextPath}/index.jsp" class="mobile-nav-item text-center">
        <i class="bi bi-house-door fs-5 d-block lh-1 mb-1"></i>
        <span style="font-size: 0.68rem; font-weight: 600;">Trang chủ</span>
    </a>
    <a href="${pageContext.request.contextPath}/tours" class="mobile-nav-item text-center">
        <i class="bi bi-compass fs-5 d-block lh-1 mb-1"></i>
        <span style="font-size: 0.68rem; font-weight: 600;">Khám phá</span>
    </a>
    <button type="button" class="btn p-0 text-center border-0 bg-transparent" onclick="document.getElementById('userChatLauncher') ? document.getElementById('userChatLauncher').click() : window.location.href='${pageContext.request.contextPath}/tours'">
        <div class="rounded-circle d-flex align-items-center justify-content-center mx-auto shadow-sm" style="width: 40px; height: 40px; background: linear-gradient(135deg, #0d9488 0%, #0f766e 100%); color: #fff; margin-top: -16px; border: 3px solid #fff;">
            <i class="bi bi-robot fs-5"></i>
        </div>
        <span style="font-size: 0.68rem; font-weight: 700; color: #0d9488;">AI Tư vấn</span>
    </button>
    <a href="${pageContext.request.contextPath}/my-bookings" class="mobile-nav-item text-center">
        <i class="bi bi-ticket-perforated fs-5 d-block lh-1 mb-1"></i>
        <span style="font-size: 0.68rem; font-weight: 600;">Vé của tôi</span>
    </a>
    <c:choose>
        <c:when test="${not empty sessionScope.user && (sessionScope.user.role == 'ADMIN' || sessionScope.user.role == 'MANAGER' || sessionScope.user.role == 'STAFF')}">
            <a href="${pageContext.request.contextPath}/admin" class="mobile-nav-item text-center text-danger">
                <i class="bi bi-shield-lock-fill fs-5 d-block lh-1 mb-1"></i>
                <span style="font-size: 0.68rem; font-weight: 700;">Quản trị</span>
            </a>
        </c:when>
        <c:when test="${not empty sessionScope.user}">
            <a href="${pageContext.request.contextPath}/my-bookings" class="mobile-nav-item text-center">
                <i class="bi bi-person-circle fs-5 d-block lh-1 mb-1"></i>
                <span style="font-size: 0.68rem; font-weight: 600;">Tài khoản</span>
            </a>
        </c:when>
        <c:otherwise>
            <a href="${pageContext.request.contextPath}/login" class="mobile-nav-item text-center">
                <i class="bi bi-person fs-5 d-block lh-1 mb-1"></i>
                <span style="font-size: 0.68rem; font-weight: 600;">Đăng nhập</span>
            </a>
        </c:otherwise>
    </c:choose>
</nav>

<jsp:include page="/user/chat-widget.jsp" />
