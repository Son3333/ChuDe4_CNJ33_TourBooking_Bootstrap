<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <fmt:setLocale value="vi_VN" />
<%
    vn.edu.eaut.tour.model.User currentUser = (vn.edu.eaut.tour.model.User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    if (!currentUser.isAdmin() && !currentUser.isManager() && !currentUser.isStaff()) {
        response.sendRedirect(request.getContextPath() + "/tours");
        return;
    }
    if (request.getAttribute("tours") == null) {
        response.sendRedirect(request.getContextPath() + "/admin");
        return;
    }
%>
            <!doctype html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Trang quản trị | Tour Booking</title>
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
                <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css"
                    rel="stylesheet">
                <style>
                    body {
                        background: #f5f7fb;
                        color: #17202a;
                        font-family: system-ui, -apple-system, sans-serif;
                    }

                    .top {
                        background: #172554;
                    }

                    .side {
                        width: 240px;
                        min-height: calc(100vh - 56px);
                        background: #0f172a;
                        position: sticky;
                        top: 0;
                    }

                    .side a {
                        display: flex;
                        align-items: center;
                        gap: 10px;
                        color: #cbd5e1;
                        text-decoration: none;
                        padding: 12px 20px;
                        transition: all 0.2s;
                        font-size: 0.95rem;
                    }

                    .side a:hover,
                    .side a.active {
                        background: #1e3a8a;
                        color: #fff;
                    }

                    .main {
                        min-width: 0;
                    }

                    .card {
                        border: 0;
                        box-shadow: 0 6px 20px rgba(15, 23, 42, 0.07);
                        border-radius: 12px;
                    }

                    .metric {
                        border-left: 4px solid #3b82f6;
                    }

                    .metric strong {
                        font-size: 1.45rem;
                        color: #172554;
                    }

                    .section-title {
                        scroll-margin-top: 20px;
                    }

                    .tour-img-thumb {
                        width: 60px;
                        height: 45px;
                        object-fit: cover;
                        border-radius: 6px;
                    }

                    .tab-section {
                        display: none !important;
                    }

                    .tab-section.active {
                        display: block !important;
                    }

                    .tab-section.row.active {
                        display: flex !important;
                    }

                    @media(max-width: 768px) {
                        .layout {
                            display: block !important;
                        }

                        .side {
                            width: 100%;
                            min-height: auto;
                            position: static;
                        }

                        .side a {
                            display: inline-flex;
                            padding: 8px 12px;
                        }
                    }
                </style>
            </head>

            <body>
                <jsp:include page="/admin/navbar.jsp" />

                <div class="layout d-flex">
                    <jsp:include page="/admin/sidebar.jsp" />

                    <main class="main flex-grow-1 p-4 p-lg-5">
                        <div class="d-flex justify-content-between align-items-start mb-4">
                            <div>
                                <p class="text-uppercase small text-primary fw-bold mb-1">Bảng điều hành Hệ thống</p>
                                <h1 class="h3 fw-bold mb-1">Quản lý & Vận hành Tour</h1>
                                <p class="text-secondary mb-0">Theo dõi doanh thu, tour, booking và khách hàng ở một nơi.</p>
                            </div>
                            <span class="badge ${currentUser.admin ? 'text-bg-danger' : (currentUser.manager ? 'text-bg-primary' : 'text-bg-success')} fs-6 px-3 py-2">${currentUser.role}</span>
                        </div>

                        <%-- Thông báo phản hồi --%>
                        <c:if test="${not empty sessionScope.success}">
                            <div class="alert alert-success alert-dismissible fade show shadow-sm" role="alert">
                                <i class="bi bi-check-circle-fill me-2"></i> ${sessionScope.success}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                            <c:remove var="success" scope="session" />
                        </c:if>
                        <c:if test="${not empty sessionScope.error}">
                            <div class="alert alert-danger alert-dismissible fade show shadow-sm" role="alert">
                                <i class="bi bi-exclamation-triangle-fill me-2"></i> ${sessionScope.error}
                                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
                            </div>
                            <c:remove var="error" scope="session" />
                        </c:if>

                        <!-- Modular Admin Sections -->
                        <jsp:include page="/admin/sections/overview.jsp" />
                        <jsp:include page="/admin/sections/tours.jsp" />
                        <jsp:include page="/admin/sections/bookings.jsp" />
                        <jsp:include page="/admin/sections/refunds.jsp" />
                        <jsp:include page="/admin/sections/coupons.jsp" />
                        <jsp:include page="/admin/sections/customers.jsp" />
                        <jsp:include page="/admin/sections/reviews.jsp" />
                        <jsp:include page="/admin/sections/audit.jsp" />
                        <jsp:include page="/admin/sections/login-history.jsp" />
                        <jsp:include page="/admin/sections/system-info.jsp" />
                        <jsp:include page="/admin/sections/incidents.jsp" />
                        <jsp:include page="/admin/sections/checkin.jsp" />
                        <jsp:include page="/admin/sections/ai-config.jsp" />
                    </main>
                </div>

                <jsp:include page="/user/chat-widget.jsp" />
                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
                <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
                <script>
                    function switchTab(event, tabId) {
                        if (event) {
                            event.preventDefault();
                        }
                        if (!tabId) return;

                        // 1. Hide all tab sections
                        const sections = document.querySelectorAll('.tab-section');
                        sections.forEach(sec => sec.classList.remove('active'));

                        // 2. Show target tab section
                        const targetSection = document.getElementById(tabId);
                        if (targetSection) {
                            targetSection.classList.add('active');
                        }

                        // 3. Update sidebar active state
                        const sidebarLinks = document.querySelectorAll('.side a[data-tab]');
                        sidebarLinks.forEach(link => {
                            if (link.getAttribute('data-tab') === tabId) {
                                link.classList.add('active');
                            } else {
                                link.classList.remove('active');
                            }
                        });

                        // 4. Update hash in address bar without scrolling
                        if (history.pushState) {
                            history.pushState(null, null, '#' + tabId);
                        } else {
                            window.location.hash = tabId;
                        }

                        // 5. If switching to overview, trigger chart resize
                        if (tabId === 'overview' && window.myRevenueChart) {
                            window.myRevenueChart.resize();
                        }
                    }

                    function initAdminCharts() {
                        const revCanvas = document.getElementById('revenueMonthlyChart');
                        if (revCanvas) {
                            const ctx = revCanvas.getContext('2d');
                            const revenueData = [
                                <c:forEach var="i" begin="1" end="12">
                                    ${not empty monthlyRevenue[i] ? monthlyRevenue[i] : 0}${i < 12 ? ',' : ''}
                                </c:forEach>
                            ];
                            window.myRevenueChart = new Chart(ctx, {
                                type: 'bar',
                                data: {
                                    labels: ['T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9', 'T10', 'T11', 'T12'],
                                    datasets: [{
                                        label: 'Doanh thu (VNĐ)',
                                        data: revenueData,
                                        backgroundColor: 'rgba(37, 99, 235, 0.75)',
                                        borderColor: 'rgb(37, 99, 235)',
                                        borderWidth: 1.5,
                                        borderRadius: 6
                                    }]
                                },
                                options: {
                                    responsive: true,
                                    maintainAspectRatio: false,
                                    plugins: {
                                        legend: { display: false },
                                        tooltip: {
                                            callbacks: {
                                                label: function(context) {
                                                    return new Intl.NumberFormat('vi-VN').format(context.raw) + ' VNĐ';
                                                }
                                            }
                                        }
                                    },
                                    scales: {
                                        y: {
                                            beginAtZero: true,
                                            ticks: {
                                                callback: function(val) {
                                                    if (val >= 1000000) return (val / 1000000) + 'M';
                                                    return val;
                                                }
                                            }
                                        }
                                    }
                                }
                            });
                        }

                        const orderCanvas = document.getElementById('orderStatusChart');
                        if (orderCanvas) {
                            const ctx2 = orderCanvas.getContext('2d');
                            const confirmed = ${not empty statusCounts['CONFIRMED'] ? statusCounts['CONFIRMED'] : 0};
                            const pending = ${not empty statusCounts['PENDING'] ? statusCounts['PENDING'] : 0};
                            const cancelled = ${not empty statusCounts['CANCELLED'] ? statusCounts['CANCELLED'] : 0};

                            new Chart(ctx2, {
                                type: 'doughnut',
                                data: {
                                    labels: ['Đã xác nhận', 'Chờ xử lý', 'Đã hủy'],
                                    datasets: [{
                                        data: [confirmed, pending, cancelled],
                                        backgroundColor: ['#10b981', '#f59e0b', '#ef4444'],
                                        hoverOffset: 4
                                    }]
                                },
                                options: {
                                    responsive: true,
                                    maintainAspectRatio: false,
                                    plugins: {
                                        legend: {
                                            position: 'bottom',
                                            labels: { boxWidth: 12, padding: 10 }
                                        }
                                    }
                                }
                            });
                        }
                    }

                    function prepareAddTour() {
                        const formTitle = document.getElementById('form-title');
                        if (formTitle) formTitle.innerHTML = '<i class="bi bi-plus-circle me-1"></i> Thêm tour mới vào hệ thống';
                        const tourId = document.getElementById('tour-id');
                        if (tourId) tourId.value = '0';
                        const name = document.getElementById('tour-name');
                        if (name) name.value = '';
                        const startDate = document.getElementById('tour-startDate');
                        if (startDate) startDate.value = '';
                        const price = document.getElementById('tour-price');
                        if (price) price.value = '';
                        const originalPrice = document.getElementById('tour-originalPrice');
                        if (originalPrice) originalPrice.value = '';
                        const discountEndDate = document.getElementById('tour-discountEndDate');
                        if (discountEndDate) discountEndDate.value = '';
                        const country = document.getElementById('tour-country');
                        if (country) country.value = 'Việt Nam';
                        const seats = document.getElementById('tour-availableSeats');
                        if (seats) seats.value = '20';
                        const duration = document.getElementById('tour-duration');
                        if (duration) duration.value = '3 ngày 2 đêm';
                        const origin = document.getElementById('tour-origin');
                        if (origin) origin.value = 'Hà Nội';
                        const destination = document.getElementById('tour-destination');
                        if (destination) destination.value = '';
                        const imageUrl = document.getElementById('tour-imageUrl');
                        if (imageUrl) imageUrl.value = '';
                        const description = document.getElementById('tour-description');
                        if (description) description.value = '';
                        const submitBtn = document.getElementById('submit-btn');
                        if (submitBtn) submitBtn.innerHTML = '<i class="bi bi-check-lg me-1"></i> Lưu tour mới';

                        updateTourImagePreview('');

                        const tourFormElem = document.getElementById('tour-form');
                        if (tourFormElem) {
                            tourFormElem.scrollIntoView({ behavior: 'smooth' });
                        }
                        if (name) name.focus();
                    }

                    function updateTourImagePreview(url) {
                        const container = document.getElementById('image-preview-container');
                        const img = document.getElementById('tour-img-preview');
                        const status = document.getElementById('image-preview-status');
                        if (!container || !img) return;

                        if (!url || url.trim() === '') {
                            container.classList.add('d-none');
                            return;
                        }
                        container.classList.remove('d-none');
                        img.src = url.trim();
                        if (status) {
                            status.className = 'fw-semibold small text-info mb-1';
                            status.innerHTML = '<span class="spinner-border spinner-border-sm me-1" role="status"></span> Đang tải ảnh...';
                        }
                    }

                    function onImagePreviewSuccess() {
                        const status = document.getElementById('image-preview-status');
                        if (status) {
                            status.className = 'fw-semibold small text-success mb-1';
                            status.innerHTML = '<i class="bi bi-check-circle-fill me-1"></i> Link ảnh hợp lệ (Xem trước thành công)';
                        }
                    }

                    function onImagePreviewError(img) {
                        const status = document.getElementById('image-preview-status');
                        if (status) {
                            status.className = 'fw-semibold small text-danger mb-1';
                            status.innerHTML = '<i class="bi bi-exclamation-circle-fill me-1"></i> Không thể tải ảnh (Kiểm tra lại link)';
                        }
                    }

                    function setTourSampleImage(url) {
                        const input = document.getElementById('tour-imageUrl');
                        if (input) {
                            input.value = url;
                            updateTourImagePreview(url);
                        }
                    }

                    function toggleDiscountInputs() {
                        const select = document.getElementById('newCouponType');
                        const wrap = document.getElementById('maxDiscountWrap');
                        if (!select || !wrap) return;
                        if (select.value === 'PERCENT') {
                            wrap.style.display = 'block';
                        } else {
                            wrap.style.display = 'none';
                        }
                    }

                    document.addEventListener('DOMContentLoaded', function() {
                        let defaultTab = '${currentUser.admin ? "customers" : (currentUser.staff ? "tours" : "overview")}';
                        let activeTab = defaultTab;
                        const hash = window.location.hash.replace('#', '');
                        const hasEditTour = ${not empty editTour && editTour.id > 0};

                        if (hasEditTour) {
                            activeTab = 'tours';
                        } else if (hash && document.getElementById(hash)) {
                            activeTab = hash;
                        }
                        switchTab(null, activeTab);

                        initAdminCharts();
                    });
                </script>
            </body>

            </html>