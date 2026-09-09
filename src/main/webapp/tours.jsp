<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN" />
<%
    if (request.getAttribute("tours") == null) {
        response.sendRedirect(request.getContextPath() + "/tours");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Danh sách Tour | TourBooking</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root {
            --navy: #17324d;
            --orange: #e76f3c;
            --orange-hover: #c9552b;
            --bg-gray: #f7f8f5;
        }

        body {
            background-color: var(--bg-gray);
            color: #17202a;
            font-family: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
            padding-bottom: 70px; /* Space for mobile sticky bottom bar */
        }

        .navbar {
            background: var(--navy);
        }

        /* Hero Subheader */
        .sub-hero {
            background: linear-gradient(120deg, var(--navy), #2b5968);
            color: white;
            padding: 3rem 0;
            border-radius: 0 0 24px 24px;
        }

        .sub-hero h1 {
            font-family: Georgia, serif;
            font-weight: 700;
        }

        /* Tour Cards Grid */
        .tour-card {
            border: none;
            border-radius: 16px;
            overflow: hidden;
            background: white;
            box-shadow: 0 10px 30px rgba(23, 50, 77, 0.08);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            height: 100%;
            display: flex;
            flex-direction: column;
        }

        .tour-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 18px 40px rgba(23, 50, 77, 0.16);
        }

        .card-img-wrapper {
            position: relative;
            height: 220px;
            overflow: hidden;
            background: #e2e8f0;
        }

        .card-img-wrapper img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.5s ease;
        }

        .tour-card:hover .card-img-wrapper img {
            transform: scale(1.08);
        }

        .tour-badge {
            position: absolute;
            top: 14px;
            left: 14px;
            z-index: 2;
            padding: 0.35rem 0.75rem;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 700;
        }

        .tour-discount-badge {
            position: absolute;
            top: 14px;
            right: 14px;
            z-index: 2;
            padding: 0.35rem 0.75rem;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 700;
            background: linear-gradient(135deg, #ff416c 0%, #ff4b2b 100%);
            color: #fff;
            box-shadow: 0 4px 10px rgba(255, 65, 108, 0.4);
            animation: pulse-badge 2s infinite;
        }

        @keyframes pulse-badge {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.05); }
        }

        .price-tag {
            color: var(--orange);
            font-size: 1.35rem;
            font-weight: 800;
        }

        .btn-accent {
            background: var(--orange);
            border-color: var(--orange);
            color: white;
            font-weight: 700;
            border-radius: 10px;
            transition: all 0.3s ease;
        }

        .btn-accent.btn-sm {
            padding: 0.25rem 0.5rem;
        }

        .btn-accent:hover {
            background: var(--orange-hover);
            border-color: var(--orange-hover);
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 6px 18px rgba(231, 111, 60, 0.35);
        }

        /* Modal 7:3 Split Detail Layout */
        .modal-tour-detail .modal-dialog {
            max-width: 1100px;
        }

        .bg-gradient-navy {
            background: linear-gradient(135deg, var(--navy) 0%, #0f2338 100%);
        }

        .bg-gradient-dark {
            background: linear-gradient(to top, rgba(0, 0, 0, 0.85) 0%, rgba(0, 0, 0, 0) 100%);
        }

        .backdrop-blur {
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
        }

        .extra-small {
            font-size: 0.75rem;
        }

        .feature-chip {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 0.75rem 0.5rem;
            transition: all 0.25s ease;
        }

        .feature-chip:hover {
            border-color: var(--orange);
            background: #fff7f3;
            transform: translateY(-2px);
        }

        .sticky-booking-box {
            position: sticky;
            top: 20px;
            background: white;
            border-radius: 16px;
            padding: 1.5rem;
            border: 1px solid #e2e8f0;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
        }

        .accordion-button:not(.collapsed) {
            background-color: #fff7f3;
            color: var(--orange);
            font-weight: 700;
        }

        /* Mobile Sticky Bottom Bar */
        .mobile-sticky-bar {
            position: fixed;
            bottom: 0;
            left: 0;
            right: 0;
            background: white;
            padding: 0.85rem 1.25rem;
            box-shadow: 0 -8px 25px rgba(0, 0, 0, 0.12);
            z-index: 1050;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        @media (min-width: 769px) {
            .mobile-sticky-bar {
                display: none;
            }
        }

        .tour-detail-modal {
            display: none;
            position: fixed;
            inset: 0;
            z-index: 2000;
            overflow-y: auto;
            padding: 1rem;
            background: rgba(15, 23, 42, 0.62);
        }

        .tour-detail-modal.is-open { display: block; }
        .tour-detail-modal .modal-dialog {
            width: min(1100px, calc(100vw - 2rem));
            max-width: 1100px;
            margin: 2rem auto;
        }
        .tour-detail-modal .modal-content {
            display: flex;
            flex-direction: column;
            max-height: calc(100vh - 4rem);
            overflow: hidden;
        }
        .tour-detail-modal .modal-body {
            overflow-y: auto;
            background: #fff;
        }
        .tour-detail-modal .sticky-booking-box { position: static; }
    </style>
</head>
<body>

<!-- Navbar -->
<jsp:include page="/user/navbar.jsp">
    <jsp:param name="active" value="tours" />
</jsp:include>

<!-- Sub Hero Header -->
<header class="sub-hero mb-4">
    <div class="container">
        <p class="text-uppercase small fw-bold text-warning mb-1">Hành trình trải nghiệm</p>
        <h1 class="h2 mb-2">Khám Phá Danh Sách Tour Du Lịch</h1>
        <p class="opacity-80 mb-0">Lịch trình trọn gói, giá tốt và dịch vụ hàng đầu.</p>
    </div>
</header>

<!-- Filter / Search Bar -->
<div class="container mb-3">
    <div class="card border-0 shadow-sm rounded-4 p-3 bg-white">
        <form action="${pageContext.request.contextPath}/tours" method="get" class="row g-2 align-items-center">
            <div class="col-lg-3 col-md-6">
                <div class="input-group">
                    <span class="input-group-text bg-light border-end-0"><i class="bi bi-search text-secondary"></i></span>
                    <input type="text" name="q" value="${q}" class="form-control border-start-0 bg-light" placeholder="Tìm tên tour...">
                </div>
            </div>
            <div class="col-lg-2 col-md-6">
                <div class="input-group">
                    <span class="input-group-text bg-light border-end-0"><i class="bi bi-globe-americas text-primary"></i></span>
                    <select name="country" class="form-select border-start-0 bg-light" onchange="this.form.submit()">
                        <option value="">-- Tất cả quốc gia --</option>
                        <c:forEach var="c" items="${countries}">
                            <option value="${c}" ${country == c ? 'selected' : ''}>${c}</option>
                        </c:forEach>
                    </select>
                </div>
            </div>
            <div class="col-lg-2 col-md-4">
                <div class="input-group">
                    <span class="input-group-text bg-light border-end-0"><i class="bi bi-geo-alt text-secondary"></i></span>
                    <input type="text" name="origin" value="${origin}" class="form-control border-start-0 bg-light" placeholder="Điểm đi...">
                </div>
            </div>
            <div class="col-lg-2 col-md-4">
                <select name="duration" class="form-select bg-light">
                    <option value="">-- Thời lượng --</option>
                    <option value="3 ngày 2 đêm" ${duration == '3 ngày 2 đêm' ? 'selected' : ''}>3 ngày 2 đêm</option>
                    <option value="4 ngày 3 đêm" ${duration == '4 ngày 3 đêm' ? 'selected' : ''}>4 ngày 3 đêm</option>
                    <option value="5 ngày 4 đêm" ${duration == '5 ngày 4 đêm' ? 'selected' : ''}>5 ngày 4 đêm</option>
                    <option value="6 ngày 5 đêm" ${duration == '6 ngày 5 đêm' ? 'selected' : ''}>6 ngày 5 đêm</option>
                    <option value="7 ngày 6 đêm" ${duration == '7 ngày 6 đêm' ? 'selected' : ''}>7 ngày 6 đêm</option>
                    <option value="8 ngày 7 đêm" ${duration == '8 ngày 7 đêm' ? 'selected' : ''}>8 ngày 7 đêm</option>
                    <option value="10 ngày 9 đêm" ${duration == '10 ngày 9 đêm' ? 'selected' : ''}>10 ngày 9 đêm</option>
                </select>
            </div>
            <div class="col-lg-2 col-md-4">
                <div class="d-flex flex-column">
                    <div class="d-flex justify-content-between extra-small text-secondary mb-1">
                        <span>Giá tối đa:</span>
                        <strong id="priceDisplay" class="text-danger fw-bold"><fmt:formatNumber value="${maxPrice != null ? maxPrice : 100000000}" type="number" maxFractionDigits="0"/> đ</strong>
                    </div>
                    <input type="range" name="maxPrice" class="form-range" id="priceRange" min="1000000" max="100000000" step="1000000" value="${maxPrice != null ? maxPrice : 100000000}" oninput="updatePriceFilter(this.value)">
                </div>
            </div>
            <div class="col-lg-1 col-md-12 d-flex gap-1">
                <button type="submit" class="btn btn-accent flex-grow-1" title="Lọc kết quả"><i class="bi bi-funnel-fill"></i> Lọc</button>
                <a href="${pageContext.request.contextPath}/tours" class="btn btn-outline-secondary" title="Đặt lại bộ lọc"><i class="bi bi-arrow-clockwise"></i></a>
            </div>
        </form>
    </div>
</div>

<!-- Main Tour Grid -->
<main class="container mb-5">
    <div class="row g-4">
        <c:if test="${empty tours}">
            <div class="col-12 text-center py-5">
                <i class="bi bi-search fs-1 text-secondary mb-3 d-block"></i>
                <h4 class="fw-bold text-secondary">Không tìm thấy tour nào</h4>
                <p class="text-secondary small mb-3">Vui lòng thử lại với từ khóa hoặc điểm đến khác.</p>
                <a href="${pageContext.request.contextPath}/tours" class="btn btn-outline-primary rounded-pill px-4">Xem tất cả tour</a>
            </div>
        </c:if>
        <div id="noPriceMatchAlert" class="col-12 text-center py-5" style="display: none;">
            <i class="bi bi-cash-coin fs-1 text-warning mb-3 d-block"></i>
            <h4 class="fw-bold text-dark">Không có tour nào dưới mức giá này</h4>
            <p class="text-secondary small mb-3">Vui lòng kéo thanh trượt sang phải để tăng mức giá tối đa hoặc chọn mức giá khác.</p>
            <button type="button" class="btn btn-outline-primary rounded-pill px-4" onclick="resetPriceFilter()">Hiện tất cả mức giá (100 Triệu VNĐ)</button>
        </div>
        <c:forEach var="tour" items="${tours}">
            <div class="col-lg-4 col-md-6">
                <div class="tour-card">
                    <div class="card-img-wrapper">
                        <c:choose>
                            <c:when test="${tour.availableSeats <= 3 && tour.availableSeats > 0}">
                                <span class="badge text-bg-warning tour-badge text-dark"><i class="bi bi-exclamation-circle-fill me-1"></i> Chỉ còn ${tour.availableSeats} chỗ</span>
                            </c:when>
                            <c:when test="${tour.availableSeats == 0}">
                                <span class="badge text-bg-danger tour-badge"><i class="bi bi-x-circle-fill me-1"></i> Đã hết chỗ</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge text-bg-success tour-badge"><i class="bi bi-check-circle-fill me-1"></i> Đang mở bán</span>
                            </c:otherwise>
                        </c:choose>

                        <c:if test="${tour.discountActive}">
                            <span class="tour-discount-badge"><i class="bi bi-fire me-1"></i> -${tour.discountPercent}%</span>
                        </c:if>

                        <c:choose>
                            <c:when test="${not empty tour.imageUrl}">
                                <img src="${tour.imageUrl}" alt="${tour.name}" referrerpolicy="no-referrer" onerror="this.onerror=null; this.src='https://images.unsplash.com/photo-1570366583862-f91883984fde?auto=format&fit=crop&w=800&q=80';">
                            </c:when>
                            <c:otherwise>
                                <img src="https://images.unsplash.com/photo-1570366583862-f91883984fde?auto=format&fit=crop&w=800&q=80" alt="Tour image" referrerpolicy="no-referrer">
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="card-body p-4 d-flex flex-column justify-content-between">
                        <div>
                            <div class="d-flex justify-content-between align-items-center text-secondary small mb-2">
                                <span><i class="bi bi-geo-alt text-primary me-1"></i> ${not empty tour.origin ? tour.origin : 'Hà Nội'} &rarr; ${not empty tour.destination ? tour.destination : 'Điểm đến'}</span>
                                <span class="badge bg-primary bg-opacity-10 text-primary border border-primary-subtle extra-small px-2 py-1"><i class="bi bi-globe-americas me-1"></i>${not empty tour.country ? tour.country : 'Việt Nam'}</span>
                            </div>
                            <div class="d-flex justify-content-between text-secondary small mb-2">
                                <span><i class="bi bi-calendar3 text-warning me-1"></i> ${tour.startDate}</span>
                                <span><i class="bi bi-clock text-info me-1"></i> ${tour.duration}</span>
                            </div>
                            <h3 class="h5 fw-bold text-dark mb-2">${tour.name}</h3>
                            <p class="text-secondary small mb-3 text-truncate">${tour.description}</p>
                        </div>

                        <div>
                            <div class="d-flex justify-content-between align-items-center gap-2 pt-3 border-top">
                                <div>
                                    <c:choose>
                                        <c:when test="${tour.discountActive}">
                                            <div class="d-flex align-items-center gap-1">
                                                <small class="text-secondary d-block">Giá ưu đãi</small>
                                                <span class="badge bg-danger bg-opacity-10 text-danger extra-small py-0 px-1 rounded">-${tour.discountPercent}%</span>
                                            </div>
                                            <span class="price-tag text-danger fw-bold"><fmt:formatNumber value="${tour.effectivePrice}" type="number" maxFractionDigits="0"/> VNĐ</span>
                                            <div class="extra-small text-muted text-decoration-line-through">
                                                <fmt:formatNumber value="${tour.originalPrice}" type="number" maxFractionDigits="0"/> VNĐ
                                            </div>
                                            <c:if test="${not empty tour.discountEndDate}">
                                                <div class="extra-small text-danger fw-bold mt-1 js-sale-countdown" data-end="${tour.discountEndDate.time}">
                                                    <i class="bi bi-clock-history me-1"></i><span>Đang tính...</span>
                                                </div>
                                            </c:if>
                                        </c:when>
                                        <c:otherwise>
                                            <small class="text-secondary d-block">Giá tiêu chuẩn</small>
                                            <span class="price-tag"><fmt:formatNumber value="${tour.effectivePrice}" type="number" maxFractionDigits="0"/> VNĐ</span>
                                            <c:if test="${tour.originalPrice > tour.price && not empty tour.discountEndDate}">
                                                <div class="extra-small text-secondary mt-1">
                                                    <i class="bi bi-info-circle me-1"></i>Đã hết hạn giảm giá
                                                </div>
                                            </c:if>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="d-flex flex-column gap-2 align-items-end">
                                    <button type="button" class="btn btn-outline-primary btn-sm rounded-pill px-3 js-tour-detail"
                                        data-tour-id="${tour.id}"
                                        data-tour-name="<c:out value="${tour.name}" />"
                                        data-tour-price="<fmt:formatNumber value="${tour.effectivePrice}" groupingUsed="false" maxFractionDigits="0"/>"
                                        data-tour-original-price="<fmt:formatNumber value="${tour.originalPrice}" groupingUsed="false" maxFractionDigits="0"/>"
                                        data-is-discount-active="${tour.discountActive}"
                                        data-discount-percent="${tour.discountPercent}"
                                        data-discount-end-date="${not empty tour.discountEndDate ? tour.discountEndDate.time : ''}"
                                        data-tour-country="<c:out value="${tour.country}" />"
                                        data-tour-seats="${tour.availableSeats}"
                                        data-tour-start-date="${tour.startDate}"
                                        data-tour-image="<c:out value="${tour.imageUrl}" />"
                                        data-tour-duration="<c:out value="${tour.duration}" />"
                                        data-tour-description="<c:out value="${tour.description}" />"
                                        >
                                    Xem chi tiết &nbsp;&rarr;
                                    </button>
                                    <c:choose>
                                        <c:when test="${tour.availableSeats <= 0}">
                                            <button type="button" class="btn btn-secondary btn-sm rounded-pill px-3" disabled>Hết chỗ</button>
                                        </c:when>
                                        <c:when test="${not empty sessionScope.user}">
                                            <form action="${pageContext.request.contextPath}/user/bookings" method="post">
                                                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                <input type="hidden" name="tourId" value="${tour.id}">
                                                <button type="submit" class="btn btn-accent btn-sm rounded-pill px-3">
                                                    <i class="bi bi-lightning-charge-fill me-1"></i>Đặt ngay
                                                </button>
                                            </form>
                                        </c:when>
                                        <c:otherwise>
                                            <a href="${pageContext.request.contextPath}/login" class="btn btn-accent btn-sm rounded-pill px-3">Đặt ngay</a>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>

    <!-- Phân Trang Danh Sách Tour (Pagination Controls) -->
    <div class="d-flex justify-content-center align-items-center gap-2 mt-5" id="toursPaginationWrap">
        <button class="btn btn-outline-primary btn-sm rounded-pill px-3 shadow-sm" id="prevPageBtn" onclick="changeTourPage(-1)">
            <i class="bi bi-chevron-left me-1"></i> Trang trước
        </button>
        <div id="pageNumbersContainer" class="d-flex gap-1"></div>
        <button class="btn btn-outline-primary btn-sm rounded-pill px-3 shadow-sm" id="nextPageBtn" onclick="changeTourPage(1)">
            Trang sau <i class="bi bi-chevron-right ms-1"></i>
        </button>
    </div>
</main>

<!-- 2. Modal Chi Tiết Tour Cao Cấp & Đẹp Mắt -->
<div class="tour-detail-modal modal-tour-detail" id="tourDetailModal" role="dialog" aria-modal="true" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content border-0 rounded-4 shadow-lg overflow-hidden">
            <!-- Header Modal -->
            <div class="modal-header bg-gradient-navy text-white p-3 px-4 border-0">
                <div class="d-flex align-items-center gap-2 flex-wrap">
                    <span class="badge text-bg-warning text-dark px-3 py-1 rounded-pill fw-bold"><i class="bi bi-star-fill me-1"></i> Tour Trọn Gói Nổi Bật</span>
                    <span class="badge bg-white text-dark px-3 py-1 rounded-pill fw-bold" id="modalTourCountry"><i class="bi bi-globe-americas text-primary me-1"></i>Việt Nam</span>
                    <h5 class="modal-title fw-bold text-white mb-0 fs-5 text-truncate" id="modalTourName" style="max-width: 650px;">Tên Tour Du Lịch</h5>
                </div>
                <button type="button" class="btn-close btn-close-white" data-close-tour-modal aria-label="Đóng"></button>
            </div>

            <div class="modal-body p-4">
                <div class="row g-4">
                    <!-- Cột Trái (70%): Banner, Tiện ích, Mô tả & Accordion Lịch trình -->
                    <div class="col-lg-8">
                        <!-- Banner Ảnh Tour có Overlay Badge -->
                        <div class="position-relative rounded-4 overflow-hidden mb-2 shadow-sm" style="height: 340px;">
                            <img id="modalTourImg" src="https://images.unsplash.com/photo-1570366583862-f91883984fde?auto=format&fit=crop&w=800&q=80" alt="Tour Detail" class="w-100 h-100" style="object-fit: cover;" referrerpolicy="no-referrer" onerror="this.onerror=null; this.src='https://images.unsplash.com/photo-1570366583862-f91883984fde?auto=format&fit=crop&w=800&q=80';">
                            <div class="position-absolute top-0 start-0 p-3 d-flex gap-2">
                                <span class="badge bg-dark bg-opacity-75 text-white backdrop-blur px-3 py-2 rounded-pill"><i class="bi bi-geo-alt-fill text-warning me-1"></i> Điểm đến hấp dẫn</span>
                            </div>
                            <div class="position-absolute bottom-0 start-0 end-0 p-3 bg-gradient-dark text-white d-flex justify-content-between align-items-center">
                                <span class="badge bg-success bg-opacity-90 text-white px-3 py-2 rounded-pill"><i class="bi bi-shield-check me-1"></i> Cam kết dịch vụ chất lượng cao</span>
                                <small class="text-white-50 extra-small"><i class="bi bi-check-all text-warning me-1"></i> Lịch trình đảm bảo 100%</small>
                            </div>
                        </div>

                        <!-- Bộ Sưu Tập Ảnh Thu Nhỏ (Gallery Thumbnails) -->
                        <div class="d-flex gap-2 mb-4 overflow-x-auto pb-1" id="tourGalleryThumbs">
                            <button type="button" class="btn btn-outline-primary active btn-sm rounded-3 py-1 px-2 d-flex align-items-center gap-1 extra-small" onclick="switchModalGalleryImg('main', this)">
                                <i class="bi bi-image"></i> Điểm đến chính
                            </button>
                            <button type="button" class="btn btn-outline-secondary btn-sm rounded-3 py-1 px-2 d-flex align-items-center gap-1 extra-small" onclick="switchModalGalleryImg('https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80', this)">
                                <i class="bi bi-building"></i> Khách sạn & Phòng
                            </button>
                            <button type="button" class="btn btn-outline-secondary btn-sm rounded-3 py-1 px-2 d-flex align-items-center gap-1 extra-small" onclick="switchModalGalleryImg('https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80', this)">
                                <i class="bi bi-cup-hot"></i> Đặc sản ẩm thực
                            </button>
                            <button type="button" class="btn btn-outline-secondary btn-sm rounded-3 py-1 px-2 d-flex align-items-center gap-1 extra-small" onclick="switchModalGalleryImg('https://images.unsplash.com/photo-1488646953014-85cb44e25828?auto=format&fit=crop&w=800&q=80', this)">
                                <i class="bi bi-camera"></i> Hoạt động vui chơi
                            </button>
                        </div>

                        <!-- Thanh Tiện ích Nổi bật (Features Bar) -->
                        <div class="row g-2 mb-4 text-center">
                            <div class="col-3">
                                <div class="feature-chip">
                                    <i class="bi bi-bus-front text-primary fs-5 mb-1 d-block"></i>
                                    <small class="fw-bold d-block text-dark">Xe Du Lịch</small>
                                    <span class="text-secondary extra-small">Đời mới, máy lạnh</span>
                                </div>
                            </div>
                            <div class="col-3">
                                <div class="feature-chip">
                                    <i class="bi bi-building text-warning fs-5 mb-1 d-block"></i>
                                    <small class="fw-bold d-block text-dark">Khách Sạn</small>
                                    <span class="text-secondary extra-small">3 - 5 Sao sang trọng</span>
                                </div>
                            </div>
                            <div class="col-3">
                                <div class="feature-chip">
                                    <i class="bi bi-cup-hot text-danger fs-5 mb-1 d-block"></i>
                                    <small class="fw-bold d-block text-dark">Bữa Ăn</small>
                                    <span class="text-secondary extra-small">Đặc sản địa phương</span>
                                </div>
                            </div>
                            <div class="col-3">
                                <div class="feature-chip">
                                    <i class="bi bi-person-badge text-success fs-5 mb-1 d-block"></i>
                                    <small class="fw-bold d-block text-dark">HDV Chu Đáo</small>
                                    <span class="text-secondary extra-small">Chuyên nghiệp, vui vẻ</span>
                                </div>
                            </div>
                        </div>

                        <!-- Giới thiệu chuyên sâu -->
                        <div class="p-3 bg-light rounded-3 mb-4 border">
                            <h6 class="fw-bold text-navy mb-2"><i class="bi bi-info-circle-fill text-primary me-2"></i> Giới thiệu chuyến đi</h6>
                            <p id="modalTourDesc" class="text-secondary leading-relaxed mb-0 small">Mô tả chuyến đi...</p>
                        </div>

                        <!-- Accordion Lịch trình chi tiết -->
                        <h6 class="fw-bold text-navy mb-3"><i class="bi bi-map-fill text-primary me-2"></i> Lịch trình chi tiết (Itinerary)</h6>
                        <div class="accordion mb-4" id="itineraryAccordion">
                            <div class="accordion-item border rounded-3 mb-2 shadow-sm overflow-hidden">
                                <h2 class="accordion-header">
                                    <button class="accordion-button rounded-3 fw-bold" type="button" data-bs-toggle="collapse" data-bs-target="#day1">
                                        <i class="bi bi-geo-fill text-danger me-2"></i> Ngày 1: Khởi hành & Tham quan các điểm nổi tiếng
                                    </button>
                                </h2>
                                <div id="day1" class="accordion-collapse collapse show" data-bs-parent="#itineraryAccordion">
                                    <div class="accordion-body text-secondary small">
                                        Xe và hướng dẫn viên đón quý khách tại điểm hẹn. Bắt đầu hành trình di chuyển, nhận phòng khách sạn nghỉ ngơi và thưởng thức đặc sản địa phương.
                                    </div>
                                </div>
                            </div>
                            <div class="accordion-item border rounded-3 mb-2 shadow-sm overflow-hidden">
                                <h2 class="accordion-header">
                                    <button class="accordion-button collapsed rounded-3 fw-bold" type="button" data-bs-toggle="collapse" data-bs-target="#day2">
                                        <i class="bi bi-camera-fill text-primary me-2"></i> Ngày 2: Khám phá cảnh đẹp & Trải nghiệm văn hóa
                                    </button>
                                </h2>
                                <div id="day2" class="accordion-collapse collapse" data-bs-parent="#itineraryAccordion">
                                    <div class="accordion-body text-secondary small">
                                        Quý khách dùng điểm tâm sáng. Xe đưa đoàn đi tham quan các danh lam thắng cảnh tiêu biểu, trải nghiệm giao lưu văn hóa và chụp ảnh lưu niệm.
                                    </div>
                                </div>
                            </div>
                            <div class="accordion-item border rounded-3 shadow-sm overflow-hidden">
                                <h2 class="accordion-header">
                                    <button class="accordion-button collapsed rounded-3 fw-bold" type="button" data-bs-toggle="collapse" data-bs-target="#day3">
                                        <i class="bi bi-bag-check-fill text-success me-2"></i> Ngày 3: Mua sắm quà lưu niệm & Trở về
                                    </button>
                                </h2>
                                <div id="day3" class="accordion-collapse collapse" data-bs-parent="#itineraryAccordion">
                                    <div class="accordion-body text-secondary small">
                                        Quý khách tự do tham quan mua sắm đặc sản làm quà cho người thân. Xe đưa đoàn về lại điểm đón ban đầu. Kết thúc chuyến đi tốt đẹp.
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Cột Phải (30%): Box Chốt Sale Đặt Tour -->
                    <div class="col-lg-4">
                        <div class="sticky-booking-box rounded-4 p-4 border border-2 shadow-sm bg-white">
                            <div class="text-center pb-3 mb-3 border-bottom">
                                <small class="text-secondary d-block uppercase fw-bold extra-small text-uppercase">Giá trọn gói / 1 Khách</small>
                                <div id="modalDiscountBadgeWrap" class="my-1" style="display: none;">
                                    <span class="badge text-bg-danger px-2 py-1 rounded-pill fw-bold" id="modalDiscountBadge">-0%</span>
                                    <span class="text-muted text-decoration-line-through small ms-2" id="modalTourOriginalPrice">0 VNĐ</span>
                                </div>
                                <div class="h2 fw-bold text-danger my-1" id="modalTourPrice">0 VNĐ</div>
                                <div id="modalCountdownWrap" class="extra-small text-danger fw-bold mb-2" style="display: none;">
                                    <i class="bi bi-clock-history me-1"></i>Ưu đãi còn: <span id="modalCountdownText">--</span>
                                </div>
                                <span class="badge text-bg-success px-3 py-1 rounded-pill"><i class="bi bi-tag-fill me-1"></i> Đã bao gồm Thuế & Phí</span>
                            </div>

                            <div class="bg-light p-3 rounded-3 mb-3 border">
                                <div class="d-flex justify-content-between align-items-center text-secondary small mb-2 pb-2 border-bottom">
                                    <span><i class="bi bi-calendar3 text-primary me-1"></i> Ngày đi:</span>
                                    <strong id="modalTourStartDate" class="text-dark">--</strong>
                                </div>
                                <div class="d-flex justify-content-between align-items-center text-secondary small mb-2 pb-2 border-bottom">
                                    <span><i class="bi bi-person-check text-success me-1"></i> Số chỗ còn nhận:</span>
                                    <span id="modalTourSeats" class="badge text-bg-success px-2 py-1">20 chỗ</span>
                                </div>
                                <div class="d-flex justify-content-between align-items-center text-secondary small mb-2 pb-2 border-bottom">
                                    <span><i class="bi bi-clock text-warning me-1"></i> Thời lượng:</span>
                                    <strong id="modalTourDuration" class="text-dark">3 ngày 2 đêm</strong>
                                </div>
                                <div class="d-flex justify-content-between align-items-center text-secondary small">
                                    <span><i class="bi bi-shield-check text-info me-1"></i> Bảo hiểm:</span>
                                    <strong class="text-success">Bao gồm trọn gói</strong>
                                </div>
                            </div>

                            <!-- Box Áp Dụng Mã Giảm Giá / Voucher Khuyến Mãi -->
                            <div class="mb-3 p-3 bg-light rounded-3 border">
                                <label class="form-label fw-bold extra-small text-uppercase text-secondary mb-1">
                                    <i class="bi bi-ticket-perforated-fill text-danger me-1"></i> Mã Giảm Giá / Voucher
                                </label>
                                <div class="input-group input-group-sm">
                                    <input type="text" id="modalCouponInput" class="form-control font-monospace text-uppercase" placeholder="VD: HE2026, GIAM200K">
                                    <button type="button" class="btn btn-outline-danger fw-bold px-3" onclick="applyTourCoupon()">Áp dụng</button>
                                </div>
                                <div id="couponFeedback" class="extra-small mt-2 d-none"></div>
                            </div>

                            <form action="${pageContext.request.contextPath}/user/bookings" method="post" id="modalBookingForm">
                                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                <input type="hidden" name="tourId" id="modalTourId">
                                <input type="hidden" name="couponCode" id="modalAppliedCoupon">

                                <c:choose>
                                    <c:when test="${not empty sessionScope.user}">
                                        <button type="submit" class="btn btn-accent w-100 btn-lg shadow-sm py-3 fw-bold rounded-3">
                                            <i class="bi bi-lightning-charge-fill me-1"></i> ĐẶT TOUR NGAY
                                        </button>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="${pageContext.request.contextPath}/login" class="btn btn-accent w-100 btn-lg shadow-sm py-3 fw-bold rounded-3">
                                            <i class="bi bi-box-arrow-in-right me-1"></i> Đăng nhập để đặt tour
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                            </form>

                            <div class="mt-3 text-center">
                                <small class="text-muted extra-small d-block mb-1"><i class="bi bi-lock-fill text-success me-1"></i> Bảo mật thông tin & Giữ chỗ tức thì</small>
                                <small class="text-muted extra-small d-block"><i class="bi bi-arrow-counterclockwise text-primary me-1"></i> Hoàn tiền nếu hủy theo chính sách</small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Mobile Sticky Bottom Bar (Nút chốt sale cố định dưới màn hình điện thoại) -->
<div class="mobile-sticky-bar" id="mobileStickyBar" style="display:none;">
    <div>
        <small class="text-secondary d-block">Tổng tiền tour</small>
        <strong class="text-danger fs-5" id="mobileBarPrice">0 VNĐ</strong>
    </div>
    <button type="button" class="btn btn-accent px-4 py-2" onclick="submitMobileBooking()">
        <i class="bi bi-lightning-charge-fill me-1"></i> Đặt Ngay
    </button>
</div>

<!-- Footer -->
<jsp:include page="/user/footer.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    let currentTourEffectivePrice = 0;
    let currentTourOriginalPrice = 0;
    let currentMainTourImage = '';
    let modalCountdownTimer = null;

    function formatTimeRemaining(diff) {
        if (diff <= 0) return 'Đã hết hạn';
        const days = Math.floor(diff / (1000 * 60 * 60 * 24));
        const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
        const mins = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
        const secs = Math.floor((diff % (1000 * 60)) / 1000);
        if (days > 0) {
            return 'Còn ' + days + ' ngày ' + hours + 'h ' + mins + 'm';
        }
        return 'Còn ' + String(hours).padStart(2, '0') + ':' + String(mins).padStart(2, '0') + ':' + String(secs).padStart(2, '0');
    }

    function updateCountdownDisplay(targetTime, spanEl, containerEl) {
        const now = Date.now();
        const diff = targetTime - now;
        if (diff <= 0) {
            spanEl.innerText = 'Đã hết hạn giảm giá (về giá gốc)';
            if (containerEl) {
                containerEl.classList.remove('text-danger');
                containerEl.classList.add('text-secondary');
            }
            return false;
        }
        spanEl.innerText = formatTimeRemaining(diff);
        return true;
    }

    function updateModalCountdown(endTime, textEl, wrapEl) {
        if (modalCountdownTimer) clearInterval(modalCountdownTimer);
        updateCountdownDisplay(endTime, textEl, wrapEl);
        modalCountdownTimer = setInterval(function() {
            const active = updateCountdownDisplay(endTime, textEl, wrapEl);
            if (!active && modalCountdownTimer) clearInterval(modalCountdownTimer);
        }, 1000);
    }

    function initCardCountdowns() {
        const updateAll = () => {
            document.querySelectorAll('.js-sale-countdown').forEach(function(wrap) {
                const endTime = Number(wrap.dataset.end);
                if (!endTime) return;
                const span = wrap.querySelector('span');
                if (!span) return;
                updateCountdownDisplay(endTime, span, wrap);
            });
        };
        updateAll();
        setInterval(updateAll, 1000);
    }

    function populateTourDetail(button) {
        const tour = button.dataset;
        const price = Number(tour.tourPrice);
        const originalPrice = Number(tour.tourOriginalPrice || price);
        const isDiscountActive = tour.isDiscountActive === 'true';
        const discountPercent = Number(tour.discountPercent || 0);
        const discountEndDate = tour.discountEndDate ? Number(tour.discountEndDate) : null;

        currentTourEffectivePrice = price;
        currentTourOriginalPrice = originalPrice;
        currentMainTourImage = tour.tourImage || 'https://images.unsplash.com/photo-1570366583862-f91883984fde?auto=format&fit=crop&w=800&q=80';

        document.getElementById('modalTourId').value = tour.tourId;
        document.getElementById('modalTourName').innerText = tour.tourName;
        const countryEl = document.getElementById('modalTourCountry');
        if (countryEl) countryEl.innerHTML = '<i class="bi bi-globe-americas text-primary me-1"></i> ' + (tour.tourCountry || 'Việt Nam');
        document.getElementById('modalTourPrice').innerHTML = price.toLocaleString('vi-VN') + ' VNĐ';
        document.getElementById('modalTourSeats').innerText = tour.tourSeats + ' chỗ';
        document.getElementById('modalTourStartDate').innerText = tour.tourStartDate;
        document.getElementById('modalTourDuration').innerText = tour.tourDuration || '3 ngày 2 đêm';
        document.getElementById('modalTourDesc').innerText = tour.tourDescription || 'Chuyến du lịch khám phá trọn gói tuyệt vời dành cho bạn và gia đình.';
        document.getElementById('modalTourImg').src = currentMainTourImage;

        // Discount & Countdown display in Modal
        const discountBadgeWrap = document.getElementById('modalDiscountBadgeWrap');
        const countdownWrap = document.getElementById('modalCountdownWrap');
        const originalPriceEl = document.getElementById('modalTourOriginalPrice');
        const discountBadgeEl = document.getElementById('modalDiscountBadge');
        const countdownTextEl = document.getElementById('modalCountdownText');

        if (isDiscountActive && originalPrice > price) {
            if (discountBadgeWrap) discountBadgeWrap.style.display = 'block';
            if (originalPriceEl) originalPriceEl.innerText = originalPrice.toLocaleString('vi-VN') + ' VNĐ';
            if (discountBadgeEl) discountBadgeEl.innerText = '-' + discountPercent + '%';

            if (discountEndDate && countdownWrap && countdownTextEl) {
                countdownWrap.style.display = 'block';
                countdownWrap.classList.remove('text-secondary');
                countdownWrap.classList.add('text-danger');
                updateModalCountdown(discountEndDate, countdownTextEl, countdownWrap);
            } else if (countdownWrap) {
                countdownWrap.style.display = 'none';
            }
        } else {
            if (discountBadgeWrap) discountBadgeWrap.style.display = 'none';
            if (countdownWrap) countdownWrap.style.display = 'none';
        }

        // Reset Coupon
        const couponInput = document.getElementById('modalCouponInput');
        if (couponInput) couponInput.value = '';
        const feedback = document.getElementById('couponFeedback');
        if (feedback) { feedback.className = 'extra-small mt-2 d-none'; feedback.innerText = ''; }
        const appliedInput = document.getElementById('modalAppliedCoupon');
        if (appliedInput) appliedInput.value = '';

        // Reset Gallery Thumbnails Active State
        document.querySelectorAll('#tourGalleryThumbs button').forEach((btn, idx) => {
            if (idx === 0) {
                btn.classList.remove('btn-outline-secondary');
                btn.classList.add('btn-outline-primary', 'active');
            } else {
                btn.classList.remove('btn-outline-primary', 'active');
                btn.classList.add('btn-outline-secondary');
            }
        });

        // Mobile bar update
        document.getElementById('mobileBarPrice').innerText = price.toLocaleString('vi-VN') + ' VNĐ';
        if (window.innerWidth <= 768) {
            document.getElementById('mobileStickyBar').style.display = 'flex';
        }
    }

    // Chuyển đổi ảnh trong Bộ sưu tập Gallery
    function switchModalGalleryImg(src, btn) {
        const imgEl = document.getElementById('modalTourImg');
        if (!imgEl) return;
        imgEl.src = (src === 'main') ? currentMainTourImage : src;

        document.querySelectorAll('#tourGalleryThumbs button').forEach(b => {
            b.classList.remove('btn-outline-primary', 'active');
            b.classList.add('btn-outline-secondary');
        });
        if (btn) {
            btn.classList.remove('btn-outline-secondary');
            btn.classList.add('btn-outline-primary', 'active');
        }
    }

    // Áp dụng Mã giảm giá / Coupon bằng AJAX
    async function applyTourCoupon() {
        const input = document.getElementById('modalCouponInput');
        const feedback = document.getElementById('couponFeedback');
        const appliedInput = document.getElementById('modalAppliedCoupon');
        const priceEl = document.getElementById('modalTourPrice');
        const mobilePriceEl = document.getElementById('mobileBarPrice');
        if (!input || !feedback) return;

        const code = input.value.trim();
        if (!code) {
            feedback.className = 'extra-small mt-2 text-danger d-block';
            feedback.innerText = 'Vui lòng nhập mã voucher!';
            return;
        }

        try {
            const url = '${pageContext.request.contextPath}/coupon?action=check&code=' + encodeURIComponent(code) + '&price=' + currentTourEffectivePrice;
            const res = await fetch(url);
            const data = await res.json();

            if (data.valid) {
                feedback.className = 'extra-small mt-2 text-success fw-bold d-block';
                feedback.innerHTML = '<i class="bi bi-check-circle-fill me-1"></i> ' + data.message;
                if (appliedInput) appliedInput.value = data.code;
                
                // Cập nhật giá hiển thị có gạch ngang giá tour
                priceEl.innerHTML = '<span class="text-decoration-line-through text-secondary fs-6 me-2">' + 
                                    currentTourEffectivePrice.toLocaleString('vi-VN') + ' đ</span>' + 
                                    Number(data.finalPrice).toLocaleString('vi-VN') + ' VNĐ';
                if (mobilePriceEl) {
                    mobilePriceEl.innerText = Number(data.finalPrice).toLocaleString('vi-VN') + ' VNĐ';
                }
            } else {
                feedback.className = 'extra-small mt-2 text-danger d-block';
                feedback.innerHTML = '<i class="bi bi-exclamation-triangle-fill me-1"></i> ' + data.message;
                if (appliedInput) appliedInput.value = '';
                priceEl.innerHTML = currentTourEffectivePrice.toLocaleString('vi-VN') + ' VNĐ';
                if (mobilePriceEl) mobilePriceEl.innerText = currentTourEffectivePrice.toLocaleString('vi-VN') + ' VNĐ';
            }
        } catch (e) {
            feedback.className = 'extra-small mt-2 text-danger d-block';
            feedback.innerText = 'Lỗi kiểm tra mã giảm giá. Vui lòng thử lại.';
        }
    }

    // Lọc Tour theo Thanh Trượt Giá & Phân Trang
    const TOURS_PER_PAGE = 6;
    let currentTourPage = 1;

    function formatVND(amount) {
        const num = Number(amount);
        if (num >= 1000000) {
            const m = num / 1000000;
            return (Number.isInteger(m) ? m : m.toFixed(1)) + ' Triệu VNĐ';
        }
        return num.toLocaleString('vi-VN') + ' VNĐ';
    }

    function updatePriceFilter(val) {
        const display = document.getElementById('priceDisplay');
        if (display) {
            display.innerText = formatVND(val);
        }
        currentTourPage = 1; // Đổi mức giá thì quay lại trang 1
        filterAndPaginateTours();
    }

    function resetPriceFilter() {
        const slider = document.getElementById('priceRange');
        if (slider) {
            slider.value = 100000000;
            updatePriceFilter(100000000);
        }
    }

    function filterAndPaginateTours() {
        const slider = document.getElementById('priceRange');
        const maxPrice = Number(slider ? slider.value : 100000000);
        const cards = Array.from(document.querySelectorAll('.tour-card')).map(card => card.closest('.col-lg-4, .col-md-6'));
        
        let matchedCols = [];
        cards.forEach(col => {
            if (!col) return;
            const priceBtn = col.querySelector('.js-tour-detail');
            const price = Number(priceBtn?.dataset?.tourPrice || 0);
            if (price <= maxPrice) {
                col.dataset.filterMatch = "true";
                matchedCols.push(col);
            } else {
                col.dataset.filterMatch = "false";
                col.style.display = 'none';
            }
        });

        // Xử lý thông báo khi không có tour nào khớp khoảng giá
        const noMatchAlert = document.getElementById('noPriceMatchAlert');
        if (noMatchAlert) {
            noMatchAlert.style.display = (matchedCols.length === 0 && cards.length > 0) ? 'block' : 'none';
        }

        const totalPages = Math.max(1, Math.ceil(matchedCols.length / TOURS_PER_PAGE));
        if (currentTourPage > totalPages) currentTourPage = totalPages;
        if (currentTourPage < 1) currentTourPage = 1;

        matchedCols.forEach((col, idx) => {
            const start = (currentTourPage - 1) * TOURS_PER_PAGE;
            const end = start + TOURS_PER_PAGE;
            col.style.display = (idx >= start && idx < end) ? '' : 'none';
        });

        // Cập nhật điều khiển phân trang
        const prevBtn = document.getElementById('prevPageBtn');
        const nextBtn = document.getElementById('nextPageBtn');
        const pageNumbersContainer = document.getElementById('pageNumbersContainer');
        const paginationWrap = document.getElementById('toursPaginationWrap');

        if (matchedCols.length <= TOURS_PER_PAGE) {
            if (paginationWrap) paginationWrap.style.display = 'none';
        } else {
            if (paginationWrap) paginationWrap.style.display = 'flex';
            if (prevBtn) prevBtn.disabled = (currentTourPage <= 1);
            if (nextBtn) nextBtn.disabled = (currentTourPage >= totalPages);

            if (pageNumbersContainer) {
                pageNumbersContainer.innerHTML = '';
                for (let p = 1; p <= totalPages; p++) {
                    const btn = document.createElement('button');
                    btn.type = 'button';
                    btn.className = 'btn btn-sm rounded-pill px-3 shadow-sm ' + (p === currentTourPage ? 'btn-primary' : 'btn-outline-primary');
                    btn.innerText = p;
                    btn.onclick = (function(page) {
                        return function() {
                            currentTourPage = page;
                            filterAndPaginateTours();
                            window.scrollTo({ top: 350, behavior: 'smooth' });
                        };
                    })(p);
                    pageNumbersContainer.appendChild(btn);
                }
            }
        }
    }

    function changeTourPage(delta) {
        currentTourPage += delta;
        filterAndPaginateTours();
        window.scrollTo({ top: 350, behavior: 'smooth' });
    }

    const tourDetailModal = document.getElementById('tourDetailModal');

    document.querySelectorAll('.js-tour-detail').forEach(function (button) {
        button.addEventListener('click', function () {
            populateTourDetail(button);
            tourDetailModal.classList.add('is-open');
            tourDetailModal.setAttribute('aria-hidden', 'false');
            document.body.style.overflow = 'hidden';
        });
    });

    function closeTourDetail() {
        tourDetailModal.classList.remove('is-open');
        tourDetailModal.setAttribute('aria-hidden', 'true');
        document.body.style.overflow = '';
    }

    tourDetailModal.querySelector('[data-close-tour-modal]').addEventListener('click', closeTourDetail);
    tourDetailModal.addEventListener('click', function (event) {
        if (event.target === tourDetailModal) closeTourDetail();
    });
    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape' && tourDetailModal.classList.contains('is-open')) closeTourDetail();
    });

    function submitMobileBooking() {
        document.getElementById('modalBookingForm').submit();
    }

    window.addEventListener('DOMContentLoaded', function() {
        initCardCountdowns();
        const slider = document.getElementById('priceRange');
        if (slider) {
            updatePriceFilter(slider.value);
        } else {
            filterAndPaginateTours();
        }
    });
</script>
</body>
</html>
