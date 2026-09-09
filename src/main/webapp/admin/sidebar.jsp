<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<aside class="side flex-shrink-0 shadow-sm">
    <div class="text-uppercase small text-secondary px-3 py-3 fw-bold tracking-wider d-none d-md-block">
        <c:choose>
            <c:when test="${sessionScope.user.role == 'ADMIN'}">Bảo trì & Kỹ thuật</c:when>
            <c:when test="${sessionScope.user.role == 'MANAGER'}">Quản lý Kinh doanh</c:when>
            <c:when test="${sessionScope.user.role == 'STAFF'}">Vận hành Tour</c:when>
            <c:otherwise>Bảng điều hành</c:otherwise>
        </c:choose>
    </div>

    <%-- MENU CHO QUẢN LÝ (MANAGER) --%>
    <c:if test="${sessionScope.user.role == 'MANAGER'}">
        <a href="#overview" data-tab="overview" onclick="switchTab(event, 'overview')"><i class="bi bi-graph-up-arrow text-success"></i> <span>Báo cáo doanh thu</span></a>
        <a href="#tours" data-tab="tours" onclick="switchTab(event, 'tours')"><i class="bi bi-check2-circle text-primary"></i> <span>Kiểm duyệt tour</span></a>
        <a href="#bookings" data-tab="bookings" onclick="switchTab(event, 'bookings')"><i class="bi bi-file-earmark-ruled text-info"></i> <span>Đơn & Hợp đồng</span></a>
        <a href="#refunds" data-tab="refunds" onclick="switchTab(event, 'refunds')"><i class="bi bi-arrow-counterclockwise text-warning"></i> <span>Xử lý Hoàn / Hủy</span></a>
        <a href="#incidents" data-tab="incidents" onclick="switchTab(event, 'incidents')"><i class="bi bi-exclamation-triangle-fill text-danger"></i> <span>Sự cố chuyến đi</span></a>
        <a href="#coupons" data-tab="coupons" onclick="switchTab(event, 'coupons')"><i class="bi bi-ticket-perforated-fill text-info"></i> <span>Mã giảm giá</span></a>
        <a href="#reviews" data-tab="reviews" onclick="switchTab(event, 'reviews')"><i class="bi bi-star-fill text-warning"></i> <span>Đánh giá</span></a>
    </c:if>

    <%-- MENU CHO NHÂN VIÊN VẬN HÀNH (STAFF) --%>
    <c:if test="${sessionScope.user.role == 'STAFF'}">
        <a href="#tours" data-tab="tours" onclick="switchTab(event, 'tours')"><i class="bi bi-pencil-square text-primary"></i> <span>Soạn thảo tour</span></a>
        <a href="#checkin" data-tab="checkin" onclick="switchTab(event, 'checkin')"><i class="bi bi-person-check-fill text-success"></i> <span>Điểm danh hành khách</span></a>
        <a href="#incidents" data-tab="incidents" onclick="switchTab(event, 'incidents')"><i class="bi bi-exclamation-triangle text-danger"></i> <span>Báo cáo sự cố</span></a>
    </c:if>

    <%-- MENU CHO QUẢN TRỊ VIÊN HỆ THỐNG (ADMIN) --%>
    <c:if test="${sessionScope.user.role == 'ADMIN'}">
        <a href="#customers" data-tab="customers" onclick="switchTab(event, 'customers')"><i class="bi bi-people-fill text-primary"></i> <span>Quản lý tài khoản</span></a>
        <a href="#login-history" data-tab="login-history" onclick="switchTab(event, 'login-history')"><i class="bi bi-shield-lock-fill text-warning"></i> <span>Nhật ký đăng nhập</span></a>
        <a href="#audit" data-tab="audit" onclick="switchTab(event, 'audit')"><i class="bi bi-clock-history text-info"></i> <span>Lịch sử chỉnh sửa</span></a>
        <a href="#ai-config" data-tab="ai-config" onclick="switchTab(event, 'ai-config')"><i class="bi bi-robot" style="color:#2dd4bf;"></i> <span>Trợ lý AI & API Key</span></a>
        <a href="#system-info" data-tab="system-info" onclick="switchTab(event, 'system-info')"><i class="bi bi-hdd-network text-secondary"></i> <span>Giám sát hệ thống</span></a>
    </c:if>
</aside>