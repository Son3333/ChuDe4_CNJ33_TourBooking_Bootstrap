<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN" />

<section id="overview" class="tab-section ${sessionScope.user.role == 'MANAGER' ? 'active' : ''}">
    <c:choose>
        <c:when test="${sessionScope.user.role == 'ADMIN'}">
            <div class="card p-5 border-0 shadow-sm rounded-4 text-center">
                <div class="mb-3">
                    <i class="bi bi-shield-slash-fill text-danger display-3"></i>
                </div>
                <h4 class="fw-bold text-danger mb-2">QUY ĐỊNH BẢO MẬT VÀ BÍ MẬT KINH DOANH</h4>
                <p class="text-secondary mx-auto mb-4" style="max-width: 650px;">
                    Theo nguyên tắc phân quyền và bảo mật dữ liệu doanh nghiệp: <strong>Quản trị viên kỹ thuật (ADMIN)</strong> chỉ phụ trách về bảo trì máy chủ, quản lý tài khoản, nhật ký đăng nhập và lịch sử audit logs hệ thống. Admin <strong>KHÔNG ĐƯỢC PHÉP</strong> xem báo cáo tài chính, doanh thu bán hàng hoặc can thiệp thương mại.
                </p>
                <div class="d-flex justify-content-center gap-3">
                    <button class="btn btn-outline-primary rounded-pill px-4" onclick="switchTab(null, 'customers')">
                        <i class="bi bi-people-fill me-1"></i> Quản lý tài khoản
                    </button>
                    <button class="btn btn-outline-warning rounded-pill px-4 text-dark" onclick="switchTab(null, 'login-history')">
                        <i class="bi bi-shield-lock-fill me-1"></i> Nhật ký đăng nhập
                    </button>
                    <button class="btn btn-outline-secondary rounded-pill px-4" onclick="switchTab(null, 'audit')">
                        <i class="bi bi-clock-history me-1"></i> Lịch sử chỉnh sửa
                    </button>
                </div>
            </div>
        </c:when>

        <c:otherwise>
            <!-- BẢNG ĐIỀU HÀNH KINH DOANH CHO QUẢN LÝ (MANAGER) -->
            <div class="row g-3 mb-4">
                <div class="col-sm-6 col-xl-3">
                    <div class="card metric p-3">
                        <small class="text-secondary">Doanh thu tháng này</small>
                        <strong><fmt:formatNumber value="${stats.revenue}" type="number" maxFractionDigits="0"/> VNĐ</strong>
                    </div>
                </div>
                <div class="col-sm-6 col-xl-3">
                    <div class="card metric p-3" style="border-left-color: #10b981;">
                        <small class="text-secondary">Tour đang mở bán</small>
                        <strong>${stats.runningTours}</strong>
                    </div>
                </div>
                <div class="col-sm-6 col-xl-3">
                    <div class="card metric p-3" style="border-left-color: #f59e0b;">
                        <small class="text-secondary">Đơn chờ xử lý</small>
                        <strong>${stats.pendingBookings}</strong>
                    </div>
                </div>
                <div class="col-sm-6 col-xl-3">
                    <div class="card metric p-3" style="border-left-color: #ef4444;">
                        <small class="text-secondary">Tỷ lệ hủy tour</small>
                        <strong>${stats.cancelRate}%</strong>
                    </div>
                </div>
            </div>

            <!-- Thống Kê Theo Mùa & Loại Tour -->
            <div class="row g-3 mb-4">
                <div class="col-md-6">
                    <div class="card p-3 shadow-sm border-0 rounded-4">
                        <h6 class="fw-bold text-primary mb-2"><i class="bi bi-sun-fill text-warning me-2"></i> Doanh Thu Theo Mùa Du Lịch</h6>
                        <div class="row text-center g-2 pt-1">
                            <div class="col-3 border-end">
                                <small class="text-muted d-block">Mùa Xuân</small>
                                <strong class="text-success small"><fmt:formatNumber value="${seasonStats.springRev}" type="number" maxFractionDigits="0"/>đ</strong>
                            </div>
                            <div class="col-3 border-end">
                                <small class="text-muted d-block">Mùa Hè (Peak)</small>
                                <strong class="text-danger small"><fmt:formatNumber value="${seasonStats.summerRev}" type="number" maxFractionDigits="0"/>đ</strong>
                            </div>
                            <div class="col-3 border-end">
                                <small class="text-muted d-block">Mùa Thu</small>
                                <strong class="text-primary small"><fmt:formatNumber value="${seasonStats.autumnRev}" type="number" maxFractionDigits="0"/>đ</strong>
                            </div>
                            <div class="col-3">
                                <small class="text-muted d-block">Mùa Đông</small>
                                <strong class="text-info small"><fmt:formatNumber value="${seasonStats.winterRev}" type="number" maxFractionDigits="0"/>đ</strong>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-6">
                    <div class="card p-3 shadow-sm border-0 rounded-4">
                        <h6 class="fw-bold text-primary mb-2"><i class="bi bi-clock-history me-2"></i> Xu Hướng Thời Lượng Chuyến Đi</h6>
                        <div class="row text-center g-2 pt-1">
                            <div class="col-4 border-end">
                                <small class="text-muted d-block">Ngắn ngày (2-3N)</small>
                                <strong class="text-dark fs-6">${seasonStats.shortTrips} lượt đặt</strong>
                            </div>
                            <div class="col-4 border-end">
                                <small class="text-muted d-block">Trung bình (4-5N)</small>
                                <strong class="text-dark fs-6">${seasonStats.midTrips} lượt đặt</strong>
                            </div>
                            <div class="col-4">
                                <small class="text-muted d-block">Dài ngày (6-7N)</small>
                                <strong class="text-dark fs-6">${seasonStats.longTrips} lượt đặt</strong>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Biểu Đồ Thống Kê Doanh Thu & Đơn Hàng (Chart.js) -->
            <div class="row g-4 mb-4">
                <div class="col-lg-8">
                    <div class="card p-4 h-100 shadow-sm border-0 rounded-4">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <div>
                                <h6 class="fw-bold mb-0 text-primary"><i class="bi bi-graph-up-arrow me-2"></i> Biểu Đồ Doanh Thu Theo Tháng (Năm 2026)</h6>
                                <small class="text-secondary">Thống kê tổng doanh thu từ các đơn đặt tour đã xác nhận và hoàn tất</small>
                            </div>
                            <span class="badge text-bg-success px-3 py-2 rounded-pill">Doanh thu VNĐ</span>
                        </div>
                        <div style="height: 280px; position: relative;">
                            <canvas id="revenueMonthlyChart"></canvas>
                        </div>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="card p-4 h-100 shadow-sm border-0 rounded-4">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <div>
                                <h6 class="fw-bold mb-0 text-primary"><i class="bi bi-pie-chart-fill me-2"></i> Tỷ Lệ Đơn Hàng</h6>
                                <small class="text-secondary">Phân bổ theo trạng thái</small>
                            </div>
                        </div>
                        <div style="height: 240px; position: relative;" class="d-flex justify-content-center align-items-center">
                            <canvas id="orderStatusChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row g-4">
                <div class="col-lg-6">
                    <div class="card p-4 h-100">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h6 class="fw-bold mb-0 text-primary"><i class="bi bi-clock-history me-1"></i> Đơn đặt tour mới nhất</h6>
                            <button class="btn btn-link btn-sm p-0 text-decoration-none" onclick="switchTab(null, 'bookings')">Xem tất cả &rarr;</button>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle small mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th>Mã đơn</th>
                                        <th>Khách hàng</th>
                                        <th>Tổng tiền</th>
                                        <th>Trạng thái</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="b" items="${bookings}" end="4">
                                        <tr>
                                            <td class="fw-bold">#${b.id}</td>
                                            <td>${b.customer}</td>
                                            <td class="fw-semibold text-success"><fmt:formatNumber value="${b.total}" type="number" maxFractionDigits="0"/> VNĐ</td>
                                            <td><span class="badge ${b.status == 'CANCELLED' ? 'text-bg-danger' : b.status == 'COMPLETED' ? 'text-bg-primary' : 'text-bg-secondary'}">${b.status}</span></td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty bookings}">
                                        <tr><td colspan="4" class="text-center text-secondary py-3">Chưa có đơn đặt tour nào.</td></tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6">
                    <div class="card p-4 h-100">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h6 class="fw-bold mb-0 text-primary"><i class="bi bi-map me-1"></i> Top Tour Bán Chạy Nhất</h6>
                            <button class="btn btn-link btn-sm p-0 text-decoration-none" onclick="switchTab(null, 'tours')">Quản lý tour &rarr;</button>
                        </div>
                        <div class="table-responsive">
                            <table class="table table-hover align-middle small mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th>Tên tour</th>
                                        <th class="text-center">Số lượt đặt</th>
                                        <th class="text-end">Doanh thu</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="item" items="${topSellingTours}" end="4">
                                        <tr>
                                            <td class="fw-semibold text-truncate" style="max-width: 200px;" title="${item.name}">${item.name}</td>
                                            <td class="text-center"><span class="badge text-bg-primary">${item.totalBooked}</span></td>
                                            <td class="text-end fw-bold text-success"><fmt:formatNumber value="${item.totalRevenue}" type="number" maxFractionDigits="0"/> VNĐ</td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty topSellingTours}">
                                        <tr><td colspan="3" class="text-center text-secondary py-3">Chưa có dữ liệu bán tour.</td></tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</section>