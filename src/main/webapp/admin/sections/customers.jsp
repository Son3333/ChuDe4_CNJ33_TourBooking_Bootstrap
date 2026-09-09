<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <fmt:setLocale value="vi_VN" />

            <section id="customers" class="tab-section card mb-4">
                <div class="card-body p-4">
                    <h2 class="h5 fw-bold mb-3"><i class="bi bi-people me-2 text-primary"></i> Quản lý tài khoản khách
                        hàng</h2>
                    <div class="table-responsive">
                        <table class="table align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Họ tên</th>
                                    <th>Tài khoản</th>
                                    <th>Vai trò</th>
                                    <th>Số đơn</th>
                                    <th>Tổng chi tiêu</th>
                                    <th>Trạng thái</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="u" items="${users}">
                                    <tr>
                                        <td class="fw-semibold">${u.name}</td>
                                        <td>${u.username}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${sessionScope.user.admin && u.role != 'ADMIN'}">
                                                    <form method="post" action="admin" class="d-inline">
                                                        <input type="hidden" name="tab" value="customers">
                                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                        <input type="hidden" name="action" value="updateRole">
                                                        <input type="hidden" name="id" value="${u.id}">
                                                        <select name="role" class="form-select form-select-sm d-inline-block w-auto py-0 px-2 fw-semibold" onchange="this.form.submit()" style="font-size: 0.82rem;">
                                                            <option value="USER" ${u.role == 'USER' ? 'selected' : ''}>USER (Khách)</option>
                                                            <option value="STAFF" ${u.role == 'STAFF' ? 'selected' : ''}>STAFF (Nhân viên)</option>
                                                            <option value="MANAGER" ${u.role == 'MANAGER' ? 'selected' : ''}>MANAGER (Quản lý)</option>
                                                        </select>
                                                    </form>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge ${u.role == 'ADMIN' ? 'bg-danger' : (u.role == 'MANAGER' ? 'bg-warning text-dark' : (u.role == 'STAFF' ? 'bg-info text-dark' : 'bg-secondary'))}">
                                                        ${u.role}
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>${u.bookings}</td>
                                        <td>
                                            <fmt:formatNumber value="${u.spent}" type="number" maxFractionDigits="0" />
                                            VNĐ
                                        </td>
                                        <td><span
                                                class="badge ${u.blocked ? 'text-bg-danger' : 'text-bg-success'}">${u.blocked
                                                ? 'Đã khóa' : 'Hoạt động'}</span></td>
                                        <td>
                                            <c:if test="${u.role != 'ADMIN'}">
                                                <form method="post" action="admin">
                                                    <input type="hidden" name="tab" value="customers">
                                                    <input type="hidden" name="csrfToken"
                                                        value="${sessionScope.csrfToken}">
                                                    <input type="hidden" name="action" value="toggleUser">
                                                    <input type="hidden" name="id" value="${u.id}">
                                                    <button
                                                        class="btn btn-sm ${u.blocked ? 'btn-outline-success' : 'btn-outline-danger'}">
                                                        ${u.blocked ? 'Mở khóa' : 'Khóa tài khoản'}
                                                    </button>
                                                </form>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>