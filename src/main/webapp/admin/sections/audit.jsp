<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN" />

<section id="audit" class="tab-section card mb-4">
    <div class="card-body p-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <div>
                <h2 class="h5 fw-bold mb-1"><i class="bi bi-clock-history me-2 text-primary"></i> Lịch Sử Chỉnh Sửa & Truy Vết Hệ Thống (Audit Logs)</h2>
                <p class="text-secondary small mb-0">Truy vết chi tiết mọi thay đổi dữ liệu (Trạng thái cũ &rarr; mới, giá vé, tour, tài khoản) phục vụ điều tra truy vấn an ninh.</p>
            </div>
            <span class="badge text-bg-primary px-3 py-2 fs-6">100 bản ghi mới nhất</span>
        </div>
        <div class="table-responsive">
            <table class="table table-hover align-middle small mb-0">
                <thead class="table-light">
                    <tr>
                        <th># ID</th>
                        <th>Thời gian</th>
                        <th>Người thực hiện</th>
                        <th>Vai trò</th>
                        <th>Đối tượng tác động</th>
                        <th>Hành động</th>
                        <th>Lịch sử thay đổi (Cũ &rarr; Mới)</th>
                        <th>Địa chỉ IP</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="log" items="${auditLogs}">
                        <tr>
                            <td class="fw-bold">#${log.id}</td>
                            <td><small class="text-muted"><fmt:formatDate value="${log.createdAt}" pattern="dd/MM/yyyy HH:mm:ss"/></small></td>
                            <td>
                                <strong>${not empty log.username ? log.username : 'Hệ thống'}</strong>
                            </td>
                            <td>
                                <span class="badge ${log.userRole == 'ADMIN' ? 'text-bg-danger' : log.userRole == 'MANAGER' ? 'text-bg-warning text-dark' : log.userRole == 'STAFF' ? 'text-bg-info text-dark' : 'text-bg-secondary'}">
                                    ${not empty log.userRole ? log.userRole : 'SYSTEM'}
                                </span>
                            </td>
                            <td>
                                <span class="badge text-bg-light border font-monospace">${not empty log.targetTable ? log.targetTable : 'bookings'}:#${log.targetId > 0 ? log.targetId : log.bookingId}</span>
                            </td>
                            <td><span class="fw-bold text-primary">${log.action}</span></td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty log.oldValue || not empty log.newValue}">
                                        <div class="d-flex align-items-center gap-2">
                                            <span class="badge text-bg-danger-subtle text-danger border border-danger-subtle px-2 py-1">${not empty log.oldValue ? log.oldValue : '(Trống)'}</span>
                                            <i class="bi bi-arrow-right text-muted"></i>
                                            <span class="badge text-bg-success-subtle text-success border border-success-subtle px-2 py-1">${not empty log.newValue ? log.newValue : '(Trống)'}</span>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <code class="text-dark bg-light px-2 py-1 rounded">${log.newStatus}</code>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td><span class="badge text-bg-light border font-monospace">${log.ipAddress}</span></td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty auditLogs}">
                        <tr>
                            <td colspan="8" class="text-center text-secondary py-4">Chưa có nhật ký hoạt động nào.</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</section>