<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN" />

<div class="tab-section ${sessionScope.user.role == 'ADMIN' ? 'active' : ''}" id="login-history">
    <div class="card p-4 shadow-sm mb-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <div>
                <h2 class="h5 fw-bold mb-1"><i class="bi bi-shield-lock-fill text-warning me-2"></i> Nhật Ký Đăng Nhập & Giám Sát Truy Cập</h2>
                <p class="text-secondary small mb-0">Lưu vết mọi lượt đăng nhập vào hệ thống gồm địa chỉ IP, thiết bị, trình duyệt và kết quả.</p>
            </div>
            <span class="badge text-bg-warning text-dark px-3 py-2 fs-6">
                <i class="bi bi-shield-check me-1"></i> An ninh hệ thống
            </span>
        </div>

        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead class="table-light">
                    <tr>
                        <th>#</th>
                        <th>Tài khoản</th>
                        <th>Địa chỉ IP</th>
                        <th>Thiết bị / Trình duyệt</th>
                        <th>Thời gian</th>
                        <th>Trạng thái</th>
                        <th>Lý do thất bại</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="lh" items="${loginHistory}" varStatus="status">
                        <tr>
                            <td>${status.index + 1}</td>
                            <td><strong class="text-primary">${lh.username}</strong></td>
                            <td><span class="badge text-bg-light border font-monospace">${lh.ipAddress}</span></td>
                            <td><small class="text-secondary text-truncate d-inline-block" style="max-width: 250px;" title="${lh.deviceInfo}">${lh.deviceInfo}</small></td>
                            <td><small class="text-muted"><fmt:formatDate value="${lh.loginTime}" pattern="dd/MM/yyyy HH:mm:ss"/></small></td>
                            <td>
                                <c:choose>
                                    <c:when test="${lh.status == 'SUCCESS'}">
                                        <span class="badge text-bg-success px-2 py-1"><i class="bi bi-check-circle-fill me-1"></i> Thành công</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge text-bg-danger px-2 py-1"><i class="bi bi-x-circle-fill me-1"></i> Thất bại</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:if test="${not empty lh.failureReason}">
                                    <small class="text-danger">${lh.failureReason}</small>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty loginHistory}">
                        <tr>
                            <td colspan="7" class="text-center text-muted py-4">Chưa có bản ghi đăng nhập nào.</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

