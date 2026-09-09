<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<section id="ai-config" class="tab-section">
    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
        <div>
            <h2 class="h4 fw-bold mb-1"><i class="bi bi-robot text-teal me-2" style="color:#0d9488;"></i> Quản Lý Trợ Lý Ảo AI & API Key Gemini</h2>
            <p class="text-secondary small mb-0">Quản lý API Key, chọn mô hình AI ưu tiên (Gemini 3.6 / 3.7 / 3.8) và kiểm tra kết nối thời gian thực.</p>
        </div>
        <div class="d-flex align-items-center gap-2">
            <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-3 py-2 fw-semibold">
                <i class="bi bi-cpu-fill me-1"></i> RAG Catalog Đồng Bộ Tự Động
            </span>
        </div>
    </div>

    <div class="row g-4">
        <%-- Form Cấu hình chính --%>
        <div class="col-lg-8">
            <div class="card border-0 shadow-sm rounded-4 p-4 mb-4">
                <h5 class="fw-bold mb-3 text-dark d-flex align-items-center gap-2">
                    <i class="bi bi-sliders2 text-primary"></i> Cấu Hình Google Gemini API Key
                </h5>
                <form id="aiConfigForm" action="${pageContext.request.contextPath}/admin/ai-config" method="post">
                    <input type="hidden" name="action" value="save">

                    <%-- Google Gemini API Key Input --%>
                    <div class="mb-3">
                        <label class="form-label fw-bold text-dark">
                            Google Gemini API Key: <span class="text-danger">*</span>
                        </label>
                        <div class="input-group">
                            <span class="input-group-text bg-light border-end-0"><i class="bi bi-key-fill text-warning"></i></span>
                            <input type="password" id="geminiApiKeyInput" name="apiKey" class="form-control border-start-0 font-monospace" 
                                   value="${not empty aiSettings.gemini_api_key ? aiSettings.gemini_api_key : ''}" 
                                   required placeholder="Nhập khóa API Gemini (VD: AIzaSy...)" autocomplete="off">
                            <button class="btn btn-outline-secondary" type="button" id="toggleKeyVisibilityBtn" onclick="toggleKeyVisibility()" title="Hiện/Ẩn Key">
                                <i class="bi bi-eye" id="eyeIcon"></i>
                            </button>
                            <button class="btn btn-outline-primary" type="button" onclick="pasteKeyFromClipboard()" title="Dán từ Clipboard">
                                <i class="bi bi-clipboard-plus"></i> Dán
                            </button>
                        </div>
                        <small class="text-secondary mt-1 d-block">
                            <i class="bi bi-info-circle me-1"></i> Khóa API được lưu an toàn trong cơ sở dữ liệu và tự động nạp cho Trợ lý ảo phục vụ khách hàng.
                        </small>
                    </div>

                    <div class="row g-3 mb-3">
                        <%-- Mô hình AI --%>
                        <div class="col-md-6">
                            <label class="form-label fw-bold text-dark">Mô hình AI ưu tiên:</label>
                            <select name="model" id="geminiModelSelect" class="form-select">
                                <option value="gemini-3.6-flash" ${aiSettings.gemini_model == 'gemini-3.6-flash' || empty aiSettings.gemini_model ? 'selected' : ''}>
                                    🌟 gemini-3.6-flash (Khuyên dùng - Nhanh & Chuẩn)
                                </option>
                                <option value="gemini-3.7-flash" ${aiSettings.gemini_model == 'gemini-3.7-flash' ? 'selected' : ''}>
                                    ⚡ gemini-3.7-flash (Thế hệ mới nhất)
                                </option>
                                <option value="gemini-3.8-flash" ${aiSettings.gemini_model == 'gemini-3.8-flash' ? 'selected' : ''}>
                                    🚀 gemini-3.8-flash (Tốc độ cao)
                                </option>
                                <option value="gemini-flash-latest" ${aiSettings.gemini_model == 'gemini-flash-latest' ? 'selected' : ''}>
                                    🔄 gemini-flash-latest (Bản Flash mới nhất)
                                </option>
                            </select>
                        </div>

                        <%-- Tên hiển thị trợ lý AI --%>
                        <div class="col-md-6">
                            <label class="form-label fw-bold text-dark">Tên hiển thị của Trợ lý AI:</label>
                            <input type="text" name="assistantName" class="form-control" 
                                   value="${not empty aiSettings.ai_assistant_name ? aiSettings.ai_assistant_name : 'Nhân viên AI Hịn Hò'}" 
                                   required maxlength="60" placeholder="VD: Nhân viên AI Hịn Hò">
                        </div>
                    </div>

                    <%-- Hộp hiển thị kết quả Test Connection --%>
                    <div id="testResultBox" class="alert d-none mb-3 py-2 px-3 small rounded-3" role="alert"></div>

                    <div class="d-flex align-items-center gap-2 pt-2">
                        <button type="submit" class="btn btn-primary rounded-pill px-4 fw-bold shadow-sm" style="background:#0d9488;border-color:#0d9488;">
                            <i class="bi bi-save-fill me-1"></i> Lưu Cấu Hình AI
                        </button>
                        <button type="button" id="testKeyBtn" class="btn btn-outline-success rounded-pill px-4 fw-semibold" onclick="testGeminiConnection()">
                            <i class="bi bi-lightning-charge-fill me-1"></i> Kiểm Tra Kết Nối Key
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <%-- Panel Hướng dẫn & Giám sát tính năng AI --%>
        <div class="col-lg-4">
            <div class="card border-0 shadow-sm rounded-4 p-4 mb-4 bg-light">
                <h6 class="fw-bold text-dark mb-3"><i class="bi bi-stars text-warning me-1"></i> Trợ Lý Ảo Du Lịch Gemini 3.6</h6>
                <ul class="list-unstyled small mb-3 text-secondary d-flex flex-column gap-2">
                    <li class="d-flex align-items-start gap-2">
                        <i class="bi bi-check2-circle text-success fs-6 mt-0"></i>
                        <span><strong>Tự động RAG:</strong> AI tự động đọc 34+ tour du lịch, giá vé, giảm giá và ngày khởi hành thực tế trong DB.</span>
                    </li>
                    <li class="d-flex align-items-start gap-2">
                        <i class="bi bi-check2-circle text-success fs-6 mt-0"></i>
                        <span><strong>Tư vấn khuyến mãi:</strong> Nắm rõ các voucher đang mở bán để hướng dẫn khách áp dụng mã.</span>
                    </li>
                    <li class="d-flex align-items-start gap-2">
                        <i class="bi bi-check2-circle text-success fs-6 mt-0"></i>
                        <span><strong>Live Chat Hybrid:</strong> Khách hàng có thể chuyển đổi qua lại giữa AI và Nhân viên tư vấn trực tiếp bất kỳ lúc nào.</span>
                    </li>
                </ul>
                <hr class="my-2">
                <h6 class="fw-bold text-dark mt-2 mb-2" style="font-size:0.85rem;"><i class="bi bi-link-45deg me-1"></i> Cách lấy API Key miễn phí:</h6>
                <p class="small text-secondary mb-2">Truy cập Google AI Studio để tạo khóa API miễn phí trong vài giây:</p>
                <a href="https://aistudio.google.com/app/apikey" target="_blank" rel="noopener noreferrer" class="btn btn-sm btn-outline-dark rounded-pill w-100">
                    <i class="bi bi-box-arrow-up-right me-1"></i> Mở Google AI Studio
                </a>
            </div>
        </div>
    </div>
</section>

<script>
    function toggleKeyVisibility() {
        const input = document.getElementById('geminiApiKeyInput');
        const icon = document.getElementById('eyeIcon');
        if (!input || !icon) return;
        if (input.type === 'password') {
            input.type = 'text';
            icon.className = 'bi bi-eye-slash';
        } else {
            input.type = 'password';
            icon.className = 'bi bi-eye';
        }
    }

    async function pasteKeyFromClipboard() {
        try {
            const text = await navigator.clipboard.readText();
            if (text) {
                const input = document.getElementById('geminiApiKeyInput');
                if (input) input.value = text.trim();
            }
        } catch(e) {
            alert('Vui lòng cấp quyền truy cập clipboard trên trình duyệt để dán nhanh.');
        }
    }

    async function testGeminiConnection() {
        const keyInput = document.getElementById('geminiApiKeyInput');
        const modelSelect = document.getElementById('geminiModelSelect');
        const btn = document.getElementById('testKeyBtn');
        const box = document.getElementById('testResultBox');
        if (!keyInput || !btn || !box) return;

        const apiKey = keyInput.value.trim();
        const model = modelSelect ? modelSelect.value : 'gemini-3.6-flash';

        if (!apiKey) {
            box.className = 'alert alert-warning py-2 px-3 small rounded-3';
            box.innerHTML = '<i class="bi bi-exclamation-triangle-fill me-1"></i> Vui lòng nhập API Key trước khi kiểm tra.';
            box.classList.remove('d-none');
            return;
        }

        const originalBtnHtml = btn.innerHTML;
        btn.disabled = true;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1" role="status"></span> Đang ping Gemini...';
        box.className = 'alert alert-info py-2 px-3 small rounded-3';
        box.innerHTML = '<i class="bi bi-arrow-repeat spin me-1"></i> Đang gửi gói tin kiểm tra kết nối tới Google Gemini (' + model + ')...';
        box.classList.remove('d-none');

        try {
            const res = await fetch('${pageContext.request.contextPath}/admin/ai-config?action=test&apiKey=' + encodeURIComponent(apiKey) + '&model=' + encodeURIComponent(model));
            const data = await res.json();

            if (data.success) {
                box.className = 'alert alert-success py-2 px-3 small rounded-3 shadow-sm';
                box.innerHTML = '<i class="bi bi-check-circle-fill text-success fs-6 me-1"></i> <strong>Tuyệt vời!</strong> ' 
                    + data.message + ' (Độ trễ phản hồi: <strong>' + (data.latencyMs || 0) + 'ms</strong>)';
            } else {
                box.className = 'alert alert-danger py-2 px-3 small rounded-3 shadow-sm';
                box.innerHTML = '<i class="bi bi-x-circle-fill text-danger fs-6 me-1"></i> <strong>Lỗi kết nối:</strong> ' + data.message;
            }
        } catch(err) {
            box.className = 'alert alert-danger py-2 px-3 small rounded-3 shadow-sm';
            box.innerHTML = '<i class="bi bi-x-circle-fill text-danger fs-6 me-1"></i> Không thể kết nối tới máy chủ để kiểm tra: ' + err.message;
        } finally {
            btn.disabled = false;
            btn.innerHTML = originalBtnHtml;
        }
    }
</script>
