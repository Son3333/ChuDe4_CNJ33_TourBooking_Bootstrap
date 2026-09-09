<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hợp Đồng Du Lịch Điện Tử | ${contract.contractCode}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css" rel="stylesheet">
    <style>
        body {
            background-color: #f1f5f9;
            color: #1e293b;
            font-family: 'Times New Roman', Times, serif, system-ui;
        }
        .contract-paper {
            max-width: 860px;
            margin: 2rem auto;
            background: #ffffff;
            padding: 3rem;
            border-radius: 12px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.08);
            border: 1px solid #e2e8f0;
        }
        .contract-header-text {
            text-align: center;
            line-height: 1.4;
        }
        .contract-title {
            font-size: 1.5rem;
            font-weight: 800;
            text-align: center;
            margin: 1.5rem 0 0.5rem 0;
            color: #0f172a;
            text-transform: uppercase;
        }
        .stamp-box {
            border: 2px solid #dc2626;
            color: #dc2626;
            padding: 8px 16px;
            display: inline-block;
            font-weight: bold;
            font-size: 0.85rem;
            transform: rotate(-5deg);
            border-radius: 6px;
            text-transform: uppercase;
        }
        .qr-box {
            text-align: center;
            padding: 10px;
            background: #f8fafc;
            border: 1px dashed #cbd5e1;
            border-radius: 8px;
        }
        @media print {
            body { background: #fff !important; }
            .contract-paper { box-shadow: none !important; border: none !important; margin: 0 !important; width: 100% !important; max-width: 100% !important; padding: 1.5cm !important; }
            .no-print { display: none !important; }
        }
    </style>
</head>
<body class="py-4">

<div class="container no-print mb-3 text-center">
    <button onclick="window.print()" class="btn btn-primary px-4 rounded-pill shadow-sm me-2">
        <i class="bi bi-printer-fill me-1"></i> In / Xuất PDF Hợp Đồng
    </button>
    <button onclick="window.close(); history.back();" class="btn btn-outline-secondary px-4 rounded-pill">
        <i class="bi bi-arrow-left me-1"></i> Quay lại
    </button>
</div>

<div class="contract-paper">
    <div class="contract-header-text mb-4">
        <h5 class="fw-bold mb-1">CỘNG HÒA XÃ HỘI CHỦ NGHĨA VIỆT NAM</h5>
        <div class="fw-bold mb-1">Độc lập - Tự do - Hạnh phúc</div>
        <div class="text-secondary small">---o0o---</div>
    </div>

    <div class="d-flex justify-content-between align-items-center mb-3">
        <span class="text-secondary small">Mã hợp đồng: <strong class="text-primary">${contract.contractCode}</strong></span>
        <span class="badge text-bg-success px-3 py-2"><i class="bi bi-shield-fill-check me-1"></i> ĐÃ XÁC THỰC SỐ</span>
    </div>

    <div class="contract-title">HỢP ĐỒNG DỊCH VỤ DU LỊCH LỮ HÀNH ĐIỆN TỬ</div>
    <div class="text-center text-secondary small mb-4">
        (Số: ${contract.contractCode}/HĐDL-TOURBOOKING)
    </div>

    <p class="small text-muted mb-3 fst-italic">
        - Căn cứ Bộ luật Dân sự nước Cộng hòa Xã hội Chủ nghĩa Việt Nam số 91/2015/QH13;<br>
        - Căn cứ Luật Du lịch số 09/2017/QH14 và các quy định pháp luật hiện hành liên quan;<br>
        Hôm nay, ngày <fmt:formatDate value="${contract.signedAt}" pattern="dd 'tháng' MM 'năm' yyyy"/>, chúng tôi gồm có:
    </p>

    <div class="mb-3">
        <strong class="text-uppercase text-primary">BÊN A: BÊN CUNG CẤP DỊCH VỤ (CÔNG TY LỮ HÀNH)</strong>
        <table class="table table-sm table-borderless small mt-1 mb-2">
            <tr><td style="width: 140px;">Tên đơn vị:</td><td><strong>CÔNG TY CỔ PHẦN DU LỊCH & LỮ HÀNH TOURBOOKING EAUT</strong></td></tr>
            <tr><td>Mã số thuế:</td><td>0108998822</td></tr>
            <tr><td>Địa chỉ:</td><td>Tòa nhà Công nghệ EAUT, Đường Trịnh Văn Bô, Nam Từ Liêm, Hà Nội</td></tr>
            <tr><td>Đại diện pháp luật:</td><td>Ông Nguyễn Văn Quản Lý - Giám đốc Điều hành</td></tr>
            <tr><td>Tài khoản thanh toán:</td><td><strong>8821900777</strong> - Ngân hàng TMCP Đầu tư & Phát triển VN (BIDV) - Chủ TK: <strong>VŨ DUY THÁI SƠN</strong></td></tr>
            <tr><td>Hotline hỗ trợ:</td><td>1900 6868 - contact@tourbooking.vn</td></tr>
        </table>
    </div>

    <div class="mb-4">
        <strong class="text-uppercase text-primary">BÊN B: BÊN SỬ DỤNG DỊCH VỤ (KHÁCH HÀNG ĐẠI DIỆN)</strong>
        <table class="table table-sm table-borderless small mt-1 mb-2">
            <tr><td style="width: 140px;">Đại diện bên B:</td><td><strong>${not empty contract.customerName ? contract.customerName : 'Khách hàng'}</strong></td></tr>
            <tr><td>Mã đơn đặt:</td><td>#BK-${contract.bookingId}</td></tr>
            <tr><td>Gói tour tham gia:</td><td><strong>${contract.tourName}</strong></td></tr>
            <tr><td>Tổng giá trị hợp đồng:</td><td><strong class="text-danger fs-6"><fmt:formatNumber value="${contract.totalAmount}" type="number" maxFractionDigits="0"/> VNĐ</strong> (Đã bao gồm VAT, bảo hiểm và chi phí tour)</td></tr>
        </table>
    </div>

    <div class="mb-4">
        <h6 class="fw-bold text-dark border-bottom pb-2"><i class="bi bi-people-fill text-primary me-2"></i> DANH SÁCH HÀNH KHÁCH THAM GIA ĐOÀN</h6>
        <c:choose>
            <c:when test="${not empty passengers}">
                <div class="table-responsive">
                    <table class="table table-bordered table-sm small align-middle">
                        <thead class="table-light">
                            <tr>
                                <th class="text-center" style="width: 40px;">STT</th>
                                <th>Họ và tên</th>
                                <th class="text-center">Giới tính</th>
                                <th class="text-center">Ngày sinh</th>
                                <th>CCCD / Hộ chiếu</th>
                                <th>Số điện thoại</th>
                                <th class="text-center">Điểm danh</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="p" items="${passengers}" varStatus="status">
                                <tr>
                                    <td class="text-center">${status.index + 1}</td>
                                    <td><strong>${p.fullName}</strong></td>
                                    <td class="text-center">${p.gender}</td>
                                    <td class="text-center">${p.birthDate}</td>
                                    <td>${p.idCard}</td>
                                    <td>${p.phone}</td>
                                    <td class="text-center">
                                        <c:choose>
                                            <c:when test="${p.checkedIn}">
                                                <span class="badge text-bg-success"><i class="bi bi-check-lg"></i> Đã check-in</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge text-bg-secondary">Chờ khởi hành</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:when>
            <c:otherwise>
                <p class="small text-muted fst-italic">Thông tin hành khách cập nhật theo đại diện đặt tour.</p>
            </c:otherwise>
        </c:choose>
    </div>

    <div class="mb-4">
        <h6 class="fw-bold text-dark border-bottom pb-2">ĐIỀU KHOẢN HỢP ĐỒNG & BẢO HIỂM DU LỊCH</h6>
        <div class="small text-secondary" style="line-height: 1.6;">
            ${contract.termsContent}
            <br><br>
            <strong>1. Trách nhiệm Bên A:</strong> Cung cấp đúng và đủ các dịch vụ theo lịch trình tour; đảm bảo xe du lịch chất lượng cao, khách sạn tiện nghi tiêu chuẩn và hướng dẫn viên xuyên suốt chuyến đi; mua bảo hiểm tai nạn du lịch mức đền bù tối đa 100.000.000 VNĐ/vụ.<br>
            <strong>2. Trách nhiệm Bên B:</strong> Cung cấp danh sách hành khách chính xác; có mặt tại điểm hẹn đúng giờ quy định; tuân thủ quy chế an toàn điểm đến.<br>
            <strong>3. Chính sách hủy hoãn & Hoàn tiền:</strong> Trường hợp Bên B hủy trước 07 ngày khởi hành, hoàn trả 80% giá trị hợp đồng. Hủy trong vòng 03 - 06 ngày hoàn trả 50%.
        </div>
    </div>

    <div class="row pt-4 border-top align-items-center">
        <div class="col-sm-4 text-center mb-3 mb-sm-0">
            <div class="qr-box d-inline-block">
                <img src="https://api.qrserver.com/v1/create-qr-code/?size=110x110&data=${contract.contractCode}" alt="Mã QR tra cứu hợp đồng" class="img-fluid" style="width: 100px; height: 100px;">
                <div class="extra-small text-muted mt-1" style="font-size: 0.72rem;">Quét để xác thực hợp đồng điện tử</div>
            </div>
        </div>

        <div class="col-sm-4 text-center">
            <div class="fw-bold small mb-1">ĐẠI DIỆN BÊN B</div>
            <div class="text-secondary small fst-italic mb-3">(Đã ký xác nhận điện tử)</div>
            <div class="text-primary fw-bold">${not empty contract.customerName ? contract.customerName : 'Khách hàng'}</div>
        </div>

        <div class="col-sm-4 text-center">
            <div class="fw-bold small mb-1">ĐẠI DIỆN BÊN A</div>
            <div class="text-secondary small fst-italic mb-3">(Ký số & Đóng dấu điện tử)</div>
            <div class="stamp-box mb-1">
                TOURBOOKING EAUT<br>
                <small style="font-size: 0.65rem;">VERIFIED E-SIGNATURE</small>
            </div>
            <div class="small text-muted"><fmt:formatDate value="${contract.signedAt}" pattern="dd/MM/yyyy HH:mm"/></div>
        </div>
    </div>
</div>

</body>
</html>

