<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <fmt:setLocale value="vi_VN" />

            <section id="refunds" class="tab-section card mb-4">
                <div class="card-body p-4">
                    <h2 class="h5 fw-bold mb-3"><i class="bi bi-arrow-counterclockwise me-2 text-primary"></i> Yêu cầu
                        hủy & hoàn tiền</h2>
                    <div class="table-responsive">
                        <table class="table align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Mã đơn</th>
                                    <th>Trạng thái hoàn</th>
                                    <th>Số tiền hoàn</th>
                                    <th>Transaction ID</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:set var="hasRefunds" value="false" />
                                <c:forEach var="b" items="${bookings}">
                                    <c:if test="${b.status == 'CANCELLED' && not empty b.refundStatus}">
                                        <c:set var="hasRefunds" value="true" />
                                        <tr>
                                            <td class="fw-bold">#${b.id}</td>
                                            <td><span
                                                    class="badge ${b.refundStatus == 'COMPLETED' ? 'text-bg-success' : 'text-bg-warning'}">${b.refundStatus
                                                    == 'COMPLETED' ? 'Đã hoàn tất' : 'Chờ hoàn tiền'}</span></td>
                                            <td class="fw-bold text-danger">
                                                <fmt:formatNumber value="${b.total}" type="number"
                                                    maxFractionDigits="0" /> VNĐ
                                            </td>
                                            <td><code>${not empty b.refundTransactionId ? b.refundTransactionId : 'Chưa có'}</code></td>
                                            <td>
                                                <c:if test="${b.refundStatus != 'COMPLETED'}">
                                                    <form method="post" action="admin" class="d-flex gap-2">
                                                        <input type="hidden" name="tab" value="refunds">
                                                        <input type="hidden" name="csrfToken"
                                                            value="${sessionScope.csrfToken}">
                                                        <input type="hidden" name="action" value="refundComplete">
                                                        <input type="hidden" name="id" value="${b.id}">
                                                        <input name="transactionId" class="form-control form-control-sm"
                                                            placeholder="Mã giao dịch ngân hàng..." required>
                                                        <button class="btn btn-sm btn-warning fw-semibold">Xác nhận chuyển
                                                            khoản</button>
                                                    </form>
                                                </c:if>
                                                <c:if test="${b.refundStatus == 'COMPLETED'}">
                                                    <span class="text-success small fw-semibold"><i class="bi bi-check-circle-fill me-1"></i> Đã xử lý xong</span>
                                                </c:if>
                                            </td>
                                        </tr>
                                    </c:if>
                                </c:forEach>
                                <c:if test="${!hasRefunds}">
                                    <tr>
                                        <td colspan="5" class="text-center text-secondary py-4">Chưa có yêu cầu hoàn tiền nào.
                                        </td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>