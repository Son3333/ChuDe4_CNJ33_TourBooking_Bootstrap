<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<nav class="navbar navbar-expand-lg navbar-dark shadow-sm">
    <div class="container">
        <a class="navbar-brand fw-bold fs-4 d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/index.jsp">
            <i class="bi bi-compass-fill text-warning"></i> TourBooking
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navContent">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navContent">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0 ms-lg-4">
                <li class="nav-item"><a class="nav-link ${param.active == 'home' ? 'active' : ''}" href="${pageContext.request.contextPath}/index.jsp" data-i18n="nav.home">Trang chủ</a></li>
                <li class="nav-item"><a class="nav-link ${param.active == 'tours' ? 'active' : ''}" href="${pageContext.request.contextPath}/tours" data-i18n="nav.tours">Danh sách Tour</a></li>
            </ul>

            <div class="d-flex align-items-center gap-2">
                <!-- Multi-Language Switcher (i18n) -->
                <div class="btn-group btn-group-sm me-2" role="group" aria-label="Language Selector">
                    <button type="button" class="btn btn-outline-light btn-sm js-lang-btn" data-lang="vi" onclick="setLanguage('vi')" title="Tiếng Việt">
                        🇻🇳 VN
                    </button>
                    <button type="button" class="btn btn-outline-light btn-sm js-lang-btn" data-lang="en" onclick="setLanguage('en')" title="English">
                        🇬🇧 EN
                    </button>
                </div>

                <c:choose>
                    <c:when test="${not empty sessionScope.user}">
                        <span class="text-white me-2">Xin chào, <strong class="text-warning">${sessionScope.user.fullName}</strong></span>
                        <a href="${pageContext.request.contextPath}/user/bookings" class="btn btn-outline-light btn-sm nav-pill">
                            <i class="bi bi-ticket-perforated me-1"></i> <span data-i18n="nav.mybookings">Tour của tôi</span>
                        </a>
                        <c:if test="${sessionScope.user.role == 'ADMIN'}">
                            <a href="${pageContext.request.contextPath}/admin" class="btn btn-warning btn-sm nav-pill">
                                <i class="bi bi-speedometer2 me-1"></i> <span data-i18n="nav.admin">Quản trị</span>
                            </a>
                        </c:if>
                        <a href="${pageContext.request.contextPath}/login?action=logout" class="btn btn-danger btn-sm nav-pill" title="Đăng xuất">
                            <i class="bi bi-box-arrow-right"></i>
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-outline-light btn-sm nav-pill px-3" data-i18n="nav.login">Đăng nhập</a>
                        <a href="${pageContext.request.contextPath}/register" class="btn btn-accent btn-sm nav-pill px-3" data-i18n="nav.register">Đăng ký</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</nav>
<script src="${pageContext.request.contextPath}/assets/i18n.js"></script>