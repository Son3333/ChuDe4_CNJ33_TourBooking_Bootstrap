<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<nav class="navbar navbar-expand-lg top navbar-dark px-3 px-lg-4 shadow-sm">
    <div class="container-fluid p-0">
        <a class="navbar-brand fw-bold d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/admin">
            <i class="bi bi-shield-lock-fill text-warning"></i> TourBooking Admin
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#adminNavContent" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="adminNavContent">
            <div class="d-flex flex-column flex-lg-row align-items-lg-center gap-2 gap-lg-3 text-white ms-auto pt-3 pt-lg-0">
                <!-- Multi-Language Switcher (i18n) -->
                <div class="btn-group btn-group-sm align-self-start align-self-lg-center" role="group" aria-label="Language Selector">
                    <button type="button" class="btn btn-outline-light btn-sm js-lang-btn" data-lang="vi" onclick="setLanguage('vi')" title="Tiếng Việt">
                        🇻🇳 VN
                    </button>
                    <button type="button" class="btn btn-outline-light btn-sm js-lang-btn" data-lang="en" onclick="setLanguage('en')" title="English">
                        🇬🇧 EN
                    </button>
                </div>

                <span class="small text-white-50"><i class="bi bi-person-circle me-1 text-warning"></i> <strong class="text-white">${sessionScope.user.fullName}</strong></span>
                <div class="d-flex align-items-center gap-2">
                    <a href="${pageContext.request.contextPath}/tours" class="btn btn-outline-light btn-sm">
                        <i class="bi bi-globe me-1"></i> <span data-i18n="nav.client">Trang khách</span>
                    </a>
                    <a href="${pageContext.request.contextPath}/login?action=logout" class="btn btn-outline-danger btn-sm text-white" title="Đăng xuất">
                        <i class="bi bi-box-arrow-right"></i> <span data-i18n="nav.logout">Đăng xuất</span>
                    </a>
                </div>
            </div>
        </div>
    </div>
</nav>
<script src="${pageContext.request.contextPath}/assets/i18n.js"></script>