<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <fmt:setLocale value="vi_VN" />

            <section id="tours" class="tab-section card mb-4">
                <div class="card-body p-4">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h2 class="h5 fw-bold mb-0"><i class="bi bi-map me-2 text-primary"></i> Quản lý danh sách Tour
                        </h2>
                        <button type="button" class="btn btn-primary" onclick="prepareAddTour()">
                            <i class="bi bi-plus-lg me-1"></i> + Thêm tour mới
                        </button>
                    </div>

                    <%-- Form Thêm / Sửa Tour --%>
                        <div id="tour-form" class="border rounded-3 p-4 mb-4 bg-light shadow-sm">
                            <div class="d-flex justify-content-between align-items-center mb-3">
                                <h3 class="h6 fw-bold text-primary mb-0" id="form-title">
                                    <i class="bi bi-pencil-square me-1"></i>
                                    <c:choose>
                                        <c:when test="${not empty editTour && editTour.id > 0}">Sửa thông tin Tour
                                            #${editTour.id}</c:when>
                                        <c:otherwise>Thêm tour mới vào hệ thống</c:otherwise>
                                    </c:choose>
                                </h3>
                                <c:if test="${not empty editTour && editTour.id > 0}">
                                    <span class="badge text-bg-warning">Đang chỉnh sửa ID #${editTour.id}</span>
                                </c:if>
                            </div>

                            <form action="admin" method="post" class="row g-3">
                                <input type="hidden" name="tab" value="tours">
                                <input type="hidden" name="action" value="save">
                                <input type="hidden" name="id" id="tour-id"
                                    value="${not empty editTour ? editTour.id : 0}">
                                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">

                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Tên tour <span
                                            class="text-danger">*</span></label>
                                    <input name="name" id="tour-name" value="${editTour.name}" class="form-control"
                                        required maxlength="200" placeholder="Nhập tên tour...">
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-semibold">Ngày khởi hành <span
                                            class="text-danger">*</span></label>
                                    <input type="date" name="startDate" id="tour-startDate"
                                        value="${editTour.startDate}" class="form-control" required>
                                </div>
                                <fmt:formatNumber value="${editTour.price}" pattern="#" maxFractionDigits="0" var="formattedPrice"/>
                                <fmt:formatNumber value="${editTour.originalPrice}" pattern="#" maxFractionDigits="0" var="formattedOrigPrice"/>
                                <div class="col-md-3">
                                    <label class="form-label fw-semibold">Giá bán (VNĐ) <span
                                            class="text-danger">*</span></label>
                                    <input type="number" name="price" id="tour-price" value="${not empty formattedPrice ? formattedPrice : ''}" min="0"
                                        step="1000" class="form-control" required placeholder="0">
                                </div>

                                <div class="col-md-3">
                                    <label class="form-label fw-semibold">Giá gốc (VNĐ)</label>
                                    <input type="number" name="originalPrice" id="tour-originalPrice"
                                        value="${not empty formattedOrigPrice ? formattedOrigPrice : ''}" min="0" step="1000" class="form-control"
                                        placeholder="0">
                                </div>
                                <fmt:formatDate value="${editTour.discountEndDate}" pattern="yyyy-MM-dd'T'HH:mm" var="formattedDiscountEndDate"/>
                                <div class="col-md-3">
                                    <label class="form-label fw-semibold">Hạn giảm giá (nếu có)</label>
                                    <input type="datetime-local" name="discountEndDate" id="tour-discountEndDate"
                                        value="${not empty formattedDiscountEndDate ? formattedDiscountEndDate : ''}" class="form-control">
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-semibold">Quốc gia <span class="text-danger">*</span></label>
                                    <select name="country" id="tour-country" class="form-select">
                                        <option value="Việt Nam" ${empty editTour || editTour.country == 'Việt Nam' ? 'selected' : ''}>🇻🇳 Việt Nam</option>
                                        <option value="Nhật Bản" ${editTour.country == 'Nhật Bản' ? 'selected' : ''}>🇯🇵 Nhật Bản</option>
                                        <option value="Hàn Quốc" ${editTour.country == 'Hàn Quốc' ? 'selected' : ''}>🇰🇷 Hàn Quốc</option>
                                        <option value="Trung Quốc" ${editTour.country == 'Trung Quốc' ? 'selected' : ''}>🇨🇳 Trung Quốc</option>
                                        <option value="Hoa Kỳ" ${editTour.country == 'Hoa Kỳ' ? 'selected' : ''}>🇺🇸 Hoa Kỳ</option>
                                        <option value="Ấn Độ" ${editTour.country == 'Ấn Độ' ? 'selected' : ''}>🇮🇳 Ấn Độ</option>
                                        <option value="Châu Âu" ${editTour.country == 'Châu Âu' ? 'selected' : ''}>🇪🇺 Châu Âu</option>
                                        <option value="Nước Úc" ${editTour.country == 'Nước Úc' ? 'selected' : ''}>🇦🇺 Nước Úc</option>
                                        <option value="Thái Lan" ${editTour.country == 'Thái Lan' ? 'selected' : ''}>🇹🇭 Thái Lan</option>
                                        <option value="Singapore & Malaysia" ${editTour.country == 'Singapore & Malaysia' ? 'selected' : ''}>🇸🇬 Singapore & Malaysia</option>
                                        <option value="Indonesia" ${editTour.country == 'Indonesia' ? 'selected' : ''}>🇮🇩 Indonesia</option>
                                    </select>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-semibold">Số chỗ còn lại <span
                                            class="text-danger">*</span></label>
                                    <input type="number" name="availableSeats" id="tour-availableSeats"
                                        value="${not empty editTour ? editTour.availableSeats : 20}" min="0"
                                        class="form-control" required>
                                </div>
                                <c:if test="${sessionScope.user.role == 'MANAGER'}">
                                    <div class="col-md-3">
                                        <label class="form-label fw-semibold">Trạng thái duyệt</label>
                                        <select name="status" id="tour-status" class="form-select">
                                            <option value="PENDING" ${editTour.status == 'PENDING' ? 'selected' : ''}>⏳ Chờ duyệt (PENDING)</option>
                                            <option value="APPROVED" ${empty editTour || editTour.status == 'APPROVED' ? 'selected' : ''}>✅ Đã duyệt (APPROVED)</option>
                                            <option value="REJECTED" ${editTour.status == 'REJECTED' ? 'selected' : ''}>❌ Từ chối (REJECTED)</option>
                                            <option value="IN_PROGRESS" ${editTour.status == 'IN_PROGRESS' ? 'selected' : ''}>✈️ Đang khởi hành (IN_PROGRESS)</option>
                                            <option value="COMPLETED" ${editTour.status == 'COMPLETED' ? 'selected' : ''}>🏁 Đã hoàn thành (COMPLETED)</option>
                                            <option value="INCIDENT" ${editTour.status == 'INCIDENT' ? 'selected' : ''}>⚠️ Sự cố (INCIDENT)</option>
                                        </select>
                                    </div>
                                </c:if>
                                <c:if test="${sessionScope.user.role != 'MANAGER'}">
                                    <input type="hidden" name="status" id="tour-status" value="${not empty editTour ? editTour.status : 'PENDING'}">
                                </c:if>
                                <div class="col-md-3">
                                    <label class="form-label fw-semibold">Thời lượng</label>
                                    <input name="duration" id="tour-duration" value="${editTour.duration}"
                                        placeholder="Ví dụ: 3 ngày 2 đêm" class="form-control">
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-semibold">Điểm đi</label>
                                    <input name="origin" id="tour-origin" value="${editTour.origin}"
                                        placeholder="Ví dụ: Hà Nội" class="form-control">
                                </div>

                                <div class="col-md-3">
                                    <label class="form-label fw-semibold">Điểm đến</label>
                                    <input name="destination" id="tour-destination" value="${editTour.destination}"
                                        placeholder="Ví dụ: Đà Nẵng" class="form-control">
                                </div>
                                <div class="col-md-9">
                                    <label class="form-label fw-semibold d-flex justify-content-between align-items-center">
                                        <span>URL hình ảnh (Link ảnh online)</span>
                                        <span class="text-secondary small">Hỗ trợ mọi link ảnh https/http/data:</span>
                                    </label>
                                    <div class="input-group mb-2">
                                        <span class="input-group-text bg-white"><i class="bi bi-image"></i></span>
                                        <input name="imageUrl" id="tour-imageUrl" value="${editTour.imageUrl}"
                                            placeholder="Dán link ảnh tại đây (vd: https://...)" class="form-control"
                                            oninput="updateTourImagePreview(this.value)"
                                            onpaste="setTimeout(() => updateTourImagePreview(document.getElementById('tour-imageUrl').value), 50)">
                                        <button type="button" class="btn btn-outline-secondary" onclick="document.getElementById('tour-imageUrl').value=''; updateTourImagePreview('');" title="Xóa link">
                                            <i class="bi bi-x-lg"></i>
                                        </button>
                                    </div>

                                    <%-- Hướng dẫn và chọn mẫu --%>
                                    <div class="d-flex align-items-center gap-1 flex-wrap mb-2">
                                        <span class="extra-small text-secondary me-1"><i class="bi bi-stars text-warning"></i> Chọn ảnh mẫu sẵn có:</span>
                                        <button type="button" class="btn btn-sm btn-outline-primary extra-small py-0 px-2 rounded-pill" onclick="setTourSampleImage('https://images.unsplash.com/photo-1570366583862-f91883984fde?auto=format&fit=crop&w=800&q=80')">🏔️ Sapa</button>
                                        <button type="button" class="btn btn-sm btn-outline-primary extra-small py-0 px-2 rounded-pill" onclick="setTourSampleImage('https://images.unsplash.com/photo-1528127269322-539801943592?auto=format&fit=crop&w=800&q=80')">⛵ Hạ Long</button>
                                        <button type="button" class="btn btn-sm btn-outline-primary extra-small py-0 px-2 rounded-pill" onclick="setTourSampleImage('https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?auto=format&fit=crop&w=800&q=80')">🌉 Đà Nẵng</button>
                                        <button type="button" class="btn btn-sm btn-outline-primary extra-small py-0 px-2 rounded-pill" onclick="setTourSampleImage('https://images.unsplash.com/photo-1583417319070-4a69db38a482?auto=format&fit=crop&w=800&q=80')">🏖️ Phú Quốc</button>
                                        <button type="button" class="btn btn-sm btn-outline-primary extra-small py-0 px-2 rounded-pill" onclick="setTourSampleImage('https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80')">🏞️ Thiên nhiên</button>
                                        <button type="button" class="btn btn-sm btn-outline-primary extra-small py-0 px-2 rounded-pill" onclick="setTourSampleImage('https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=800&q=80')">🏰 Hội An</button>
                                    </div>

                                    <div class="alert alert-info py-2 px-3 small mb-2 d-flex align-items-center gap-2">
                                        <i class="bi bi-lightbulb-fill text-warning fs-5"></i>
                                        <span><strong>Mẹo lấy link ảnh:</strong> Bạn mở Google Tìm kiếm ảnh &rarr; Nhấp <strong>chuột phải vào ảnh</strong> &rarr; Chọn <strong>"Sao chép địa chỉ hình ảnh"</strong> (Copy image address) rồi dán vào đây.</span>
                                    </div>

                                    <%-- Khung Xem Trước Ảnh Trực Tiếp --%>
                                    <div id="image-preview-container" class="p-3 bg-white border rounded-3 ${not empty editTour.imageUrl ? '' : 'd-none'}">
                                        <div class="d-flex align-items-start gap-3">
                                            <div class="position-relative" style="width: 120px; height: 80px; flex-shrink: 0;">
                                                <img id="tour-img-preview" 
                                                     src="${not empty editTour.imageUrl ? editTour.imageUrl : 'https://images.unsplash.com/photo-1570366583862-f91883984fde?auto=format&fit=crop&w=800&q=80'}" 
                                                     alt="Xem trước ảnh tour" 
                                                     referrerpolicy="no-referrer"
                                                     style="width: 100%; height: 100%; object-fit: cover; border-radius: 8px; border: 1px solid #cbd5e1;"
                                                     onload="onImagePreviewSuccess()"
                                                     onerror="onImagePreviewError(this)">
                                            </div>
                                            <div>
                                                <div id="image-preview-status" class="fw-semibold small text-success mb-1">
                                                    <i class="bi bi-check-circle-fill me-1"></i> Link ảnh hợp lệ (Xem trước thành công)
                                                </div>
                                                <small class="text-secondary d-block" id="image-preview-hint">Ảnh này sẽ xuất hiện trên trang chủ, danh sách tour và modal chi tiết.</small>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-12">
                                    <label class="form-label fw-semibold">Mô tả tour</label>
                                    <textarea name="description" id="tour-description" class="form-control" rows="3"
                                        placeholder="Mô tả ngắn về tour...">${editTour.description}</textarea>
                                </div>

                                <div class="col-12 d-flex gap-2">
                                    <button class="btn btn-primary" type="submit" id="submit-btn">
                                        <i class="bi bi-check-lg me-1"></i>
                                        <c:choose>
                                            <c:when test="${not empty editTour && editTour.id > 0}">Cập nhật tour
                                            </c:when>
                                            <c:otherwise>Lưu tour mới</c:otherwise>
                                        </c:choose>
                                    </button>
                                    <button type="button" class="btn btn-outline-secondary" onclick="prepareAddTour()">
                                        <i class="bi bi-x-lg me-1"></i> Tạo mới / Hủy sửa
                                    </button>
                                </div>
                            </form>
                        </div>

                        <%-- Thanh tìm kiếm tour --%>
                            <form method="get" action="admin#tours" class="row g-2 mb-3">
                                <div class="col-md-5">
                                    <input name="q" value="${keyword}" class="form-control"
                                        placeholder="Tìm kiếm theo tên tour...">
                                </div>
                                <div class="col-md-4">
                                    <select name="availability" class="form-select">
                                        <option value="">-- Tất cả trạng thái chỗ --</option>
                                        <option value="available" ${availability=='available' ? 'selected' : '' }>Còn
                                            chỗ (> 0)</option>
                                        <option value="soldout" ${availability=='soldout' ? 'selected' : '' }>Hết chỗ (=
                                            0)</option>
                                    </select>
                                </div>
                                <div class="col-md-3 d-flex gap-1">
                                    <button class="btn btn-secondary flex-grow-1" type="submit"><i
                                            class="bi bi-search"></i> Lọc</button>
                                    <a href="admin#tours" class="btn btn-outline-secondary"><i
                                            class="bi bi-arrow-clockwise"></i> Clear</a>
                                </div>
                            </form>

                            <%-- Bảng danh sách tour --%>
                                <div class="table-responsive">
                                    <table class="table table-hover align-middle mb-0">
                                        <thead class="table-light">
                                            <tr>
                                                <th>#</th>
                                                <th>Ảnh</th>
                                                <th>Tên tour</th>
                                                <th>Ngày KH</th>
                                                <th>Giá bán</th>
                                                <th>Số chỗ</th>
                                                <th class="text-center">Trạng thái</th>
                                                <th class="text-center">Thao tác</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="tour" items="${tours}">
                                                <tr>
                                                    <td class="fw-bold">${tour.id}</td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${not empty tour.imageUrl}">
                                                                <img src="${tour.imageUrl}" alt="${tour.name}"
                                                                    class="tour-img-thumb shadow-sm"
                                                                    referrerpolicy="no-referrer"
                                                                    onerror="this.onerror=null; this.src='https://images.unsplash.com/photo-1570366583862-f91883984fde?auto=format&fit=crop&w=400&q=80';">
                                                            </c:when>
                                                            <c:otherwise>
                                                                <img src="https://images.unsplash.com/photo-1570366583862-f91883984fde?auto=format&fit=crop&w=400&q=80" alt="Mặc định"
                                                                    class="tour-img-thumb opacity-75"
                                                                    referrerpolicy="no-referrer">
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <div class="fw-semibold">${tour.name}</div>
                                                        <div class="d-flex align-items-center gap-1 mt-1 flex-wrap">
                                                            <span class="badge bg-primary bg-opacity-10 text-primary border border-primary-subtle extra-small px-2 py-0"><i class="bi bi-globe-americas me-1"></i>${tour.country}</span>
                                                            <small class="text-secondary"><i class="bi bi-geo-alt"></i> ${tour.origin} &rarr; ${tour.destination}</small>
                                                        </div>
                                                    </td>
                                                    <td>${tour.startDate}</td>
                                                    <td>
                                                        <div class="fw-bold text-success">
                                                            <fmt:formatNumber value="${tour.price}" type="number" maxFractionDigits="0" /> VNĐ
                                                        </div>
                                                        <c:if test="${tour.originalPrice > tour.price}">
                                                            <div class="extra-small text-muted text-decoration-line-through">
                                                                <fmt:formatNumber value="${tour.originalPrice}" type="number" maxFractionDigits="0" /> VNĐ
                                                            </div>
                                                            <c:choose>
                                                                <c:when test="${tour.discountActive}">
                                                                    <span class="badge bg-danger extra-small py-0 px-1">Giảm ${tour.discountPercent}%</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge bg-secondary extra-small py-0 px-1">Hết hạn</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:if>
                                                    </td>
                                                    <td>
                                                        <span
                                                            class="badge ${tour.availableSeats > 0 ? 'text-bg-success' : 'text-bg-danger'}">
                                                            ${tour.availableSeats} chỗ
                                                        </span>
                                                    </td>
                                                    <td class="text-center">
                                                        <c:choose>
                                                            <c:when test="${tour.status == 'APPROVED'}">
                                                                <span class="badge bg-success-subtle text-success border border-success px-2 py-1"><i class="bi bi-check-circle-fill me-1"></i>Đã duyệt</span>
                                                            </c:when>
                                                            <c:when test="${tour.status == 'PENDING'}">
                                                                <span class="badge bg-warning text-dark px-2 py-1"><i class="bi bi-clock-history me-1"></i>Chờ duyệt</span>
                                                            </c:when>
                                                            <c:when test="${tour.status == 'REJECTED'}">
                                                                <span class="badge bg-danger-subtle text-danger border border-danger px-2 py-1" title="${tour.approvalNote}"><i class="bi bi-x-circle me-1"></i>Từ chối</span>
                                                            </c:when>
                                                            <c:when test="${tour.status == 'IN_PROGRESS'}">
                                                                <span class="badge bg-info-subtle text-info border border-info px-2 py-1"><i class="bi bi-airplane-engines me-1"></i>Đang chạy</span>
                                                            </c:when>
                                                            <c:when test="${tour.status == 'COMPLETED'}">
                                                                <span class="badge bg-secondary-subtle text-secondary border border-secondary px-2 py-1"><i class="bi bi-flag-fill me-1"></i>Hoàn thành</span>
                                                            </c:when>
                                                            <c:when test="${tour.status == 'INCIDENT'}">
                                                                <span class="badge bg-danger text-white px-2 py-1"><i class="bi bi-exclamation-triangle-fill me-1"></i>Sự cố</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-light text-dark border">${tour.status}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td class="text-center">
                                                        <div class="d-inline-flex gap-1 align-items-center">
                                                            <%-- Phê duyệt tour (Dành cho Quản lý) --%>
                                                            <c:if test="${tour.status == 'PENDING' && sessionScope.user.role == 'MANAGER'}">
                                                                <form method="post" action="admin" class="d-inline">
                                                                    <input type="hidden" name="tab" value="tours">
                                                                    <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                                    <input type="hidden" name="action" value="approveTour">
                                                                    <input type="hidden" name="id" value="${tour.id}">
                                                                    <button type="submit" class="btn btn-sm btn-success" title="Duyệt mở bán tour">
                                                                        <i class="bi bi-check-lg"></i> Duyệt
                                                                    </button>
                                                                </form>
                                                                <form method="post" action="admin" class="d-inline" onsubmit="var note=prompt('Lý do từ chối tour #${tour.id}:', 'Thông tin chưa đầy đủ'); if(!note) return false; this.note.value=note; return true;">
                                                                    <input type="hidden" name="tab" value="tours">
                                                                    <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                                    <input type="hidden" name="action" value="rejectTour">
                                                                    <input type="hidden" name="id" value="${tour.id}">
                                                                    <input type="hidden" name="note" value="">
                                                                    <button type="submit" class="btn btn-sm btn-outline-danger" title="Từ chối duyệt tour">
                                                                        <i class="bi bi-x-lg"></i>
                                                                    </button>
                                                                </form>
                                                            </c:if>

                                                            <a href="admin?edit=${tour.id}#tour-form"
                                                                class="btn btn-sm btn-outline-primary" title="Sửa tour">
                                                                <i class="bi bi-pencil-fill"></i>
                                                            </a>
                                                            <form method="post" action="admin" class="d-inline"
                                                                onsubmit="return confirm('Bạn có chắc chắn muốn xóa tour #${tour.id}?');">
                                                                <input type="hidden" name="tab" value="tours">
                                                                <input type="hidden" name="csrfToken"
                                                                    value="${sessionScope.csrfToken}">
                                                                <input type="hidden" name="action" value="delete">
                                                                <input type="hidden" name="id" value="${tour.id}">
                                                                <button type="submit"
                                                                    class="btn btn-sm btn-outline-danger"
                                                                    title="Xóa tour">
                                                                    <i class="bi bi-trash-fill"></i>
                                                                </button>
                                                            </form>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                            <c:if test="${empty tours}">
                                                <tr>
                                                    <td colspan="8" class="text-center text-secondary py-4">Không tìm
                                                        thấy tour nào.</td>
                                                </tr>
                                            </c:if>
                                        </tbody>
                                    </table>
                                </div>

                                 <%-- Phân trang chuẩn giao diện chuyên nghiệp --%>
                                 <c:if test="${totalPages > 1}">
                                     <nav class="mt-4 d-flex justify-content-between align-items-center flex-wrap gap-2">
                                         <small class="text-secondary fw-semibold">
                                             Hiển thị trang <strong>${page}</strong> / <strong>${totalPages}</strong>
                                         </small>
                                         
                                         <ul class="pagination pagination-sm mb-0 flex-wrap justify-content-center">
                                             <%-- Nút Trang Trước --%>
                                             <li class="page-item ${page <= 1 ? 'disabled' : ''}">
                                                 <a class="page-link" href="admin?page=${page - 1}&q=${keyword}&availability=${availability}#tours" aria-label="Trang trước">
                                                     <i class="bi bi-chevron-left"></i>
                                                 </a>
                                             </li>

                                             <%-- Trang đầu (1) --%>
                                             <li class="page-item ${page == 1 ? 'active' : ''}">
                                                 <a class="page-link" href="admin?page=1&q=${keyword}&availability=${availability}#tours">1</a>
                                             </li>

                                             <%-- Dấu ... bên trái nếu page > 4 --%>
                                             <c:if test="${page > 4}">
                                                 <li class="page-item disabled"><span class="page-link">...</span></li>
                                             </c:if>

                                             <%-- Các trang ở giữa quanh trang hiện tại --%>
                                             <c:forEach var="p" begin="2" end="${totalPages - 1}">
                                                 <c:if test="${p >= page - 2 && p <= page + 2}">
                                                     <li class="page-item ${p == page ? 'active' : ''}">
                                                         <a class="page-link" href="admin?page=${p}&q=${keyword}&availability=${availability}#tours">${p}</a>
                                                     </li>
                                                 </c:if>
                                             </c:forEach>

                                             <%-- Dấu ... bên phải nếu page < totalPages - 3 --%>
                                             <c:if test="${page < totalPages - 3}">
                                                 <li class="page-item disabled"><span class="page-link">...</span></li>
                                             </c:if>

                                             <%-- Trang cuối (totalPages) --%>
                                             <c:if test="${totalPages > 1}">
                                                 <li class="page-item ${page == totalPages ? 'active' : ''}">
                                                     <a class="page-link" href="admin?page=${totalPages}&q=${keyword}&availability=${availability}#tours">${totalPages}</a>
                                                 </li>
                                             </c:if>

                                             <%-- Nút Trang Sau --%>
                                             <li class="page-item ${page >= totalPages ? 'disabled' : ''}">
                                                 <a class="page-link" href="admin?page=${page + 1}&q=${keyword}&availability=${availability}#tours" aria-label="Trang sau">
                                                     <i class="bi bi-chevron-right"></i>
                                                 </a>
                                             </li>
                                         </ul>
                                     </nav>
                                 </c:if>
                </div>
            </section>