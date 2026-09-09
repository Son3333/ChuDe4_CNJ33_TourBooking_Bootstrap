<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<section id="coupons" class="tab-section">
    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
        <div>
            <h2 class="h4 fw-bold mb-1"><i class="bi bi-ticket-perforated-fill text-danger me-2"></i> Quản Lý Mã Giảm Giá / Voucher</h2>
            <p class="text-secondary small mb-0">Tạo và quản lý các chương trình ưu đãi, mã khuyến mãi cho khách hàng khi đặt tour.</p>
        </div>
        <button type="button" class="btn btn-primary rounded-pill px-4 shadow-sm" data-bs-toggle="modal" data-bs-target="#createCouponModal">
            <i class="bi bi-plus-circle-fill me-1"></i> Tạo Mã Giảm Giá Mới
        </button>
    </div>

    <!-- Danh sách Voucher -->
    <div class="card border-0 shadow-sm rounded-4 overflow-hidden mb-4">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th>Mã Voucher</th>
                        <th>Phạm Vi Áp Dụng</th>
                        <th>Loại Giảm</th>
                        <th>Giá Trị Giảm</th>
                        <th>Đơn Tối Thiểu</th>
                        <th>Hạn Dùng</th>
                        <th>Lượt Dùng</th>
                        <th>Trạng Thái</th>
                        <th class="text-end">Hành Động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="c" items="${coupons}">
                        <tr>
                            <td>
                                <span class="badge text-bg-warning font-monospace fs-6 px-3 py-1 border border-warning">${c.code}</span>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${c.specificTour}">
                                        <span class="badge bg-info-subtle text-info-emphasis border border-info-subtle px-2 py-1" title="${c.applicableTourName}">
                                            <i class="bi bi-pin-map-fill me-1 text-danger"></i> Tour #${c.applicableTourId}
                                        </span>
                                        <small class="text-secondary d-block text-truncate" style="max-width: 140px;" title="${c.applicableTourName}">
                                            <c:out value="${c.applicableTourName}" />
                                        </small>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-primary-subtle text-primary border border-primary-subtle px-2 py-1">
                                            <i class="bi bi-globe me-1"></i> Tất cả các tour
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${c.discountType == 'PERCENT'}">
                                        <span class="badge text-bg-info text-dark">Theo Phần Trăm (%)</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge text-bg-success">Tiền Mặt Cố Định</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${c.discountType == 'PERCENT'}">
                                        <strong class="text-danger fs-6">${c.discountValue}%</strong>
                                        <c:if test="${c.maxDiscountAmount > 0}">
                                            <small class="text-secondary d-block">(Tối đa <fmt:formatNumber value="${c.maxDiscountAmount}" pattern="#"/> đ)</small>
                                        </c:if>
                                    </c:when>
                                    <c:otherwise>
                                        <strong class="text-danger fs-6"><fmt:formatNumber value="${c.discountValue}" pattern="#"/> VNĐ</strong>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <fmt:formatNumber value="${c.minOrderAmount}" pattern="#"/> VNĐ
                            </td>
                            <td>
                                <span class="badge text-bg-light border text-dark"><i class="bi bi-calendar-event me-1"></i> ${c.expiryDate}</span>
                            </td>
                            <td>
                                <div class="d-flex align-items-center gap-2">
                                    <div class="progress flex-grow-1" style="height: 6px; width: 60px;">
                                        <div class="progress-bar bg-primary" role="progressbar" style="width: ${(c.usedCount / c.maxUsage) * 100}%;"></div>
                                    </div>
                                    <small class="fw-bold">${c.usedCount}/${c.maxUsage}</small>
                                </div>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${c.active}">
                                        <span class="badge text-bg-success"><i class="bi bi-check-circle-fill me-1"></i> Đang áp dụng</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge text-bg-secondary"><i class="bi bi-pause-circle-fill me-1"></i> Tạm ngưng</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-end">
                                <form action="${pageContext.request.contextPath}/coupon" method="post" class="d-inline">
                                    <input type="hidden" name="action" value="toggle">
                                    <input type="hidden" name="id" value="${c.id}">
                                    <button type="submit" class="btn btn-sm ${c.active ? 'btn-outline-warning' : 'btn-outline-success'} rounded-pill me-1" title="${c.active ? 'Tạm ngưng' : 'Kích hoạt'}">
                                        <i class="bi ${c.active ? 'bi-pause-fill' : 'bi-play-fill'}"></i>
                                    </button>
                                </form>
                                <form action="${pageContext.request.contextPath}/coupon" method="post" class="d-inline" onsubmit="return confirm('Bạn có chắc chắn muốn xóa mã voucher này?');">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="${c.id}">
                                    <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill" title="Xóa">
                                        <i class="bi bi-trash"></i>
                                    </button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty coupons}">
                        <tr>
                            <td colspan="9" class="text-center text-secondary py-4">Chưa có mã giảm giá nào được tạo.</td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Modal Tạo Mã Giảm Giá Mới -->
    <div class="modal fade" id="createCouponModal" tabindex="-1" aria-labelledby="createCouponModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content rounded-4 border-0 shadow">
                <div class="modal-header bg-primary text-white">
                    <h5 class="modal-title fw-bold" id="createCouponModalLabel"><i class="bi bi-plus-circle me-2"></i> Tạo Mã Khuyến Mãi Mới</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Đóng"></button>
                </div>
                <form action="${pageContext.request.contextPath}/coupon" method="post">
                    <input type="hidden" name="action" value="create">
                    <div class="modal-body p-4">
                        <div class="mb-3">
                            <label class="form-label fw-bold">Mã Voucher (Code):</label>
                            <input type="text" name="code" class="form-control font-monospace fw-bold text-uppercase" placeholder="VD: HE2026, GIAM50K, TET2026" required maxlength="30">
                        </div>

                        <%-- Phạm vi áp dụng: Tất cả tour vs Tour đặc thù --%>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Phạm Vi Áp Dụng:</label>
                            <div class="d-flex gap-4 mb-2">
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="applicableScope" id="scopeAll" value="ALL" checked onchange="toggleTourScopeSelect()">
                                    <label class="form-check-label fw-semibold" for="scopeAll">
                                        <i class="bi bi-globe text-primary me-1"></i> Tất cả các tour
                                    </label>
                                </div>
                                <div class="form-check">
                                    <input class="form-check-input" type="radio" name="applicableScope" id="scopeSpecific" value="SPECIFIC" onchange="toggleTourScopeSelect()">
                                    <label class="form-check-label fw-semibold text-danger" for="scopeSpecific">
                                        <i class="bi bi-pin-map-fill me-1"></i> Tour cụ thể (Đặc thù)
                                    </label>
                                </div>
                            </div>
                            <div id="specificTourWrap" style="display: none;" class="p-2 bg-light rounded-3 border">
                                <label class="form-label small fw-bold text-dark mb-1">Chọn tour áp dụng:</label>
                                <select name="applicableTourId" id="applicableTourSelect" class="form-select">
                                    <option value="0">-- Chọn tour áp dụng đặc thù --</option>
                                    <c:forEach var="t" items="${tours}">
                                        <option value="${t.id}">#${t.id} - ${t.name} (${t.destination})</option>
                                    </c:forEach>
                                </select>
                                <small class="text-secondary d-block mt-1"><i class="bi bi-info-circle me-1"></i>Voucher chỉ có hiệu lực khi khách đặt tour đã chọn.</small>
                            </div>
                        </div>

                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Loại Giảm Giá:</label>
                                <select name="discountType" id="newCouponType" class="form-select">
                                    <option value="PERCENT">Theo Phần Trăm (%)</option>
                                    <option value="FIXED">Số Tiền Cố Định (VNĐ)</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Giá Trị Giảm:</label>
                                <input type="number" name="discountValue" class="form-control" placeholder="VD: 10 (%) hoặc 200000 (VNĐ)" required min="1" step="any">
                            </div>
                        </div>

                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Đơn Tối Thiểu (VNĐ):</label>
                                <input type="number" name="minOrderAmount" class="form-control" value="0" min="0" step="10000">
                            </div>
                            <div class="col-md-6" id="maxDiscountWrap">
                                <label class="form-label fw-bold">Giảm Tối Đa (VNĐ):</label>
                                <input type="number" name="maxDiscountAmount" class="form-control" value="0" min="0" step="10000" placeholder="0 = Không giới hạn">
                            </div>
                        </div>

                        <div class="row g-3 mb-3">
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Ngày Hết Hạn:</label>
                                <input type="date" name="expiryDate" class="form-control" required value="2026-12-31">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label fw-bold">Số Lượng Sử Dụng:</label>
                                <input type="number" name="maxUsage" class="form-control" value="100" min="1" required>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer bg-light p-3">
                        <button type="button" class="btn btn-outline-secondary rounded-pill px-4" data-bs-dismiss="modal">Hủy</button>
                        <button type="submit" class="btn btn-primary fw-bold rounded-pill px-4 shadow-sm">
                            <i class="bi bi-check-circle-fill me-1"></i> Lưu & Phát Hành
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</section>

<script>
    function toggleTourScopeSelect() {
        const isSpecific = document.getElementById('scopeSpecific').checked;
        const wrap = document.getElementById('specificTourWrap');
        if (wrap) {
            wrap.style.display = isSpecific ? 'block' : 'none';
        }
    }
</script>

