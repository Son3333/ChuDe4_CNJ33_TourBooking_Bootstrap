<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN" />

<div class="tab-section" id="incidents">
    <div class="card p-4 shadow-sm mb-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <div>
                <h2 class="h5 fw-bold mb-1"><i class="bi bi-exclamation-triangle-fill text-danger me-2"></i> Báo Cáo & Xử Lý Sự Cố Chuyến Đi</h2>
                <p class="text-secondary small mb-0">Quản lý và giải quyết các sự cố phát sinh trên tour thực tế (hỏng xe, thời tiết xấu, sự cố khách hàng).</p>
            </div>
            <button type="button" class="btn btn-sm btn-danger rounded-pill px-3" data-bs-toggle="modal" data-bs-target="#newIncidentModal">
                <i class="bi bi-plus-circle me-1"></i> Báo cáo sự cố mới
            </button>
        </div>

        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead class="table-light">
                    <tr>
                        <th>#</th>
                        <th>Tour ID</th>
                        <th>Loại sự cố</th>
                        <th>Mô tả chi tiết</th>
                        <th>Mức độ</th>
                        <th>Trạng thái</th>
                        <th>Người báo cáo</th>
                        <th>Phương án xử lý</th>
                        <th class="text-center">Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="inc" items="${incidents}" varStatus="status">
                        <tr>
                            <td>${status.index + 1}</td>
                            <td><span class="badge text-bg-secondary">Tour #${inc.tourId}</span></td>
                            <td><strong>${inc.incidentType}</strong></td>
                            <td><small class="text-secondary">${inc.description}</small></td>
                            <td>
                                <c:choose>
                                    <c:when test="${inc.severity == 'CRITICAL'}">
                                        <span class="badge text-bg-danger">Nghiêm trọng</span>
                                    </c:when>
                                    <c:when test="${inc.severity == 'HIGH'}">
                                        <span class="badge text-bg-warning text-dark">Cao</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge text-bg-info text-dark">Trung bình</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${inc.status == 'RESOLVED'}">
                                        <span class="badge text-bg-success"><i class="bi bi-check-circle me-1"></i> Đã xử lý</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge text-bg-warning text-dark"><i class="bi bi-clock me-1"></i> Đang xử lý</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td><small class="text-muted">${not empty inc.reporterName ? inc.reporterName : 'Nhân viên tour'}</small></td>
                            <td>
                                <small class="text-success">${not empty inc.resolution ? inc.resolution : 'Chưa có phương án'}</small>
                            </td>
                            <td class="text-center">
                                <c:if test="${inc.status != 'RESOLVED' && (sessionScope.user.role == 'MANAGER' || sessionScope.user.role == 'STAFF')}">
                                    <button type="button" class="btn btn-sm btn-outline-success rounded-pill px-3" data-bs-toggle="modal" data-bs-target="#resolveModal_${inc.id}">
                                        <i class="bi bi-check2"></i> Giải quyết
                                    </button>

                                    <!-- Modal Resolve Incident -->
                                    <div class="modal fade" id="resolveModal_${inc.id}" tabindex="-1">
                                        <div class="modal-dialog modal-dialog-centered">
                                            <form method="post" action="${pageContext.request.contextPath}/admin" class="modal-content">
                                                <input type="hidden" name="action" value="resolveIncident">
                                                <input type="hidden" name="id" value="${inc.id}">
                                                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                <div class="modal-header">
                                                    <h5 class="modal-title fw-bold">Xử lý sự cố Tour #${inc.tourId}</h5>
                                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                </div>
                                                <div class="modal-body text-start">
                                                    <div class="mb-3">
                                                        <label class="form-label small fw-bold">Phương án giải quyết & Đền bù:</label>
                                                        <textarea name="resolution" class="form-control" rows="3" required placeholder="Nhập biện pháp khắc phục (ví dụ: đã đổi xe, hỗ trợ voucher ăn uống,...)"></textarea>
                                                    </div>
                                                </div>
                                                <div class="modal-footer">
                                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                                                    <button type="submit" class="btn btn-success fw-bold">Xác nhận hoàn tất</button>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty incidents}">
                        <tr>
                            <td colspan="9" class="text-center text-muted py-4">Hiện không có sự cố nào được ghi nhận.</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Modal Báo Cáo Sự Cố Mới -->
<div class="modal fade" id="newIncidentModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <form method="post" action="${pageContext.request.contextPath}/admin" class="modal-content">
            <input type="hidden" name="action" value="reportIncident">
            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
            <div class="modal-header">
                <h5 class="modal-title fw-bold text-danger"><i class="bi bi-exclamation-triangle me-2"></i> Báo cáo sự cố chuyến đi mới</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label small fw-bold">Mã Tour (ID):</label>
                    <input type="number" name="tourId" class="form-control" required placeholder="Ví dụ: 12">
                </div>
                <div class="mb-3">
                    <label class="form-label small fw-bold">Loại sự cố:</label>
                    <select name="incidentType" class="form-select" required>
                        <option value="Trục trặc phương tiện vận chuyển">Trục trặc phương tiện vận chuyển</option>
                        <option value="Thời tiết bất lợi">Thời tiết bất lợi</option>
                        <option value="Sự cố khách sạn / Ăn uống">Sự cố khách sạn / Ăn uống</option>
                        <option value="Vấn đề sức khỏe hành khách">Vấn đề sức khỏe hành khách</option>
                        <option value="Khác">Khác</option>
                    </select>
                </div>
                <div class="mb-3">
                    <label class="form-label small fw-bold">Mức độ nghiêm trọng:</label>
                    <select name="severity" class="form-select">
                        <option value="LOW">Thấp (Chỉ chậm lịch trình nhẹ)</option>
                        <option value="MEDIUM" selected>Trung bình (Cần đổi xe hoặc hỗ trợ dịch vụ)</option>
                        <option value="HIGH">Cao (Ảnh hưởng chuyến bay / hành trình lớn)</option>
                        <option value="CRITICAL">Khẩn cấp (Cần hủy hoặc thay đổi toàn bộ tour)</option>
                    </select>
                </div>
                <div class="mb-3">
                    <label class="form-label small fw-bold">Mô tả sự cố:</label>
                    <textarea name="description" class="form-control" rows="3" required placeholder="Mô tả sự việc thực tế xảy ra tại điểm đến..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                <button type="submit" class="btn btn-danger fw-bold">Gửi báo cáo sự cố</button>
            </div>
        </form>
    </div>
</div>

