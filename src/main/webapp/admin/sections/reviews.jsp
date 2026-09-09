<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>

        <section id="reviews" class="tab-section card mb-4">
            <div class="card-body p-4">
                <h2 class="h5 fw-bold mb-3"><i class="bi bi-star me-2 text-primary"></i> Đánh giá & phản hồi từ khách
                    hàng</h2>
                <div class="table-responsive">
                    <table class="table align-middle">
                        <thead class="table-light">
                            <tr>
                                <th>Khách hàng</th>
                                <th>Tour</th>
                                <th>Sao</th>
                                <th>Nội dung</th>
                                <th>Trả lời & Duyệt</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="r" items="${reviews}">
                                <tr>
                                    <td>${r.customer}</td>
                                    <td>${r.tour}</td>
                                    <td class="text-warning fw-bold">${r.rating} <i class="bi bi-star-fill"></i></td>
                                    <td>${r.comment}</td>
                                    <td>
                                        <form method="post" action="admin" class="d-flex gap-2">
                                            <input type="hidden" name="tab" value="reviews">
                                            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                            <input type="hidden" name="action" value="review">
                                            <input type="hidden" name="id" value="${r.id}">
                                            <select name="visible" class="form-select form-select-sm"
                                                style="width:100px;">
                                                <option value="true" ${r.visible ? 'selected' : '' }>Hiện</option>
                                                <option value="false" ${not r.visible ? 'selected' : '' }>Ẩn</option>
                                            </select>
                                            <input name="reply" value="${r.reply}" class="form-control form-control-sm"
                                                placeholder="Trả lời...">
                                            <button class="btn btn-sm btn-primary">Lưu</button>
                                        </form>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty reviews}">
                                <tr>
                                    <td colspan="5" class="text-center text-secondary">Chưa có đánh giá nào.</td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </section>