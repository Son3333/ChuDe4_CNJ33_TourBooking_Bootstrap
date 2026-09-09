<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN" />
<%
    if (session.getAttribute("user") == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    if (request.getAttribute("myBookings") == null) {
        response.sendRedirect(request.getContextPath() + "/user/bookings");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tour Của Tôi | TourBooking</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        :root {
            --navy: #17324d;
            --orange: #e76f3c;
            --bg-gray: #f7f8f5;
        }

        body {
            background-color: var(--bg-gray);
            color: #17202a;
            font-family: system-ui, -apple-system, "Segoe UI", Roboto, sans-serif;
        }

        .navbar {
            background: var(--navy);
        }

        /* Stepper Progression */
        .stepper {
            display: flex;
            justify-content: space-between;
            position: relative;
            margin-bottom: 2rem;
        }

        .stepper::before {
            content: "";
            position: absolute;
            top: 50%;
            left: 0;
            right: 0;
            height: 3px;
            background: #e2e8f0;
            z-index: 1;
            transform: translateY(-50%);
        }

        .step-item {
            position: relative;
            z-index: 2;
            background: var(--bg-gray);
            padding: 0 1rem;
            text-align: center;
        }

        .step-circle {
            width: 42px;
            height: 42px;
            border-radius: 50%;
            background: #cbd5e1;
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            margin: 0 auto 0.5rem auto;
            transition: all 0.3s ease;
        }

        .step-item.active .step-circle {
            background: var(--orange);
            box-shadow: 0 0 0 6px rgba(231, 111, 60, 0.2);
        }

        .step-item.completed .step-circle {
            background: #10b981;
        }

        .step-title {
            font-size: 0.85rem;
            font-weight: 700;
            color: #64748b;
        }

        .step-item.active .step-title {
            color: var(--navy);
        }

        /* Booking Card Style */
        .booking-card {
            border: none;
            border-radius: 16px;
            background: white;
            box-shadow: 0 8px 25px rgba(23, 50, 77, 0.06);
            transition: all 0.3s ease;
            margin-bottom: 1.25rem;
        }

        .booking-card:hover {
            box-shadow: 0 14px 35px rgba(23, 50, 77, 0.12);
        }

        .ticket-code {
            background: #f1f5f9;
            color: var(--navy);
            font-family: monospace;
            font-size: 1rem;
            font-weight: 700;
            padding: 0.3rem 0.75rem;
            border-radius: 8px;
            border: 1px dashed #cbd5e1;
        }

        /* Nav Tabs */
        .nav-tabs .nav-link {
            border: none;
            color: #64748b;
            font-weight: 600;
            padding: 0.75rem 1.25rem;
            border-radius: 10px;
            margin-right: 0.5rem;
            transition: all 0.2s ease;
        }

        .nav-tabs .nav-link.active {
            background: var(--navy);
            color: white;
        }

        .payment-modal {
            display: none;
            position: fixed;
            inset: 0;
            z-index: 2000;
            padding: 1rem;
            overflow-y: auto;
            background: rgba(15, 23, 42, 0.62);
        }
        .payment-modal.is-open { display: block; }
        .payment-modal .modal-dialog { margin: 2rem auto; }

        /* E-Ticket Styles */
        .eticket-card {
            background: #ffffff;
            border-radius: 16px;
            overflow: hidden;
            border: 2px dashed #cbd5e1;
            position: relative;
            box-shadow: 0 10px 30px rgba(15,23,42,0.08);
        }
        .eticket-header {
            background: linear-gradient(135deg, #17324d 0%, #0f2238 100%);
            color: #ffffff;
            padding: 1.25rem 1.5rem;
        }
        .eticket-body {
            padding: 1.5rem;
            background: #ffffff;
        }
        .eticket-qr-box {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 12px;
            text-align: center;
        }
        .eticket-stub {
            background: #f8fafc;
            border-top: 2px dashed #cbd5e1;
            padding: 1rem 1.5rem;
        }

        @media (max-width: 768px) {
            body { padding-bottom: 75px; }
            .booking-card { padding: 1rem !important; }
            .step-circle { width: 32px !important; height: 32px !important; font-size: 0.8rem !important; margin-bottom: 0.25rem !important; }
            .step-title { font-size: 0.68rem !important; }
            .step-item { padding: 0 0.25rem !important; }
            .eticket-header, .eticket-body, .eticket-stub { padding: 1rem !important; }
        }

        @media print {
            body * { visibility: hidden !important; }
            .printable-ticket-area, .printable-ticket-area * { visibility: visible !important; }
            .printable-ticket-area { position: absolute; left: 0; top: 0; width: 100%; margin: 0; padding: 0; }
            .modal-footer, .btn, .btn-close, .navbar, .stepper, footer, #liveChatApp, .modal-backdrop { display: none !important; }
        }
    </style>
</head>
<body class="pb-5">

<!-- Navbar -->
<jsp:include page="/user/navbar.jsp" />

<div class="container">

    <!-- Stepper Tiến Trình Đặt Tour -->
    <div class="row justify-content-center mb-4">
        <div class="col-lg-10">
            <div class="stepper">
                <div class="step-item completed">
                    <div class="step-circle"><i class="bi bi-check-lg"></i></div>
                    <div class="step-title">1. Chọn số lượng</div>
                </div>
                <div class="step-item completed">
                    <div class="step-circle"><i class="bi bi-check-lg"></i></div>
                    <div class="step-title">2. Thông tin hành khách</div>
                </div>
                <div class="step-item active">
                    <div class="step-circle">3</div>
                    <div class="step-title">3. Quản lý & Thanh toán</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Thông Báo Phản Hồi -->
    <c:if test="${not empty sessionScope.msg}">
        <div class="alert alert-success alert-dismissible fade show shadow-sm mb-4" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i> ${sessionScope.msg}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <c:remove var="msg" scope="session" />
    </c:if>
    <c:if test="${not empty sessionScope.error}">
        <div class="alert alert-danger alert-dismissible fade show shadow-sm mb-4" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i> ${sessionScope.error}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <c:remove var="error" scope="session" />
    </c:if>

    <div class="row g-4">
        <!-- Danh Sách Đơn Đặt Tour Theo Tabs -->
        <div class="col-lg-8">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <h1 class="h4 fw-bold text-dark mb-0"><i class="bi bi-ticket-detailed text-primary me-2"></i> Tour Của Tôi</h1>
                <span class="badge text-bg-secondary fs-6">${myBookings.size()} đơn</span>
            </div>

            <!-- Tabs Phân Loại -->
            <ul class="nav nav-tabs border-0 mb-4" id="bookingTabs">
                <li class="nav-item">
                    <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#tabAll">Tất cả đơn</button>
                </li>
            </ul>

            <div class="tab-content" id="bookingTabsContent">
                <div class="tab-pane fade show active" id="tabAll">
                    <c:forEach var="b" items="${myBookings}">
                        <div class="booking-card p-4">
                            <div class="d-flex justify-content-between align-items-start mb-3">
                                <div>
                                    <span class="ticket-code">#BK-${b.id}</span>
                                    <small class="text-secondary ms-2"><i class="bi bi-calendar-event"></i> Ngày đặt: ${b.bookingDate}</small>
                                </div>
                                <div class="d-flex align-items-center gap-1">
                                    <c:choose>
                                        <c:when test="${b.status == 'COMPLETED'}">
                                            <span class="badge text-bg-primary px-3 py-2"><i class="bi bi-check2-all me-1"></i> Đã hoàn thành</span>
                                        </c:when>
                                        <c:when test="${b.status == 'CONFIRMED'}">
                                            <span class="badge text-bg-success px-3 py-2"><i class="bi bi-check-circle-fill me-1"></i> Đã xác nhận</span>
                                        </c:when>
                                        <c:when test="${b.status == 'PENDING'}">
                                            <span class="badge text-bg-warning text-dark px-3 py-2"><i class="bi bi-clock-history me-1"></i> Chờ thanh toán</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge text-bg-danger px-3 py-2"><i class="bi bi-x-circle-fill me-1"></i> Đã hủy</span>
                                            <c:if test="${b.paymentStatus == 'PAID'}">
                                                <c:choose>
                                                    <c:when test="${b.refundStatus == 'COMPLETED'}">
                                                        <span class="badge text-bg-success px-2 py-2"><i class="bi bi-check-circle me-1"></i> Đã hoàn tiền</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge text-bg-warning text-dark px-2 py-2"><i class="bi bi-hourglass-split me-1"></i> Chờ hoàn tiền</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:if>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <h3 class="h5 fw-bold text-dark mb-2">${b.tour.name}</h3>
                            <div class="d-flex flex-wrap gap-2 gap-sm-4 text-secondary small mb-3">
                                <span><i class="bi bi-calendar3 text-primary"></i> Ngày KH: <strong>${b.tour.startDate}</strong></span>
                                <span><i class="bi bi-cash-stack text-success"></i> Giá tour: <strong class="text-danger fs-6"><fmt:formatNumber value="${b.tour.price}" type="number" maxFractionDigits="0"/> VNĐ</strong></span>
                                <c:if test="${not empty b.paymentStatus}">
                                    <span><i class="bi bi-credit-card text-info"></i> Thanh toán: <strong class="${b.paymentStatus == 'PAID' ? 'text-success' : 'text-warning'}">${b.paymentStatus == 'PAID' ? 'Đã thanh toán' : 'Chờ thanh toán'}</strong></span>
                                </c:if>
                            </div>

                            <div class="pt-3 border-top d-flex justify-content-between align-items-center flex-wrap gap-2">
                                <small class="text-secondary"><i class="bi bi-info-circle me-1"></i> Khách đặt: ${sessionScope.user.fullName}</small>

                                <div class="d-flex gap-2 flex-wrap">
                                    <c:if test="${b.status == 'PENDING'}">
                                        <button type="button" class="btn btn-success btn-sm fw-bold px-3 rounded-pill shadow-sm" data-bs-toggle="modal" data-bs-target="#payModal_${b.id}" onclick="openModal('payModal_${b.id}')">
                                            <i class="bi bi-qr-code-scan me-1"></i> Thanh Toán qua BIDV
                                        </button>
                                    </c:if>

                                    <c:if test="${b.status == 'CONFIRMED' || b.status == 'COMPLETED'}">
                                        <a href="${pageContext.request.contextPath}/contract?bookingId=${b.id}" target="_blank" class="btn btn-outline-info btn-sm fw-bold px-3 rounded-pill">
                                            <i class="bi bi-file-earmark-text-fill me-1"></i> Hợp đồng điện tử
                                        </a>
                                        <button type="button" class="btn btn-primary btn-sm fw-bold px-3 rounded-pill shadow-sm" data-bs-toggle="modal" data-bs-target="#ticketModal_${b.id}" onclick="openModal('ticketModal_${b.id}')">
                                            <i class="bi bi-printer-fill me-1"></i> In Vé / Tải PDF
                                        </button>
                                        <button type="button" class="btn btn-warning btn-sm fw-bold px-3 rounded-pill text-dark" data-bs-toggle="modal" data-bs-target="#reviewModal_${b.id}" onclick="openModal('reviewModal_${b.id}')">
                                            <i class="bi bi-star-fill text-dark me-1"></i> Đánh giá chuyến đi
                                        </button>
                                    </c:if>


                                    <c:if test="${b.status == 'PENDING' || b.status == 'CONFIRMED'}">
                                        <button type="button" class="btn btn-outline-danger btn-sm fw-bold px-3 rounded-pill" data-bs-toggle="modal" data-bs-target="#cancelModal_${b.id}" onclick="openModal('cancelModal_${b.id}')">
                                            <i class="bi bi-x-circle me-1"></i> Hủy & Yêu cầu hoàn tiền
                                        </button>
                                    </c:if>
                                </div>
                            </div>
                        </div>

                        <!-- Modal Thanh Toán VietQR Chuyên Nghiệp -->
                        <c:if test="${b.status == 'PENDING'}">
                            <div class="modal fade" id="payModal_${b.id}" tabindex="-1" aria-labelledby="payModalLabel_${b.id}" aria-hidden="true">
                                <div class="modal-dialog modal-dialog-centered modal-lg">
                                    <div class="modal-content rounded-4 border-0 shadow-lg overflow-hidden">
                                        <!-- Header Modal -->
                                        <div class="modal-header text-white p-3 px-4 d-flex justify-content-between align-items-center" style="background: linear-gradient(135deg, #0d6efd 0%, #0a58ca 100%);">
                                            <div class="d-flex align-items-center gap-2">
                                                <i class="bi bi-qr-code-scan fs-4"></i>
                                                <div>
                                                    <h5 class="modal-title fw-bold mb-0" id="payModalLabel_${b.id}">Thanh Toán Đơn Đặt Tour #BK-${b.id}</h5>
                                                    <small class="opacity-75">${b.tour.name}</small>
                                                </div>
                                            </div>
                                            <div class="d-flex align-items-center gap-2">
                                                <span class="badge text-bg-warning text-dark font-monospace small px-2 py-1"><i class="bi bi-lightning-charge-fill me-1"></i> Auto Check 24/7</span>
                                                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" onclick="closeModal('payModal_${b.id}')" aria-label="Đóng"></button>
                                            </div>
                                        </div>

                                        <div class="modal-body p-4">
                                            <div class="row g-4 align-items-center">
                                                <!-- Cột 1: Mã QR VietQR BIDV -->
                                                <div class="col-md-5 text-center border-end-md">
                                                    <fmt:formatNumber value="${b.tour.price}" pattern="#" maxFractionDigits="0" var="cleanAmount"/>
                                                    <div class="p-3 bg-white rounded-3 border shadow-sm d-inline-block">
                                                        <img src="https://img.vietqr.io/image/BIDV-8821900777-compact2.png?amount=${cleanAmount}&addInfo=BK${b.id}&accountName=VU%20DUY%20THAI%20SON"
                                                             alt="Mã QR Thanh toán VietQR BIDV"
                                                             class="img-fluid rounded"
                                                             style="max-width: 220px; width: 100%; height: auto;"
                                                             onerror="this.onerror=null; this.src='https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=BIDV%20STK:8821900777%20-%20VU%20DUY%20THAI%20SON%20-%20So%20tien:%20${cleanAmount}%20VND%20-%20Noi%20dung:%20BK${b.id}';">
                                                    </div>
                                                    <div class="mt-2 text-muted extra-small">
                                                        <i class="bi bi-shield-check text-success me-1"></i> Quét bằng BIDV SmartBanking hoặc bất kỳ App Ngân hàng / Wallet nào
                                                    </div>
                                                </div>

                                                <!-- Cột 2: Thông tin tài khoản & nút sao chép -->
                                                <div class="col-md-7">
                                                    <h6 class="fw-bold text-dark mb-3"><i class="bi bi-bank me-2 text-primary"></i> Thông Tin Chuyển Khoản Trực Tiếp</h6>

                                                    <div class="bg-light p-3 rounded-3 border mb-3">
                                                        <div class="d-flex justify-content-between align-items-center mb-2 pb-2 border-bottom">
                                                            <span class="text-secondary small">Ngân hàng:</span>
                                                            <strong class="text-dark"><span class="badge text-bg-primary fs-6">BIDV</span> Ngân hàng TMCP Đầu tư và Phát triển VN</strong>
                                                        </div>

                                                        <div class="d-flex justify-content-between align-items-center mb-2 pb-2 border-bottom">
                                                            <span class="text-secondary small">Số tài khoản:</span>
                                                            <div class="d-flex align-items-center">
                                                                <strong class="text-primary font-monospace fs-5 me-2">8821900777</strong>
                                                                <button type="button" class="btn btn-sm btn-outline-primary py-0 px-2" id="copyStkBtn_${b.id}" onclick="copyToClipboard('8821900777', 'copyStkBtn_${b.id}')">
                                                                    <i class="bi bi-copy me-1"></i> Chép
                                                                </button>
                                                            </div>
                                                        </div>

                                                        <div class="d-flex justify-content-between align-items-center mb-2 pb-2 border-bottom">
                                                            <span class="text-secondary small">Chủ tài khoản:</span>
                                                            <strong class="text-dark">VU DUY THAI SON</strong>
                                                        </div>

                                                        <div class="d-flex justify-content-between align-items-center mb-2 pb-2 border-bottom">
                                                            <span class="text-secondary small">Số tiền:</span>
                                                            <strong class="text-danger fs-5"><fmt:formatNumber value="${b.tour.price}" type="number" maxFractionDigits="0"/> VNĐ</strong>
                                                        </div>

                                                        <div class="d-flex justify-content-between align-items-center">
                                                            <span class="text-secondary small">Nội dung CK:</span>
                                                            <div class="d-flex align-items-center">
                                                                <span class="badge text-bg-warning font-monospace fs-6 px-3 py-1 me-2">BK${b.id}</span>
                                                                <button type="button" class="btn btn-sm btn-outline-warning text-dark py-0 px-2" id="copyMemoBtn_${b.id}" onclick="copyToClipboard('BK${b.id}', 'copyMemoBtn_${b.id}')">
                                                                    <i class="bi bi-copy me-1"></i> Chép
                                                                </button>
                                                            </div>
                                                        </div>
                                                    </div>

                                                    <div class="alert alert-primary py-2 px-3 small mb-2 d-flex align-items-center justify-content-between flex-wrap gap-2 border-0 shadow-sm" style="background: #eef2ff;">
                                                        <div class="d-flex align-items-center gap-2">
                                                            <div class="spinner-grow spinner-grow-sm text-primary" role="status"></div>
                                                            <span class="text-primary fw-semibold">Hệ thống đang tự động lắng nghe giao dịch chuyển khoản...</span>
                                                        </div>
                                                        <button type="button" class="btn btn-sm btn-outline-primary rounded-pill px-3 py-1 fw-bold" onclick="checkPaymentStatus('BK${b.id}', ${b.id})">
                                                            <i class="bi bi-arrow-repeat me-1"></i> Kiểm tra tiền về
                                                        </button>
                                                    </div>

                                                    <!-- VNPay Test Card Info Hint -->
                                                    <div class="p-2 bg-white rounded border small text-secondary">
                                                        <div class="fw-bold text-danger mb-1"><i class="bi bi-credit-card-2-front me-1"></i> Thẻ test VNPay Sandbox (Dành cho kiểm thử):</div>
                                                        <div>Ngân hàng: <strong>NCB</strong> | Số thẻ: <code>9704198526191432198</code></div>
                                                        <div>Tên: <strong>NGUYEN VAN A</strong> | Hạn thẻ: <strong>07/15</strong> | OTP: <strong>123456</strong></div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="modal-footer bg-light p-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
                                            <button type="button" class="btn btn-outline-secondary rounded-pill px-3" data-bs-dismiss="modal" onclick="closeModal('payModal_${b.id}')">Đóng</button>
                                            <div class="d-flex gap-2 flex-wrap align-items-center">
                                                <c:if test="${sessionScope.user.role == 'ADMIN' || sessionScope.user.role == 'MANAGER'}">
                                                    <button type="button" class="btn btn-outline-warning text-dark fw-bold rounded-pill px-3 shadow-sm btn-sm" onclick="adminForceApprove('${b.id}', 'BK${b.id}')" title="Chỉ hiển thị cho Quản trị viên để test duyệt đơn mà không cần chuyển khoản">
                                                        <i class="bi bi-shield-check me-1"></i> [Admin] Duyệt Test
                                                    </button>
                                                </c:if>
                                                <a href="${pageContext.request.contextPath}/payment/vnpay-create?bookingId=${b.id}" class="btn btn-danger fw-bold rounded-pill px-3 shadow-sm d-flex align-items-center gap-1">
                                                    <i class="bi bi-credit-card-fill me-1"></i> Cổng VNPay
                                                </a>
                                                <button type="button" class="btn btn-success fw-bold rounded-pill px-3 shadow-sm" onclick="checkPaymentStatus('BK${b.id}', ${b.id})">
                                                    <i class="bi bi-check-circle-fill me-1"></i> Tôi Đã Chuyển Khoản Xong
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:if>

                        <!-- Popup Modal Hủy Tour -->
                        <div class="modal fade" id="cancelModal_${b.id}" tabindex="-1" aria-labelledby="cancelModalLabel_${b.id}" aria-hidden="true">
                            <div class="modal-dialog modal-dialog-centered">
                                <div class="modal-content rounded-4 border-0 shadow">
                                    <div class="modal-header bg-danger text-white">
                                        <h5 class="modal-title fw-bold" id="cancelModalLabel_${b.id}"><i class="bi bi-exclamation-triangle-fill me-2"></i> Xác nhận Hủy & Hoàn tiền</h5>
                                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" onclick="closeModal('cancelModal_${b.id}')" aria-label="Đóng"></button>
                                    </div>
                                    <div class="modal-body p-4">
                                        <div class="alert alert-warning mb-4">
                                            <p class="fw-bold mb-1"><i class="bi bi-shield-exclamation me-1"></i> Chính sách hoàn tiền:</p>
                                            <p class="small mb-0">Khi bạn xác nhận hủy tour, yêu cầu sẽ được gửi tới Ban quản trị. Số tiền đã thanh toán (nếu có) sẽ được chuyển hoàn về tài khoản của bạn trong vòng <strong>3-5 ngày làm việc</strong>.</p>
                                        </div>

                                        <form action="${pageContext.request.contextPath}/user/bookings" method="post">
                                            <input type="hidden" name="action" value="cancel">
                                            <input type="hidden" name="bookingId" value="${b.id}">
                                            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">

                                            <div class="form-check mb-4">
                                                <input class="form-check-input" type="checkbox" id="agree_${b.id}" onchange="toggleCancelButton(${b.id})">
                                                <label class="form-check-label small text-dark fw-semibold" for="agree_${b.id}">
                                                    Tôi đã đọc và hoàn toàn đồng ý với chính sách hủy & hoàn tiền.
                                                </label>
                                            </div>

                                            <button type="submit" class="btn btn-danger w-100 fw-bold py-2 rounded-3" id="confirmBtn_${b.id}" disabled>
                                                <i class="bi bi-x-circle me-1"></i> Xác Nhận Hủy Tour #BK-${b.id}
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Modal Viết Đánh Giá Chuyến Đi -->
                        <c:if test="${b.status == 'CONFIRMED' || b.status == 'COMPLETED'}">
                            <div class="modal fade" id="reviewModal_${b.id}" tabindex="-1" aria-labelledby="reviewModalLabel_${b.id}" aria-hidden="true">
                                <div class="modal-dialog modal-dialog-centered">
                                    <div class="modal-content rounded-4 border-0 shadow">
                                        <div class="modal-header bg-warning text-dark">
                                            <h5 class="modal-title fw-bold" id="reviewModalLabel_${b.id}"><i class="bi bi-star-fill me-2"></i> Đánh giá chuyến đi</h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal" onclick="closeModal('reviewModal_${b.id}')" aria-label="Đóng"></button>
                                        </div>
                                        <div class="modal-body p-4">
                                            <h6 class="fw-bold text-dark mb-1">${b.tour.name}</h6>
                                            <p class="text-secondary small mb-3">Mã đơn: #BK-${b.id} &bull; Khởi hành: ${b.tour.startDate}</p>
                                            <form action="${pageContext.request.contextPath}/user/bookings" method="post">
                                                <input type="hidden" name="action" value="review">
                                                <input type="hidden" name="tourId" value="${b.tourId}">
                                                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">

                                                <div class="mb-3">
                                                    <label class="form-label fw-semibold">Bạn đánh giá chuyến đi mấy sao?</label>
                                                    <select name="rating" class="form-select" required>
                                                        <option value="5" selected>⭐⭐⭐⭐⭐ (5 sao - Tuyệt vời)</option>
                                                        <option value="4">⭐⭐⭐⭐ (4 sao - Rất tốt)</option>
                                                        <option value="3">⭐⭐⭐ (3 sao - Bình thường)</option>
                                                        <option value="2">⭐⭐ (2 sao - Cần cải thiện)</option>
                                                        <option value="1">⭐ (1 sao - Thất vọng)</option>
                                                    </select>
                                                </div>

                                                <div class="mb-3">
                                                    <label class="form-label fw-semibold">Chia sẻ cảm nhận của bạn:</label>
                                                    <textarea name="comment" class="form-control" rows="3" placeholder="Nhập cảm nhận về khách sạn, hướng dẫn viên, lịch trình..." required maxlength="500"></textarea>
                                                </div>

                                                <button type="submit" class="btn btn-warning w-100 fw-bold py-2 rounded-3 text-dark">
                                                    <i class="bi bi-send-fill me-1"></i> Gửi đánh giá ngay
                                                </button>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:if>

                        <!-- Modal Xuất Vé Du Lịch Điện Tử / E-Ticket -->
                        <c:if test="${b.status == 'CONFIRMED' || b.status == 'COMPLETED'}">
                            <div class="modal fade" id="ticketModal_${b.id}" tabindex="-1" aria-labelledby="ticketModalLabel_${b.id}" aria-hidden="true">
                                <div class="modal-dialog modal-dialog-centered modal-lg">
                                    <div class="modal-content rounded-4 border-0 shadow-lg overflow-hidden">
                                        <div class="modal-header bg-dark text-white p-3 px-4">
                                            <div class="d-flex align-items-center gap-2">
                                                <i class="bi bi-airplane-engines-fill text-warning fs-4"></i>
                                                <div>
                                                    <h5 class="modal-title fw-bold mb-0" id="ticketModalLabel_${b.id}">Vé Du Lịch Điện Tử (E-Ticket)</h5>
                                                    <small class="text-white-50">Mã vé: #ETICKET-BK-${b.id}</small>
                                                </div>
                                            </div>
                                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" onclick="closeModal('ticketModal_${b.id}')" aria-label="Đóng"></button>
                                        </div>

                                        <div class="modal-body p-4 bg-light">
                                            <!-- Khung Vé Có Thể In Ấn (Printable Ticket Area) -->
                                            <div class="printable-ticket-area eticket-card" id="printableTicket_${b.id}">
                                                <!-- Ticket Header -->
                                                <div class="eticket-header d-flex justify-content-between align-items-center flex-wrap gap-2">
                                                    <div>
                                                        <h4 class="fw-bold mb-0 text-white"><i class="bi bi-compass-fill text-warning me-2"></i> TourBooking Vietnam</h4>
                                                        <small class="text-white-50">Hệ thống đặt tour du lịch trọn gói cao cấp</small>
                                                    </div>
                                                    <div class="text-end">
                                                        <span class="badge text-bg-success px-3 py-2 fs-6 rounded-pill"><i class="bi bi-check-circle-fill me-1"></i> VÉ HỢP LỆ (CONFIRMED)</span>
                                                        <small class="d-block text-white-50 mt-1">Mã xác thực: BK-${b.id}</small>
                                                    </div>
                                                </div>

                                                <!-- Ticket Body -->
                                                <div class="eticket-body">
                                                    <div class="row g-4">
                                                        <div class="col-md-8">
                                                            <h5 class="fw-bold text-dark mb-3">${b.tour.name}</h5>
                                                            
                                                            <div class="row g-3 small mb-3">
                                                                <div class="col-sm-6">
                                                                    <div class="p-2 bg-light rounded border">
                                                                        <span class="text-secondary d-block">Hành khách:</span>
                                                                        <strong class="text-dark fs-6">${sessionScope.user.fullName}</strong>
                                                                    </div>
                                                                </div>
                                                                <div class="col-sm-6">
                                                                    <div class="p-2 bg-light rounded border">
                                                                        <span class="text-secondary d-block">Tài khoản đặt:</span>
                                                                        <strong class="text-dark">@${sessionScope.user.username}</strong>
                                                                    </div>
                                                                </div>
                                                                <div class="col-sm-6">
                                                                    <div class="p-2 bg-light rounded border">
                                                                        <span class="text-secondary d-block">Ngày khởi hành:</span>
                                                                        <strong class="text-primary fs-6"><i class="bi bi-calendar3 me-1"></i> ${b.tour.startDate}</strong>
                                                                    </div>
                                                                </div>
                                                                <div class="col-sm-6">
                                                                    <div class="p-2 bg-light rounded border">
                                                                        <span class="text-secondary d-block">Thời lượng:</span>
                                                                        <strong class="text-dark"><i class="bi bi-clock me-1"></i> 3 ngày 2 đêm</strong>
                                                                    </div>
                                                                </div>
                                                            </div>

                                                            <div class="alert alert-warning py-2 small mb-0">
                                                                <i class="bi bi-exclamation-circle-fill me-1"></i> <strong>Lưu ý:</strong> Quý khách vui lòng có mặt tại điểm đón trước giờ khởi hành 30 phút và xuất trình vé này cùng CCCD/Hộ chiếu.
                                                            </div>
                                                        </div>

                                                        <!-- QR Check-in & Stub -->
                                                        <div class="col-md-4 text-center border-start-md">
                                                            <div class="eticket-qr-box">
                                                                <img src="https://api.qrserver.com/v1/create-qr-code/?size=140x140&data=TOURBOOKING-TICKET-BK-${b.id}-USER-${sessionScope.user.id}" 
                                                                     alt="QR Check-in" 
                                                                     class="img-fluid rounded mb-2" 
                                                                     style="width: 140px; height: 140px;">
                                                                <small class="d-block fw-bold text-dark">QUÉT ĐỂ CHECK-IN</small>
                                                                <small class="text-secondary extra-small font-monospace">#BK-${b.id}</small>
                                                            </div>
                                                            <div class="mt-3">
                                                                <small class="text-secondary d-block">Tổng thanh toán</small>
                                                                <strong class="text-danger fs-5"><fmt:formatNumber value="${b.tour.price}" type="number" maxFractionDigits="0"/> VNĐ</strong>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>

                                                <!-- Ticket Stub Footer -->
                                                <div class="eticket-stub d-flex justify-content-between align-items-center flex-wrap gap-2 text-secondary small">
                                                    <span><i class="bi bi-shield-check text-success me-1"></i> Bản quyền TourBooking Vietnam &bull; Hotline: 1900 6868</span>
                                                    <span>Ngày in vé: <fmt:formatDate value="<%= new java.util.Date() %>" pattern="dd/MM/yyyy HH:mm" /></span>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="modal-footer bg-light p-3">
                                            <button type="button" class="btn btn-outline-secondary rounded-pill px-4" data-bs-dismiss="modal" onclick="closeModal('ticketModal_${b.id}')">Đóng</button>
                                            <button type="button" class="btn btn-primary fw-bold rounded-pill px-4 shadow-sm" onclick="window.print()">
                                                <i class="bi bi-printer-fill me-1"></i> In Vé / Xuất File PDF
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:if>
                    </c:forEach>

                    <c:if test="${empty myBookings}">
                        <div class="card border-0 shadow-sm p-5 text-center">
                            <i class="bi bi-ticket-perforated fs-1 text-secondary mb-3"></i>
                            <h3 class="h5 fw-bold text-secondary">Bạn chưa có đơn đặt tour nào</h3>
                            <p class="text-secondary small mb-4">Khám phá ngay hàng trăm chuyến du lịch hấp dẫn.</p>
                            <div>
                                <a href="${pageContext.request.contextPath}/tours" class="btn btn-primary rounded-pill px-4">Xem Danh Sách Tour</a>
                            </div>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>

        <!-- Khối Tóm Tắt Đơn Hàng -->
        <div class="col-lg-4">
            <div class="card border-0 shadow-sm rounded-4 p-4 sticky-top" style="top: 20px;">
                <h3 class="h5 fw-bold text-dark mb-3"><i class="bi bi-receipt me-2 text-primary"></i> Tổng Kết Đơn Hàng</h3>

                <div class="d-flex justify-content-between mb-2 text-secondary small">
                    <span>Số lượng đơn:</span>
                    <strong class="text-dark">${myBookings.size()} chuyến</strong>
                </div>
                <div class="d-flex justify-content-between mb-2 text-secondary small">
                    <span>Phí dịch vụ:</span>
                    <span class="text-success fw-bold">Miễn phí</span>
                </div>

                <hr>

                <div class="d-flex justify-content-between align-items-center mb-4">
                    <span class="fw-bold text-dark">TRẠNG THÁI:</span>
                    <span class="h6 fw-bold text-success mb-0">Đã đồng bộ</span>
                </div>

                <a href="${pageContext.request.contextPath}/tours" class="btn btn-primary w-100 fw-bold py-2 rounded-3">
                    + Đặt Thêm Tour Khác
                </a>
            </div>
        </div>
    </div>

</div>

<!-- Footer -->
<jsp:include page="/user/footer.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    let activePaymentPollInterval = null;

    function startPaymentPolling(bookingId, bookingCode) {
        stopPaymentPolling();
        activePaymentPollInterval = setInterval(async () => {
            try {
                const res = await fetch('${pageContext.request.contextPath}/payment/check?action=checkStatus&bookingId=' + bookingId);
                const data = await res.json();
                if (data && data.isPaid) {
                    stopPaymentPolling();
                    closeModal('payModal_' + bookingId);
                    if (window.Swal) {
                        Swal.fire({
                            icon: 'success',
                            iconColor: '#10b981',
                            title: '<h4 class="fw-bold text-success mb-1">Đã Nhận Tiền & Tự Động Duyệt Đơn!</h4>',
                            html: '<p class="text-secondary mb-2">Hệ thống đã khớp lệnh chuyển khoản cho đơn <strong>#' + bookingCode + '</strong> thành công!</p>' +
                                  '<span class="badge bg-success px-3 py-2 fs-6">ĐÃ XÁC NHẬN (CONFIRMED)</span>',
                            confirmButtonText: '<i class="bi bi-ticket-perforated-fill me-1"></i> Xem vé & Hợp đồng ngay',
                            customClass: {
                                confirmButton: 'btn btn-success rounded-pill px-4 py-2'
                            }
                        }).then(() => {
                            window.location.reload();
                        });
                    } else {
                        alert('Thanh toán thành công! Đơn hàng ' + bookingCode + ' đã được tự động duyệt.');
                        window.location.reload();
                    }
                }
            } catch (e) {
                console.error('Lỗi kiểm tra giao dịch tự động:', e);
            }
        }, 2500);
    }

    function stopPaymentPolling() {
        if (activePaymentPollInterval) {
            clearInterval(activePaymentPollInterval);
            activePaymentPollInterval = null;
        }
    }

    function openModal(modalId) {
        const modalEl = document.getElementById(modalId);
        if (!modalEl) return;
        try {
            if (window.bootstrap && window.bootstrap.Modal) {
                const modalInstance = bootstrap.Modal.getOrCreateInstance(modalEl);
                modalInstance.show();
            } else {
                modalEl.classList.add('show');
                modalEl.style.display = 'block';
                document.body.classList.add('modal-open');
            }
        } catch (err) {
            console.error('Error opening modal:', err);
            modalEl.classList.add('show');
            modalEl.style.display = 'block';
        }

        if (modalId.startsWith('payModal_')) {
            const bId = modalId.replace('payModal_', '');
            startPaymentPolling(bId, 'BK' + bId);
        }
    }

    function closeModal(modalId) {
        const modalEl = document.getElementById(modalId);
        if (!modalEl) return;
        try {
            if (window.bootstrap && window.bootstrap.Modal) {
                const modalInstance = bootstrap.Modal.getInstance(modalEl);
                if (modalInstance) modalInstance.hide();
            }
            modalEl.classList.remove('show');
            modalEl.style.display = 'none';
            document.body.classList.remove('modal-open');
            document.querySelectorAll('.modal-backdrop').forEach(el => el.remove());
        } catch (err) {
            console.error('Error closing modal:', err);
        }

        if (modalId.startsWith('payModal_')) {
            stopPaymentPolling();
        }
    }

    function toggleCancelButton(id) {
        const checkbox = document.getElementById('agree_' + id);
        const confirmBtn = document.getElementById('confirmBtn_' + id);
        if (checkbox && confirmBtn) {
            confirmBtn.disabled = !checkbox.checked;
        }
    }

    function copyToClipboard(text, elementId) {
        if (navigator.clipboard && window.isSecureContext) {
            navigator.clipboard.writeText(text).then(() => showCopiedFeedback(elementId)).catch(() => fallbackCopy(text, elementId));
        } else {
            fallbackCopy(text, elementId);
        }
    }

    function fallbackCopy(text, elementId) {
        const textArea = document.createElement("textarea");
        textArea.value = text;
        textArea.style.position = "fixed";
        textArea.style.left = "-999999px";
        document.body.appendChild(textArea);
        textArea.select();
        try {
            document.execCommand('copy');
            showCopiedFeedback(elementId);
        } catch (err) {
            console.error('Fallback copy failed', err);
        }
        document.body.removeChild(textArea);
    }

    function showCopiedFeedback(elementId) {
        const btn = document.getElementById(elementId);
        if (btn) {
            const originalHTML = btn.innerHTML;
            btn.innerHTML = '<i class="bi bi-check-lg"></i> Đã chép!';
            btn.classList.remove('btn-outline-primary', 'btn-outline-warning');
            btn.classList.add('btn-success', 'text-white');
            setTimeout(() => {
                btn.innerHTML = originalHTML;
                btn.classList.remove('btn-success', 'text-white');
                btn.classList.add('btn-outline-primary');
            }, 2000);
        }
    }

    /**
     * Kiểm tra đối soát trạng thái thanh toán thực tế từ Ngân hàng
     */
    async function checkPaymentStatus(bookingCode, bookingId) {
        if (!window.Swal) {
            window.location.reload();
            return;
        }

        Swal.fire({
            title: '<h5 class="fw-bold text-primary mb-1">Đang Kiểm Tra Giao Dịch...</h5>',
            html: '<div class="text-center py-3">' +
                  '  <div class="spinner-border text-primary mb-3" style="width: 2.5rem; height: 2.5rem;" role="status"></div>' +
                  '  <p class="text-secondary small mb-1">Đang đối soát tín hiệu chuyển khoản cho đơn <strong>#' + bookingCode + '</strong></p>' +
                  '  <small class="text-muted">Vui lòng chờ trong giây lát...</small>' +
                  '</div>',
            allowOutsideClick: false,
            showConfirmButton: false
        });

        try {
            const response = await fetch('${pageContext.request.contextPath}/payment/check?action=autoReconcile&bookingId=' + bookingId);
            const data = await response.json();

            if (data && data.isPaid) {
                Swal.fire({
                    icon: 'success',
                    iconColor: '#10b981',
                    title: '<h4 class="fw-bold text-success mb-1">Đã Nhận Tiền & Xác Nhận Thành Công!</h4>',
                    html: '<div class="text-start px-1 py-1">' +
                          '  <p class="text-secondary mb-3">' +
                          '    Hệ thống đã nhận được tiền chuyển khoản cho đơn hàng ' +
                          '    <span class="badge text-bg-warning font-monospace fs-6 px-2 py-1">#' + bookingCode + '</span>.' +
                          '  </p>' +
                          '  <div class="p-3 bg-light rounded-3 border mb-2 small">' +
                          '    <div class="text-success fw-bold mb-1"><i class="bi bi-check-circle-fill me-1"></i> Trạng thái: ĐÃ XÁC NHẬN (CONFIRMED)</div>' +
                          '    <div class="text-muted"><i class="bi bi-ticket-perforated me-1"></i> Vé du lịch điện tử & Hợp đồng đã được kích hoạt.</div>' +
                          '  </div>' +
                          '</div>',
                    confirmButtonText: '<i class="bi bi-ticket-perforated-fill me-1"></i> Xem Vé & Hợp Đồng Ngay',
                    customClass: {
                        confirmButton: 'btn btn-success rounded-pill px-4 py-2 fw-bold shadow-sm'
                    }
                }).then(() => {
                    window.location.reload();
                });
            } else {
                Swal.fire({
                    icon: 'warning',
                    iconColor: '#f59e0b',
                    title: '<h5 class="fw-bold text-warning mb-1">Chưa Nhận Được Tiền Chuyển Khoản</h5>',
                    html: '<div class="text-start px-1 py-1">' +
                          '  <p class="text-secondary mb-3 small">' +
                          '    Hệ thống ngân hàng chưa ghi nhận biến động số dư cho đơn hàng ' +
                          '    <strong class="text-dark">#' + bookingCode + '</strong>.' +
                          '  </p>' +
                          '  <div class="p-3 bg-light rounded-3 border small mb-2">' +
                          '    <div class="fw-bold text-dark mb-1"><i class="bi bi-info-circle me-1 text-primary"></i> Quý khách lưu ý:</div>' +
                          '    <ul class="mb-0 ps-3 text-muted">' +
                          '      <li>Vui lòng kiểm tra đã chuyển đúng nội dung: <strong class="text-danger">BK' + bookingId + '</strong></li>' +
                          '      <li>Nếu quý khách vừa chuyển, ngân hàng có thể mất <strong>30s - 1 phút</strong> để truyền tín hiệu Webhook.</li>' +
                          '      <li>Hệ thống đang chạy lắng nghe tự động, khi tiền vào modal sẽ tự duyệt ngay lập tức.</li>' +
                          '    </ul>' +
                          '  </div>' +
                          '</div>',
                    confirmButtonText: '<i class="bi bi-arrow-repeat me-1"></i> Đã Hiểu, Tôi Sẽ Đợi',
                    customClass: {
                        confirmButton: 'btn btn-primary rounded-pill px-4 py-2 fw-bold'
                    }
                });
            }
        } catch (err) {
            Swal.fire({
                icon: 'error',
                title: '<h5 class="fw-bold text-danger mb-1">Lỗi Kết Nối</h5>',
                text: 'Không thể kết nối đến máy chủ đối soát. Vui lòng thử lại sau giây lát!',
                confirmButtonText: 'Đóng'
            });
        }
    }

    /**
     * Dành riêng cho Quản trị viên / Manager duyệt test đơn hàng ngay
     */
    async function adminForceApprove(bookingId, bookingCode) {
        if (!confirm('[QUẢN TRỊ VIÊN] Bạn có chắc muốn duyệt test đơn hàng #' + bookingCode + ' mà không cần chờ chuyển khoản thực tế?')) {
            return;
        }

        try {
            const response = await fetch('${pageContext.request.contextPath}/payment/check?action=autoReconcile&staffOverride=true&bookingId=' + bookingId);
            const data = await response.json();
            if (data && data.success) {
                alert('Quản trị viên đã duyệt đơn #' + bookingCode + ' thành công!');
                window.location.reload();
            } else {
                alert(data ? data.message : 'Duyệt thất bại.');
            }
        } catch (e) {
            alert('Lỗi kết nối máy chủ.');
        }
    }
</script>
</body>
</html>
