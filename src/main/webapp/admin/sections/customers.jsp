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