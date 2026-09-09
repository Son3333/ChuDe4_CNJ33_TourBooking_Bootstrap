<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <fmt:setLocale value="vi_VN" />

            <section id="bookings" class="tab-section card mb-4">
                <div class="card-body p-4">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h2 class="h5 fw-bold mb-0"><i class="bi bi-ticket-detailed me-2 text-primary"></i> Quản lý đơn đặt tour</h2>
                        <div class="d-flex align-items-center gap-2">
                            <a href="admin?action=exportBookings" class="btn btn-sm btn-outline-success">
                                <i class="bi bi-file-earmark-spreadsheet me-1"></i> Xuất CSV
                            </a>
                            <span class="text-secondary small">100 đơn mới nhất</span>
                        </div>
                    </div>
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Mã đơn</th>
                                    <th>Khách hàng</th>
                                    <th>Tour</th>
                                    <th>Ngày đặt</th>
                                    <th>Tổng tiền</th>
                                    <th>Thanh toán</th>
                                    <th>Trạng thái</th>
                                    <th>Cập nhật</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="b" items="${bookings}">
                                    <tr>
                                        <td class="fw-bold">#${b.id}</td>
                                        <td>${b.customer}<br><small class="text-secondary">${b.username}</small></td>
                                        <td>${b.tour}</td>
                                        <td>${b.date}</td>
                                        <td>
                                            <fmt:formatNumber value="${b.total}" type="number" maxFractionDigits="0" />
                                            VNĐ
                                        </td>
                                        <td><span
                                                class="badge ${b.paymentStatus == 'PAID' ? 'text-bg-success' : 'text-bg-warning'}">${b.paymentStatus
                                                == 'PAID' ? 'Đã thanh toán' : 'Chờ thanh toán'}</span></td>
                                        <td><span
                                                class="badge ${b.status == 'CANCELLED' ? 'text-bg-danger' : b.status == 'COMPLETED' ? 'text-bg-primary' : 'text-bg-secondary'}">${b.status}</span>
                                        </td>
                                        <td>
                                            <form method="post" action="admin" class="d-flex gap-1">
                                                <input type="hidden" name="tab" value="bookings">
                                                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                <input type="hidden" name="action" value="bookingStatus">
                                                <input type="hidden" name="id" value="${b.id}">
                                                <select name="status" class="form-select form-select-sm">
                                                    <option value="PENDING" ${b.status=='PENDING' ? 'selected' : '' }>
                                                        Chờ xử lý</option>
                                                    <option value="CONFIRMED" ${b.status=='CONFIRMED' ? 'selected' : ''
                                                        }>Xác nhận</option>
                                                    <option value="COMPLETED" ${b.status=='COMPLETED' ? 'selected' : ''
                                                        }>Hoàn thành</option>
                                                    <option value="CANCELLED" ${b.status=='CANCELLED' ? 'selected' : ''
                                                        }>Hủy đơn</option>
                                                </select>
                                                <select name="paymentStatus" class="form-select form-select-sm">
                                                    <option value="PENDING" ${b.paymentStatus=='PENDING' ? 'selected'
                                                        : '' }>Chờ TT</option>
                                                    <option value="PAID" ${b.paymentStatus=='PAID' ? 'selected' : '' }>
                                                        Đã TT</option>
                                                </select>
                                                <button class="btn btn-sm btn-primary">Lưu</button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty bookings}">
                                    <tr>
                                        <td colspan="8" class="text-center text-secondary py-4">Chưa có đơn đặt tour
                                            nào.</td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>