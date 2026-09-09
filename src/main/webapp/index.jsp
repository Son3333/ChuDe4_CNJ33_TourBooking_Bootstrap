<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TourBooking - Khám phá hành trình mới</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        :root {
            --navy: #17324d;
            --navy-dark: #0f2238;
            --orange: #e76f3c;
            --orange-hover: #c9552b;
            --bg-gray: #f7f8f5;
        }

        body {
            background-color: var(--bg-gray);
            color: #17202a;
            font-family: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
        }

        .navbar {
            background: var(--navy);
            position: relative;
            z-index: 10;
        }

        /* Hero Section & Slider */
        .hero {
            position: relative;
            min-height: 85vh;
            display: flex;
            align-items: center;
            overflow: hidden;
            color: white;
        }

        .hero-slide {
            position: absolute;
            inset: 0;
            background-position: center;
            background-size: cover;
            opacity: 0;
            transition: opacity 1.2s ease-in-out;
            animation: kenburns 20s infinite alternate ease-in-out;
        }

        .hero-slide.active {
            opacity: 1;
        }

        @keyframes kenburns {
            0% { transform: scale(1); }
            100% { transform: scale(1.12); }
        }

        .hero-overlay {
            position: absolute;
            inset: 0;
            background: linear-gradient(180deg, rgba(15, 34, 56, 0.75) 0%, rgba(15, 34, 56, 0.88) 100%);
            z-index: 1;
        }

        .hero-content {
            position: relative;
            z-index: 2;
            width: 100%;
            padding-top: 3rem;
            padding-bottom: 3rem;
        }

        .hero h1 {
            font-family: Georgia, serif;
            font-size: clamp(2.2rem, 5vw, 4.2rem);
            line-height: 1.1;
            font-weight: 700;
        }

        /* Horizontal Search Bar (PC Single Block) */
        .search-box {
            background: white;
            border-radius: 16px;
            padding: 1rem 1.25rem;
            box-shadow: 0 15px 35px rgba(15, 34, 56, 0.25);
            color: #334155;
        }

        .search-box label {
            font-size: 0.75rem;
            font-weight: 700;
            text-transform: uppercase;
            color: #64748b;
            letter-spacing: 0.05em;
            margin-bottom: 0.2rem;
            display: block;
        }

        .search-box input, .search-box select {
            border: none;
            outline: none;
            box-shadow: none;
            font-weight: 600;
            color: var(--navy);
            padding-left: 0;
            background: transparent;
        }

        .search-box input:focus, .search-box select:focus {
            box-shadow: none;
            border-color: transparent;
        }

        .search-divider {
            border-right: 1px solid #e2e8f0;
        }

        .btn-accent {
            background: var(--orange);
            border-color: var(--orange);
            color: white;
            font-weight: 700;
            border-radius: 12px;
            padding: 0.8rem 1.75rem;
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
            box-shadow: 0 8px 20px rgba(231, 111, 60, 0.35);
        }

        /* Tour Cards & Grid */
        .section-title {
            color: var(--navy);
            font-weight: 800;
        }

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
            text-transform: uppercase;
        }

        .price-tag {
            color: var(--orange);
            font-size: 1.35rem;
            font-weight: 800;
        }

        .nav-pill {
            border-radius: 8px;
        }

        /* Responsive Mobile Adjustment */
        @media (max-width: 991px) {
            .search-divider {
                border-right: none;
                border-bottom: 1px solid #e2e8f0;
                padding-bottom: 0.75rem;
                margin-bottom: 0.75rem;
            }
        }
        @media (max-width: 768px) {
            .hero {
                min-height: auto;
                padding: 2.5rem 0 3rem 0;
            }
            .hero-content {
                padding-top: 1rem;
                padding-bottom: 1rem;
            }
            .hero h1 {
                font-size: 1.85rem;
            }
            .hero p.lead {
                font-size: 0.95rem;
            }
            .search-box {
                padding: 1rem;
                border-radius: 14px;
            }
            .card-img-wrapper {
                height: 180px;
            }
            .section-title {
                font-size: 1.35rem;
            }
        }
    </style>
</head>
<body>

<!-- Navbar -->
<jsp:include page="/user/navbar.jsp">
    <jsp:param name="active" value="home" />
</jsp:include>

<!-- 1. Hero Section với Slider Background & Horizontal Search Bar -->
<section class="hero">
    <div class="hero-slide active" style="background-image: url('https://images.unsplash.com/photo-1570366583862-f91883984fde?auto=format&fit=crop&w=1800&q=85')"></div>
    <div class="hero-slide" style="background-image: url('https://images.unsplash.com/photo-1528127269322-539801943592?auto=format&fit=crop&w=1800&q=85')"></div>
    <div class="hero-slide" style="background-image: url('https://images.unsplash.com/photo-1559592413-7cec4d0cae2b?auto=format&fit=crop&w=1800&q=85')"></div>
    <div class="hero-overlay"></div>

    <div class="container hero-content">
        <div class="row justify-content-center text-center mb-4">
            <div class="col-lg-9">
                <p class="text-uppercase small fw-bold text-warning mb-2 letter-spacing-2"><i class="bi bi-stars me-1"></i> Đi xa hơn, sống trọn hơn</p>
                <h1 class="mb-3">Mở Bản Đồ, Chọn Hành Trình</h1>
                <p class="lead opacity-90 mb-4">Tìm kiếm hàng trăm chuyến du lịch trọn gói, giá tốt nhất và trải nghiệm đáng nhớ.</p>
            </div>
        </div>

        <!-- Horizontal Search Box (Khối tìm kiếm nguyên khối) -->
        <div class="row justify-content-center">
            <div class="col-lg-11">
                <div class="search-box">
                    <form action="${pageContext.request.contextPath}/tours" method="get" class="row g-2 align-items-center">
                        <!-- Nơi đi -->
                        <div class="col-lg-3 col-md-6 search-divider">
                            <label><i class="bi bi-geo-alt-fill text-danger me-1"></i> Điểm đi</label>
                            <input type="text" name="origin" class="form-control" placeholder="Hà Nội, TP.HCM...">
                        </div>
                        <!-- Nơi đến -->
                        <div class="col-lg-3 col-md-6 search-divider">
                            <label><i class="bi bi-pin-map-fill text-primary me-1"></i> Điểm đến</label>
                            <input type="text" name="q" class="form-control" placeholder="Sapa, Đà Nẵng, Phú Quốc...">
                        </div>
                        <!-- Ngày khởi hành -->
                        <div class="col-lg-2 col-md-6 search-divider">
                            <label><i class="bi bi-calendar-event-fill text-warning me-1"></i> Khởi hành</label>
                            <input type="date" name="startDate" class="form-control">
                        </div>
                        <!-- Số người -->
                        <div class="col-lg-2 col-md-6 search-divider">
                            <label><i class="bi bi-people-fill text-success me-1"></i> Số khách</label>
                            <select name="guests" class="form-select">
                                <option value="1">1 người</option>
                                <option value="2" selected>2 người</option>
                                <option value="4">3-4 người</option>
                                <option value="5">Gia đình (5+)</option>
                            </select>
                        </div>
                        <!-- Nút tìm kiếm -->
                        <div class="col-lg-2 col-12">
                            <button type="submit" class="btn btn-accent w-100 h-100 d-flex align-items-center justify-content-center gap-2">
                                <i class="bi bi-search"></i> Tìm Kiếm
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- 2. Danh Sách Tour Nổi Bật (Grid Layout) -->
<section class="py-5 container">
    <div class="d-flex justify-content-between align-items-end mb-4">
        <div>
            <p class="text-uppercase small fw-bold text-primary mb-1">Gợi ý dành cho bạn</p>
            <h2 class="h3 section-title mb-0">Tour Du Lịch Hot Nhất</h2>
        </div>
        <a href="${pageContext.request.contextPath}/tours" class="btn btn-outline-primary btn-sm fw-semibold rounded-pill px-3">
            Xem tất cả tour <i class="bi bi-arrow-right ms-1"></i>
        </a>
    </div>

<%
    vn.edu.eaut.tour.dao.TourDAO homeTourDAO = new vn.edu.eaut.tour.dao.TourDAO();
    java.util.List<vn.edu.eaut.tour.model.Tour> featuredTours = homeTourDAO.getAllTours();
    if (featuredTours != null && featuredTours.size() > 6) {
        featuredTours = featuredTours.subList(0, 6);
    }
    request.setAttribute("featuredTours", featuredTours);
%>
    <div class="row g-4">
        <c:forEach var="tour" items="${featuredTours}">
            <div class="col-lg-4 col-md-6">
                <div class="tour-card">
                    <div class="card-img-wrapper">
                        <c:choose>
                            <c:when test="${tour.availableSeats <= 3 && tour.availableSeats > 0}">
                                <span class="badge text-bg-warning tour-badge text-dark"><i class="bi bi-exclamation-triangle-fill me-1"></i> Chỉ còn ${tour.availableSeats} chỗ</span>
                            </c:when>
                            <c:when test="${tour.availableSeats == 0}">
                                <span class="badge text-bg-danger tour-badge"><i class="bi bi-x-circle-fill me-1"></i> Đã hết chỗ</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge text-bg-success tour-badge"><i class="bi bi-fire me-1"></i> Đang mở bán</span>
                            </c:otherwise>
                        </c:choose>

                        <c:if test="${tour.discountActive}">
                            <span class="tour-discount-badge" style="position:absolute; bottom:12px; left:12px; background:linear-gradient(135deg,#e76f3c,#ef4444); color:white; font-weight:bold; font-size:0.8rem; padding:4px 10px; border-radius:30px; box-shadow:0 4px 10px rgba(0,0,0,0.25); z-index:2;">
                                <i class="bi bi-fire me-1"></i> -${tour.discountPercent}%
                            </span>
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
                                <span><i class="bi bi-clock text-info me-1"></i> ${not empty tour.duration ? tour.duration : 'Nhiều ngày'}</span>
                                <span><i class="bi bi-calendar3 text-warning me-1"></i> ${tour.startDate}</span>
                            </div>
                            <h3 class="h5 fw-bold text-dark mb-3 text-truncate" title="${tour.name}">${tour.name}</h3>
                        </div>
                        <div>
                            <div class="d-flex justify-content-between align-items-center pt-3 border-top">
                                <div>
                                    <small class="text-secondary d-block">Giá từ</small>
                                    <c:choose>
                                        <c:when test="${tour.discountActive}">
                                            <span class="price-tag text-danger fw-bold"><fmt:formatNumber value="${tour.price}" type="number" maxFractionDigits="0"/> đ</span>
                                            <small class="text-muted text-decoration-line-through ms-1"><fmt:formatNumber value="${tour.originalPrice}" type="number" maxFractionDigits="0"/> đ</small>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="price-tag fw-bold" style="color:var(--navy);"><fmt:formatNumber value="${tour.price}" type="number" maxFractionDigits="0"/> đ</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <a href="${pageContext.request.contextPath}/tours" class="btn btn-accent btn-sm rounded-pill px-3">
                                    Chi tiết <i class="bi bi-chevron-right ms-1"></i>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </c:forEach>
    </div>
</section>

<!-- Footer -->
<jsp:include page="/user/footer.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Slider background crossfade
    const slides = document.querySelectorAll('.hero-slide');
    let cur = 0;
    if (slides.length > 0) {
        setInterval(() => {
            slides[cur].classList.remove('active');
            cur = (cur + 1) % slides.length;
            slides[cur].classList.add('active');
        }, 6000);
    }
</script>
</body>
</html>
