<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<nav class="navbar top navbar-dark px-4 shadow-sm">
    <a class="navbar-brand fw-bold d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/admin">
        <i class="bi bi-shield-lock-fill text-warning"></i> TourBooking Admin
    </a>
    <div class="d-flex align-items-center gap-3 text-white">
        <!-- Multi-Language Switcher (i18n) -->
        <div class="btn-group btn-group-sm" role="group" aria-label="Language Selector">
            <button type="button" class="btn btn-outline-light btn-sm js-lang-btn" data-lang="vi" onclick="setLanguage('vi')" title="Tiếng Việt">
                🇻🇳 VN
            </button>
            <button type="button" class="btn btn-outline-light btn-sm js-lang-btn" data-lang="en" onclick="setLanguage('en')" title="English">
                🇬🇧 EN
            </button>
        </div>

        <span><i class="bi bi-person-circle me-1"></i> ${sessionScope.user.fullName}</span>
        <a href="${pageContext.request.contextPath}/tours" class="btn btn-outline-light btn-sm">
            <i class="bi bi-globe me-1"></i> <span data-i18n="nav.client">Trang khách</span>
        </a>
        <a href="${pageContext.request.contextPath}/login?action=logout" class="btn btn-outline-danger btn-sm text-white" title="Đăng xuất">
            <i class="bi bi-box-arrow-right"></i> <span data-i18n="nav.logout">Đăng xuất</span>
        </a>
    </div>
</nav>
<script src="${pageContext.request.contextPath}/assets/i18n.js"></script>