<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN" />

<div class="tab-section" id="checkin">
    <div class="card p-4 shadow-sm mb-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <div>
                <h2 class="h5 fw-bold mb-1"><i class="bi bi-person-check-fill text-success me-2"></i> Điểm Danh Khách Đi Tour Khởi Hành</h2>
                <p class="text-secondary small mb-0">Dành cho nhân viên điều hành & hướng dẫn viên điểm danh danh sách hành khách tại điểm đón xe / sân bay.</p>
            </div>
            <form method="get" action="${pageContext.request.contextPath}/admin" class="d-flex gap-2 align-items-center">
                <input type="hidden" name="tab" value="checkin">
                <label class="small text-muted text-nowrap">Chọn Tour:</label>
                <select name="checkinTourId" class="form-select form-select-sm" onchange="this.form.submit()">
                    <option value="">-- Chọn Tour cần điểm danh --</option>
                    <c:forEach var="t" items="${not empty allToursSimple ? allToursSimple : tours}">
                        <option value="${t.id}" ${checkinTourId == t.id || param.checkinTourId == t.id ? 'selected' : ''}>#${t.id} - ${t.name} (${t.startDate})</option>
                    </c:forEach>
                </select>
            </form>
        </div>

        <c:choose>
            <c:when test="${not empty checkinPassengers}">
                <div class="alert alert-primary py-2 d-flex justify-content-between align-items-center mb-3">
                    <span><i class="bi bi-info-circle-fill me-1"></i> Danh sách hành khách đã đặt tour và xác nhận thanh toán.</span>
                    <span class="badge text-bg-primary fs-6">${checkinPassengers.size()} Hành khách</span>
                </div>

                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-light">
                            <tr>
                                <th class="text-center" style="width: 40px;">STT</th>
                                <th>Họ và tên</th>
                                <th class="text-center">Giới tính</th>
                                <th class="text-center">Ngày sinh</th>
                                <th>CCCD / Hộ chiếu</th>
                                <th>Số điện thoại</th>
                                <th class="text-center">Mã đơn</th>
                                <th class="text-center">Trạng thái điểm danh</th>
                                <th class="text-center">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${checkinPassengers}" varStatus="status">
                                <tr class="${p.checkedIn ? 'table-success-subtle' : ''}">
                                    <td class="text-center">${status.index + 1}</td>
                                    <td><strong>${p.fullName}</strong></td>
                                    <td class="text-center">${p.gender}</td>
                                    <td class="text-center">${p.birthDate}</td>
                                    <td><span class="font-monospace small">${p.idCard}</span></td>
                                    <td>${p.phone}</td>
                                    <td class="text-center"><span class="badge text-bg-secondary">#BK-${p.bookingId}</span></td>
                                    <td class="text-center">
                                        <c:choose>
                                            <c:when test="${p.checkedIn}">
                                                <span class="badge text-bg-success px-2 py-1"><i class="bi bi-check-lg me-1"></i> Đã lên xe</span>
                                                <div class="extra-small text-muted" style="font-size: 0.7rem;"><fmt:formatDate value="${p.checkedInAt}" pattern="HH:mm dd/MM"/></div>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge text-bg-warning text-dark px-2 py-1">Chưa có mặt</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center">
                                        <form method="post" action="${pageContext.request.contextPath}/admin" class="d-inline">
                                            <input type="hidden" name="action" value="toggleCheckin">
                                            <input type="hidden" name="id" value="${p.id}">
                                            <input type="hidden" name="checkedIn" value="${!p.checkedIn}">
                                            <input type="hidden" name="tourId" value="${param.checkinTourId}">
                                            <input type="hidden" name="tab" value="checkin">
                                            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                            <button type="submit" class="btn btn-sm ${p.checkedIn ? 'btn-outline-danger' : 'btn-success'} rounded-pill px-3">
                                                <i class="bi ${p.checkedIn ? 'bi-x-lg' : 'bi-check-lg'} me-1"></i>
                                                ${p.checkedIn ? 'Hủy điểm danh' : 'Điểm danh'}
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:when>
            <c:otherwise>
                <div class="text-center py-5 text-muted">
                    <i class="bi bi-people display-4 text-secondary mb-3 d-block"></i>
                    <p class="mb-0">Vui lòng chọn một tour ở trên để xem và điểm danh danh sách hành khách.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>
