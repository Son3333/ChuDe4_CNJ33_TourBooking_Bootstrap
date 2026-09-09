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

            <div class="d-flex flex-column flex-lg-row align-items-stretch align-items-lg-center gap-2 pt-3 pt-lg-0 mt-2 mt-lg-0 border-top border-secondary border-lg-0">
                <!-- Multi-Language Switcher (i18n) -->
                <div class="btn-group btn-group-sm align-self-start align-self-lg-center" role="group" aria-label="Language Selector">
                    <button type="button" class="btn btn-outline-light btn-sm js-lang-btn px-2 py-1" data-lang="vi" onclick="setLanguage('vi')" title="Tiếng Việt">
                        🇻🇳 VN
                    </button>
                    <button type="button" class="btn btn-outline-light btn-sm js-lang-btn px-2 py-1" data-lang="en" onclick="setLanguage('en')" title="English">
                        🇬🇧 EN
                    </button>
                </div>

                <c:choose>
                    <c:when test="${not empty sessionScope.user}">
                        <div class="d-flex align-items-center gap-2 flex-wrap">
                            <span class="text-white small">Xin chào, <strong class="text-warning">${sessionScope.user.fullName}</strong></span>
                            <div class="d-flex align-items-center gap-1 ms-auto ms-lg-0">
                                <a href="${pageContext.request.contextPath}/user/bookings" class="btn btn-outline-light btn-sm nav-pill">
                                    <i class="bi bi-ticket-perforated me-1"></i> <span data-i18n="nav.mybookings">Tour của tôi</span>
                                </a>
                                <c:if test="${sessionScope.user.role == 'ADMIN' || sessionScope.user.role == 'MANAGER' || sessionScope.user.role == 'STAFF'}">
                                    <a href="${pageContext.request.contextPath}/admin" class="btn btn-warning btn-sm nav-pill fw-bold">
                                        <i class="bi bi-speedometer2 me-1"></i> <span data-i18n="nav.admin">Quản trị</span>
                                    </a>
                                </c:if>
                                <a href="${pageContext.request.contextPath}/login?action=logout" class="btn btn-outline-danger btn-sm nav-pill" title="Đăng xuất">
                                    <i class="bi bi-box-arrow-right"></i>
                                </a>
                            </div>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="d-flex align-items-center gap-2 mt-2 mt-lg-0">
                            <a href="${pageContext.request.contextPath}/login" class="btn btn-outline-light btn-sm nav-pill px-3 flex-fill text-center" data-i18n="nav.login">Đăng nhập</a>
                            <a href="${pageContext.request.contextPath}/register" class="btn btn-accent btn-sm nav-pill px-3 flex-fill text-center" data-i18n="nav.register">Đăng ký</a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</nav>
<script src="${pageContext.request.contextPath}/assets/i18n.js"></script>