<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<style>
    /* ================= LIVE CHAT & AI GEMINI 3.6 STYLES ================= */
    .live-chat-root { position: fixed; right: 24px; bottom: 24px; z-index: 2100; font-family: system-ui, -apple-system, sans-serif; }
    
    /* User Launcher Button */
    .user-chat-launcher {
        border: 0; border-radius: 50px; padding: 12px 22px; 
        background: linear-gradient(135deg, #0d9488 0%, #0f766e 50%, #115e59 100%);
        color: #fff; font-weight: 700; font-size: 0.95rem; display: flex; align-items: center; gap: 8px;
        box-shadow: 0 8px 24px rgba(13,148,136,.45); cursor: pointer; 
        transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    }
    .user-chat-launcher:hover { transform: translateY(-3px) scale(1.03); box-shadow: 0 12px 28px rgba(13,148,136,.6); }
    .user-chat-launcher .ai-pulse-badge {
        background: #f59e0b; color: #1e293b; font-size: 0.68rem; font-weight: 800;
        border-radius: 999px; padding: 2px 7px; text-transform: uppercase; letter-spacing: 0.5px;
    }
    .user-chat-launcher .badge-unread { background: #ef4444; color: #fff; font-size: 0.75rem; border-radius: 999px; padding: 2px 7px; }

    /* Chat Panel */
    .chat-panel {
        display: none; position: fixed; right: 24px; bottom: 90px; width: min(420px, calc(100vw - 32px));
        height: min(620px, calc(100vh - 110px)); background: #ffffff; border-radius: 20px;
        box-shadow: 0 20px 50px rgba(15,23,42,.25); border: 1px solid #cbd5e1; overflow: hidden;
        flex-direction: column; z-index: 2105; animation: chatPanelFadeIn 0.25s ease-out;
    }
    .chat-panel.is-open { display: flex; }
    @keyframes chatPanelFadeIn { from { opacity: 0; transform: translateY(12px) scale(0.97); } to { opacity: 1; transform: translateY(0) scale(1); } }

    /* Chat Header */
    .chat-header {
        padding: 14px 18px; background: linear-gradient(135deg, #17324d 0%, #0f2238 100%);
        color: #fff; display: flex; justify-content: space-between; align-items: center;
    }
    .chat-header .status-dot { width: 9px; height: 9px; border-radius: 50%; display: inline-block; margin-right: 5px; }
    .chat-header .status-dot.active { background: #10b981; box-shadow: 0 0 8px #10b981; }
    .chat-header-btn { border: 0; background: rgba(255,255,255,0.15); color: #fff; width: 30px; height: 30px; border-radius: 50%; display: flex; align-items: center; justify-content: center; cursor: pointer; transition: background 0.2s; }
    .chat-header-btn:hover { background: rgba(255,255,255,0.3); }

    /* Mode Switching Bar (Tabs 2 Luồng Chat Rõ Ràng) */
    .chat-mode-bar {
        display: flex; gap: 8px; padding: 8px 12px; background: #f1f5f9; border-bottom: 1px solid #e2e8f0;
    }
    .chat-mode-btn {
        flex: 1; border: 1px solid #cbd5e1; background: #ffffff; color: #475569;
        padding: 8px 10px; border-radius: 12px; font-size: 0.82rem; font-weight: 700;
        cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 6px;
        transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
    }
    .chat-mode-btn:hover { background: #e2e8f0; color: #0f172a; }
    .chat-mode-btn.active.mode-ai {
        background: linear-gradient(135deg, #0d9488 0%, #0f766e 100%);
        color: #ffffff; border-color: #0f766e; box-shadow: 0 4px 12px rgba(13,148,136,.35);
    }
    .chat-mode-btn.active.mode-human {
        background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);
        color: #ffffff; border-color: #1d4ed8; box-shadow: 0 4px 12px rgba(37,99,235,.35);
    }
    .tab-unread-dot {
        width: 8px; height: 8px; background: #ef4444; border-radius: 50%;
        display: inline-block; margin-left: 4px; animation: tabDotPulse 1.5s infinite;
    }
    @keyframes tabDotPulse { 0%, 100% { opacity: 1; transform: scale(1); } 50% { opacity: 0.3; transform: scale(1.4); } }

    /* Mode Banner Info */
    .chat-mode-banner {
        font-size: 0.78rem; padding: 7px 14px; background: #f0fdf4; color: #166534;
        border-bottom: 1px solid #dcfce7; display: flex; align-items: center; justify-content: space-between;
    }
    .chat-mode-banner.human { background: #eff6ff; color: #1e40af; border-bottom-color: #dbeafe; }

    .chat-inactivity-banner {
        background: #fef2f2; border-bottom: 1px solid #fecaca; padding: 8px 14px;
        color: #991b1b; font-size: 0.8rem; display: flex; align-items: center; justify-content: space-between;
    }

    /* Messages Container & Bubbles */
    .chat-messages-container {
        flex: 1; overflow-y: auto; padding: 14px; background: #f8fafc;
        display: flex; flex-direction: column; gap: 10px; scroll-behavior: smooth;
    }

    .msg-bubble { 
        max-width: 86%; padding: 10px 14px; border-radius: 16px; 
        font-size: 0.88rem; line-height: 1.48; word-break: break-word; 
    }
    .msg-bubble.mine { 
        align-self: flex-end; background: #17324d; color: #ffffff; 
        border-bottom-right-radius: 4px; box-shadow: 0 2px 8px rgba(23,50,77,0.2); 
    }
    .msg-bubble.theirs { 
        align-self: flex-start; background: #f1f5f9; color: #1e293b; 
        border-bottom-left-radius: 4px; border: 1px solid #e2e8f0;
    }
    .msg-bubble.ai-bubble {
        align-self: flex-start; background: #ffffff; color: #1e293b;
        border: 1.5px solid #a7f3d0; border-bottom-left-radius: 4px;
        box-shadow: 0 3px 12px rgba(16,185,129,0.1);
    }
    .msg-bubble.admin-bubble {
        align-self: flex-start; background: #eff6ff; color: #1e293b;
        border: 1.5px solid #bfdbfe; border-bottom-left-radius: 4px;
        box-shadow: 0 3px 12px rgba(59,130,246,0.1);
    }
    .msg-bubble small { display: block; margin-top: 4px; font-size: 0.68rem; opacity: 0.75; }
    .msg-bubble.mine small { text-align: right; color: #cbd5e1; }

    /* Markdown inside bubbles */
    .msg-bubble strong { font-weight: 700; color: inherit; }
    .msg-bubble ul { margin: 6px 0 6px 18px; padding: 0; }
    .msg-bubble li { margin-bottom: 4px; }
    .msg-bubble hr { margin: 8px 0; border-color: rgba(0,0,0,0.08); }

    /* Typing indicator */
    .typing-indicator {
        align-self: flex-start; display: flex; align-items: center; gap: 5px;
        padding: 8px 14px; background: #ffffff; border: 1px solid #a7f3d0;
        border-radius: 16px; border-bottom-left-radius: 4px; box-shadow: 0 2px 6px rgba(16,185,129,0.1);
    }
    .typing-dot {
        width: 6px; height: 6px; background: #059669; border-radius: 50%;
        animation: typingBounce 1.4s infinite ease-in-out both;
    }
    .typing-dot:nth-child(2) { animation-delay: -0.32s; }
    .typing-dot:nth-child(3) { animation-delay: -0.16s; }
    @keyframes typingBounce {
        0%, 80%, 100% { transform: scale(0); opacity: 0.4; }
        40% { transform: scale(1); opacity: 1; }
    }

    /* Quick suggestions */
    .chat-quick-replies { 
        padding: 8px 12px; background: #ffffff; border-top: 1px solid #f1f5f9; 
        display: flex; gap: 6px; overflow-x: auto; white-space: nowrap; scrollbar-width: none; 
    }
    .chat-quick-replies::-webkit-scrollbar { display: none; }
    .chat-quick-chip { 
        font-size: 0.75rem; font-weight: 500; background: #f1f5f9; color: #475569; 
        border: 1px solid #e2e8f0; border-radius: 20px; padding: 4px 10px; cursor: pointer; transition: all 0.2s; 
    }
    .chat-quick-chip:hover { background: #0d9488; color: #fff; border-color: #0d9488; }
    .chat-quick-chip.chip-human:hover { background: #2563eb; color: #fff; border-color: #2563eb; }

    /* Input bar */
    .chat-input-bar { padding: 10px 14px; background: #ffffff; border-top: 1px solid #e2e8f0; display: flex; gap: 8px; align-items: center; }
    .chat-input-bar textarea { flex: 1; resize: none; min-height: 38px; max-height: 80px; border-radius: 12px; font-size: 0.88rem; padding: 8px 12px; border: 1px solid #cbd5e1; }
    .chat-input-bar textarea:focus { outline: none; border-color: #0d9488; box-shadow: 0 0 0 2px rgba(13,148,136,0.2); }
    .chat-send-btn { 
        width: 40px; height: 40px; border-radius: 12px; border: 0; 
        background: linear-gradient(135deg, #0d9488 0%, #0f766e 100%); 
        color: #fff; display: flex; align-items: center; justify-content: center; cursor: pointer; transition: all 0.2s; 
    }
    .chat-send-btn:hover { background: #e76f3c; transform: scale(1.05); }

    /* ================= ADMIN FLOATING CHAT BUBBLES SYSTEM ================= */
    .admin-bubbles-container {
        position: fixed; right: 24px; bottom: 24px; z-index: 2200;
        display: flex; flex-direction: column; align-items: flex-end; gap: 10px;
    }
    .admin-master-bubble {
        width: 62px; height: 62px; border-radius: 50%; background: linear-gradient(135deg, #1e3a8a 0%, #0f172a 100%);
        color: #fff; display: flex; align-items: center; justify-content: center; font-size: 1.6rem;
        box-shadow: 0 8px 25px rgba(15,23,42,.45); cursor: pointer; position: relative;
        transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275); border: 2px solid #38bdf8;
    }
    .admin-master-bubble:hover { transform: scale(1.1); box-shadow: 0 12px 30px rgba(56,189,248,.4); }
    .admin-badge-count {
        position: absolute; top: -4px; right: -4px; background: #ef4444; color: #fff;
        font-size: 0.75rem; font-weight: 800; border-radius: 999px; min-width: 22px; height: 22px;
        display: flex; align-items: center; justify-content: center; padding: 0 5px; border: 2px solid #fff;
    }
    .admin-customer-bubbles-stack {
        display: flex; flex-direction: column-reverse; gap: 8px; align-items: flex-end;
        max-height: 420px; overflow-y: auto; padding-right: 4px; scrollbar-width: none;
    }
    .customer-bubble-item {
        display: flex; align-items: center; gap: 8px; background: #ffffff; border-radius: 30px;
        padding: 4px 12px 4px 4px; box-shadow: 0 4px 16px rgba(15,23,42,.15);
        border: 2px solid #e2e8f0; cursor: pointer; transition: all 0.25s ease;
        position: relative; max-width: 210px;
    }
    .customer-bubble-item:hover, .customer-bubble-item.active {
        transform: translateX(-6px); border-color: #3b82f6; background: #eff6ff;
        box-shadow: 0 6px 20px rgba(59,130,246,.25);
    }
    .customer-avatar-circle {
        width: 36px; height: 36px; border-radius: 50%; background: #17324d; color: #fff;
        display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 0.85rem;
        position: relative; flex-shrink: 0;
    }
    .customer-status-badge {
        width: 10px; height: 10px; border-radius: 50%; border: 2px solid #fff;
        position: absolute; bottom: -1px; right: -1px;
    }
    .customer-status-badge.online { background: #10b981; }
    .customer-status-badge.offline { background: #94a3b8; }
    .customer-bubble-name { font-size: 0.82rem; font-weight: 600; color: #1e293b; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

    /* Facebook Messenger Floating Button */
    .fb-floating-btn {
        width: 48px; height: 48px; border-radius: 50%; background: linear-gradient(135deg, #0084ff 0%, #00c6ff 100%);
        color: #fff; display: flex; align-items: center; justify-content: center; font-size: 1.4rem;
        box-shadow: 0 6px 20px rgba(0,132,255,0.4); text-decoration: none; transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
    }
    .fb-floating-btn:hover { transform: translateY(-3px) scale(1.08); box-shadow: 0 10px 25px rgba(0,132,255,0.55); color: #fff; }

    /* Admin Active Conversation Box */
    .admin-chat-hub-panel {
        display: none; position: fixed; right: 98px; bottom: 24px; width: min(450px, calc(100vw - 120px));
        height: min(620px, calc(100vh - 50px)); background: #ffffff; border-radius: 20px;
        box-shadow: 0 20px 60px rgba(15,23,42,.3); border: 1px solid #cbd5e1; z-index: 2210;
        overflow: hidden; flex-direction: column; animation: chatPanelFadeIn 0.2s ease-out;
    }
    .admin-chat-hub-panel.is-open { display: flex; }
    .customer-info-bar {
        background: #f1f5f9; padding: 8px 16px; border-bottom: 1px solid #e2e8f0;
        display: flex; justify-content: space-between; align-items: center; font-size: 0.82rem;
    }
</style>

<div id="liveChatApp" 
     data-role="${not empty sessionScope.user ? sessionScope.user.role : 'GUEST'}" 
     data-user-id="${not empty sessionScope.user ? sessionScope.user.id : 0}" 
     data-user-name="${not empty sessionScope.user ? sessionScope.user.fullName : ''}" 
     data-context-path="${pageContext.request.contextPath}">
    
    <c:choose>
        <%-- ==================== 1. NẾU LÀ ADMIN (LIVE CHAT MULTI-CUSTOMER HUB) ==================== --%>
        <c:when test="${sessionScope.user.role == 'ADMIN'}">
            <div class="admin-bubbles-container" id="adminBubblesRoot">
                <%-- Cột danh sách bong bóng từng khách hàng --%>
                <div id="adminCustomerBubblesStack" class="admin-customer-bubbles-stack"></div>

                <%-- Bong bóng chính điều khiển (Master Admin Chat Bubble) --%>
                <div id="adminMasterBubble" class="admin-master-bubble" title="Trung tâm Live Chat & Giám sát Tư vấn viên AI">
                    <i class="bi bi-headset"></i>
                    <span id="adminTotalUnreadBadge" class="admin-badge-count d-none">0</span>
                </div>

                <%-- Khung chat tương tác với khách hàng đang chọn --%>
                <section id="adminChatHubPanel" class="admin-chat-hub-panel">
                    <header class="chat-header">
                        <div class="d-flex align-items-center gap-2">
                            <div id="adminCurrentAvatar" class="customer-avatar-circle" style="background:#3b82f6;">KH</div>
                            <div>
                                <strong id="adminCurrentCustomerName" class="d-block lh-1">Chưa chọn khách hàng</strong>
                                <small id="adminCurrentCustomerSub" class="text-white-50">Chọn bong bóng khách hàng để chat</small>
                            </div>
                        </div>
                        <div class="d-flex align-items-center gap-1">
                            <a href="https://www.facebook.com/kasa.pro.666/?locale=vi_VN" target="_blank" rel="noopener noreferrer" class="btn btn-sm btn-primary rounded-pill px-2 py-0 extra-small text-white text-decoration-none d-flex align-items-center gap-1 shadow-sm me-1" style="background:#1877f2; border:none;" title="Mở trang Facebook cá nhân / Fanpage">
                                <i class="bi bi-facebook"></i> <span>Trang FB</span>
                            </a>
                            <button type="button" id="adminChatHubClose" class="chat-header-btn" title="Thu nhỏ"><i class="bi bi-dash-lg"></i></button>
                        </div>
                    </header>

                    <div class="customer-info-bar">
                        <span id="adminCustomerStatusText"><i class="bi bi-circle-fill text-success me-1"></i> Trực tuyến</span>
                        <span class="text-secondary small" id="adminCustomerLastActive">Vừa xong</span>
                    </div>

                    <div id="adminChatMessages" class="chat-messages-container">
                        <div class="text-center text-secondary small py-5">
                            <i class="bi bi-people-fill fs-2 text-primary mb-2 d-block"></i>
                            Vui lòng chọn một khách hàng từ danh sách bong bóng để xem toàn bộ lịch sử tư vấn và can thiệp live chat.
                        </div>
                    </div>

                    <%-- Mẫu câu trả lời nhanh cho Admin --%>
                    <div class="chat-quick-replies">
                        <span class="chat-quick-chip" onclick="adminQuickReply('Dạ em chào quý khách! Em là nhân viên tư vấn của TourBooking, em có thể hỗ trợ gì cho mình ạ?')">👋 Chào khách</span>
                        <span class="chat-quick-chip" onclick="adminQuickReply('Đơn đặt tour của quý khách đã được duyệt và giữ chỗ thành công ạ!')">✅ Đã duyệt</span>
                        <span class="chat-quick-chip" onclick="adminQuickReply('Quý khách vui lòng chuyển khoản theo mã QR đơn hàng để hệ thống tự động xuất vé ngay nhé.')">🏦 Hướng dẫn CK</span>
                        <span class="chat-quick-chip" onclick="adminQuickReply('Quý khách có thể nhắn tin trực tiếp qua Facebook Admin: https://www.facebook.com/kasa.pro.666/?locale=vi_VN để được hỗ trợ 24/7 ạ!')">💬 Gửi FB Admin</span>
                    </div>

                    <form id="adminChatForm" class="chat-input-bar">
                        <textarea id="adminChatInput" placeholder="Nhập câu trả lời trực tiếp cho khách..." rows="1" maxlength="1000" required></textarea>
                        <button type="submit" class="chat-send-btn" title="Gửi câu trả lời cho khách"><i class="bi bi-send-fill"></i></button>
                    </form>
                </section>
            </div>
        </c:when>

        <%-- ==================== 2. NẾU LÀ KHÁCH HÀNG HOẶC KHÁCH VÃNG LAI ==================== --%>
        <c:otherwise>
            <div class="live-chat-root d-flex align-items-center gap-2">
                <%-- Nút tắt mở nhanh Facebook Messenger --%>
                <a href="https://www.facebook.com/kasa.pro.666/?locale=vi_VN" target="_blank" rel="noopener noreferrer" class="fb-floating-btn" title="Nhắn tin trực tiếp qua Facebook / Messenger 24/7">
                    <i class="bi bi-messenger"></i>
                </a>

                <%-- Nút bấm mở chat Nhân viên AI Hịn Hò & Live Chat --%>
                <%-- Nút bấm mở chat Nhân viên AI Hịn Hò & Live Chat --%>
                <button type="button" id="userChatLauncher" class="user-chat-launcher" title="Bấm để chat với Nhân viên AI Hịn Hò">
                    <i class="bi bi-robot fs-5"></i>
                    <span>Nhân viên AI Hịn Hò</span>
                    <span class="ai-pulse-badge">Tư vấn 24/7</span>
                    <span id="userUnreadBadge" class="badge-unread d-none">1</span>
                </button>

                <section id="userChatPanel" class="chat-panel" aria-label="Khung tư vấn trực tuyến Nhân viên AI Hịn Hò & Live Chat">
                    <header class="chat-header">
                        <div class="d-flex align-items-center gap-2">
                            <div class="position-relative">
                                <div class="rounded-circle bg-white text-dark d-flex align-items-center justify-content-center shadow-sm" style="width:38px;height:38px;font-size:1.2rem;">
                                    <i class="bi bi-robot text-teal" style="color:#0d9488;"></i>
                                </div>
                            </div>
                            <div>
                                <strong class="d-block lh-1">Nhân viên AI Hịn Hò</strong>
                                <small class="text-white-50"><span class="status-dot active"></span> Sẵn sàng 24/7 (Trực tuyến)</small>
                            </div>
                        </div>
                        <div class="d-flex align-items-center gap-1">
                            <button type="button" id="userClearChatBtn" class="chat-header-btn" title="Làm mới / Xóa cuộc trò chuyện"><i class="bi bi-trash3"></i></button>
                            <a href="https://www.facebook.com/kasa.pro.666/?locale=vi_VN" target="_blank" rel="noopener noreferrer" class="btn btn-sm btn-primary rounded-pill px-2 py-0 extra-small text-white text-decoration-none d-flex align-items-center gap-1 shadow-sm" style="background:#1877f2; border:none;" title="Chat qua Facebook Messenger 24/7">
                                <i class="bi bi-facebook"></i> <span>FB Admin</span>
                            </a>
                            <button type="button" id="userChatCloseBtn" class="chat-header-btn" title="Đóng"><i class="bi bi-x-lg"></i></button>
                        </div>
                    </header>

                    <%-- Thanh chuyển đổi 2 luồng Chat tách biệt rõ ràng --%>
                    <div class="chat-mode-bar">
                        <button type="button" id="tabAiBtn" class="chat-mode-btn active mode-ai" onclick="switchCustomerTab('AI')">
                            <i class="bi bi-robot"></i> Trợ lý AI (24/7)
                        </button>
                        <button type="button" id="tabHumanBtn" class="chat-mode-btn" onclick="switchCustomerTab('HUMAN')">
                            <i class="bi bi-headset"></i> Tư vấn viên (Người thật)
                            <span id="tabHumanUnreadDot" class="tab-unread-dot d-none"></span>
                        </button>
                    </div>

                    <%-- Banner thông tin phân định rõ luồng --%>
                    <div id="bannerAi" class="chat-mode-banner">
                        <span><i class="bi bi-stars text-warning me-1"></i> <strong>Trợ lý AI 24/7:</strong> Tư vấn tour, giá vé & nhận voucher tức thì.</span>
                    </div>
                    <div id="bannerHuman" class="chat-mode-banner human d-none">
                        <span><i class="bi bi-headset text-primary me-1"></i> <strong>Nhân viên tư vấn (Người thật):</strong> Trực tiếp hỗ trợ. AI không can thiệp.</span>
                    </div>

                    <c:choose>
                        <c:when test="${empty sessionScope.user}">
                            <%-- Khách chưa đăng nhập --%>
                            <div class="chat-messages-container justify-content-center text-center p-4">
                                <i class="bi bi-person-lock fs-1 text-primary mb-3"></i>
                                <h6 class="fw-bold">Bạn chưa đăng nhập</h6>
                                <p class="text-secondary small mb-3">Vui lòng đăng nhập tài khoản để trò chuyện cùng Nhân viên AI Hịn Hò và đội ngũ tư vấn TourBooking nhé.</p>
                                <div class="d-flex justify-content-center gap-2 flex-wrap">
                                    <a href="${pageContext.request.contextPath}/login" class="btn btn-primary rounded-pill px-3 btn-sm" style="background:#0d9488;border-color:#0d9488;">
                                        <i class="bi bi-box-arrow-in-right me-1"></i> Đăng nhập ngay
                                    </a>
                                    <a href="https://www.facebook.com/kasa.pro.666/?locale=vi_VN" target="_blank" rel="noopener noreferrer" class="btn btn-outline-primary rounded-pill px-3 btn-sm">
                                        <i class="bi bi-facebook me-1"></i> Chat Facebook
                                    </a>
                                </div>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <%-- Khách hàng đã đăng nhập --%>
                            <div id="userInactivityBanner" class="chat-inactivity-banner d-none">
                                <span><i class="bi bi-clock-history me-1"></i> Phiên chat tạm dừng do 10p không tương tác.</span>
                                <button type="button" id="userRestartChatBtn" class="btn btn-sm btn-danger py-0 px-2 rounded-pill extra-small">Bắt đầu lại</button>
                            </div>

                            <%-- ================= LUỒNG 1: TRỢ LÝ AI (24/7) ================= --%>
                            <div id="userChatMessagesAI" class="chat-messages-container">
                                <div class="text-center text-secondary small py-3 chat-welcome-placeholder" id="welcomePlaceholderAI">
                                    <div class="mb-2">
                                        <span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-3 py-1 fw-bold">
                                            <i class="bi bi-robot me-1"></i> Trợ lý Du lịch AI Hịn Hò (24/7)
                                        </span>
                                    </div>
                                    Xin chào <strong><c:out value="${sessionScope.user.fullName}" /></strong>!<br>
                                    Em là <strong>Nhân viên AI Hịn Hò</strong> của TourBooking. Em có thể tư vấn chi tiết mọi tour trong và ngoài nước, kiểm tra vé và gợi ý mã giảm giá tốt nhất cho bạn!<br>
                                    <small class="text-muted d-block mt-2">💡 Bạn muốn gặp nhân viên người thật? Hãy bấm tab <strong>"Tư vấn viên (Người thật)"</strong> phía trên nhé.</small>
                                </div>
                            </div>

                            <%-- ================= LUỒNG 2: TƯ VẤN VIÊN (NGƯỜI THẬT) ================= --%>
                            <div id="userChatMessagesHuman" class="chat-messages-container d-none">
                                <div class="text-center text-secondary small py-3 chat-welcome-placeholder" id="welcomePlaceholderHuman">
                                    <div class="mb-2">
                                        <span class="badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill px-3 py-1 fw-bold">
                                            <i class="bi bi-headset me-1"></i> Tư vấn viên TourBooking (Người thật)
                                        </span>
                                    </div>
                                    Xin chào <strong><c:out value="${sessionScope.user.fullName}" /></strong>!<br>
                                    Đây là luồng <strong>chat trực tiếp với Nhân viên hỗ trợ của TourBooking</strong>.<br>
                                    <span class="text-primary fw-semibold">Robot AI hoàn toàn không trả lời tại kênh này.</span><br>
                                    <small class="text-muted d-block mt-2">Đội ngũ tư vấn viên sẽ đọc và giải đáp câu hỏi của bạn sớm nhất!</small>
                                </div>
                            </div>

                            <%-- Bouncing typing dots khi AI đang phân tích và soạn câu trả lời --%>
                            <div id="aiTypingIndicator" class="typing-indicator d-none ms-3 mb-2">
                                <i class="bi bi-robot text-success me-1"></i>
                                <span class="text-secondary small me-2">Nhân viên AI đang soạn câu trả lời...</span>
                                <span class="typing-dot"></span>
                                <span class="typing-dot"></span>
                                <span class="typing-dot"></span>
                            </div>

                            <%-- Gợi ý nhanh cho luồng AI --%>
                            <div id="quickRepliesAI" class="chat-quick-replies">
                                <span class="chat-quick-chip" onclick="quickSend('Tư vấn giúp tôi các tour du lịch hot nhất hiện nay')">🔥 Tour hot hè 2026</span>
                                <span class="chat-quick-chip" onclick="quickSend('Tư vấn cho anh tour nước ngoài: Thái Lan, Hàn Quốc, Nhật Bản, Châu Âu')">🌏 Tour nước ngoài</span>
                                <span class="chat-quick-chip" onclick="quickSend('Hiện tại có những mã giảm giá (coupon) nào đang dùng được?')">🎟️ Mã giảm giá</span>
                                <span class="chat-quick-chip" onclick="quickSend('Tôi muốn tìm tour giá tiết kiệm dưới 5 triệu đồng')">💰 Tour dưới 5 triệu</span>
                                <span class="chat-quick-chip" onclick="switchCustomerTab('HUMAN')">🎧 Gặp nhân viên</span>
                            </div>

                            <%-- Gợi ý nhanh cho luồng Tư vấn viên Người thật --%>
                            <div id="quickRepliesHuman" class="chat-quick-replies d-none">
                                <span class="chat-quick-chip" onclick="quickSend('Dạ em chào anh/chị tư vấn viên, em cần hỗ trợ đặt tour ạ!')">👋 Chào tư vấn viên</span>
                                <span class="chat-quick-chip" onclick="quickSend('Nhờ anh/chị kiểm tra giúp em số chỗ trống và lịch khởi hành tour với ạ!')">🎫 Kiểm tra chỗ trống</span>
                                <span class="chat-quick-chip" onclick="quickSend('Em cần nhân viên hướng dẫn thanh toán đơn hàng qua VietQR ạ!')">💳 Hướng dẫn thanh toán</span>
                                <span class="chat-quick-chip" onclick="switchCustomerTab('AI')">🤖 Quay lại hỏi AI</span>
                            </div>

                            <form id="userChatForm" class="chat-input-bar">
                                <textarea id="userChatInput" placeholder="Hỏi Trợ lý AI về tour, giá vé, ưu đãi... (Enter để gửi)" rows="1" maxlength="1500" required></textarea>
                                <button type="submit" id="userChatSendBtn" class="chat-send-btn" title="Gửi (Enter)"><i class="bi bi-send-fill"></i></button>
                            </form>
                        </c:otherwise>
                    </c:choose>
                </section>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<script>
    (function() {
        const root = document.getElementById('liveChatApp');
        if (!root) return;

        const role = root.getAttribute('data-role');
        const currentUserId = Number(root.getAttribute('data-user-id'));
        const contextPath = root.getAttribute('data-context-path');
        const baseUrl = contextPath + '/chat';
        const INACTIVITY_TIMEOUT_MS = 10 * 60 * 1000; // 10 phút tự động đóng

        // Chuyển đổi Markdown cơ bản sang HTML an toàn
        function formatMarkdown(text) {
            if (!text) return '';
            let safe = text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
            
            // In đậm **text**
            safe = safe.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>');
            
            // Gạch đầu dòng bullet
            safe = safe.replace(/^[•\-\*]\s+(.*)$/gm, '<li class="mb-1">$1</li>');
            safe = safe.replace(/((?:<li class="mb-1">.*<\/li>\s*)+)/g, '<ul class="ps-3 my-2 mb-2">$1</ul>');
            
            // Danh sách số 1. 2.
            safe = safe.replace(/^\d+\.\s+(.*)$/gm, '<li class="mb-1 ms-3" style="list-style-type: decimal;">$1</li>');
            
            // Đường kẻ ngang ---
            safe = safe.replace(/^---+$/gm, '<hr>');

            // Code highlight `text`
            safe = safe.replace(/`([^`]+)`/g, '<code class="bg-light px-1 py-0 rounded text-danger border">$1</code>');

            // Xuống dòng
            safe = safe.replace(/\n/g, '<br>');
            return safe;
        }

        function escapeHtml(text) {
            if (!text) return '';
            return text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/\n/g, '<br>');
        }

        // Âm thanh thông báo nhẹ nhàng bằng Web Audio API
        function playNotificationSound() {
            try {
                const AudioContextClass = window.AudioContext || window.webkitAudioContext;
                if (!AudioContextClass) return;
                const ctx = new AudioContextClass();
                const osc = ctx.createOscillator();
                const gain = ctx.createGain();
                osc.type = 'sine';
                osc.frequency.setValueAtTime(587.33, ctx.currentTime);
                osc.frequency.setValueAtTime(880, ctx.currentTime + 0.1);
                gain.gain.setValueAtTime(0.12, ctx.currentTime);
                gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.3);
                osc.connect(gain);
                gain.connect(ctx.destination);
                osc.start();
                osc.stop(ctx.currentTime + 0.35);
            } catch(e) {}
        }

        /* =========================================================================
         * 1. LOGIC KHÁCH HÀNG (2 LUỒNG RIÊNG BIỆT: TRỢ LÝ AI & TƯ VẤN VIÊN NGƯỜI THẬT)
         * ========================================================================= */
        if (role !== 'ADMIN') {
            const launcher = document.getElementById('userChatLauncher');
            const panel = document.getElementById('userChatPanel');
            const closeBtn = document.getElementById('userChatCloseBtn');
            const clearBtn = document.getElementById('userClearChatBtn');
            const input = document.getElementById('userChatInput');
            const form = document.getElementById('userChatForm');
            const sendBtn = document.getElementById('userChatSendBtn');
            const unreadBadge = document.getElementById('userUnreadBadge');
            const banner = document.getElementById('userInactivityBanner');
            const restartBtn = document.getElementById('userRestartChatBtn');
            const typingIndicator = document.getElementById('aiTypingIndicator');

            // 2 Tab elements
            const tabAiBtn = document.getElementById('tabAiBtn');
            const tabHumanBtn = document.getElementById('tabHumanBtn');
            const tabHumanUnreadDot = document.getElementById('tabHumanUnreadDot');
            const bannerAi = document.getElementById('bannerAi');
            const bannerHuman = document.getElementById('bannerHuman');
            const boxAi = document.getElementById('userChatMessagesAI');
            const boxHuman = document.getElementById('userChatMessagesHuman');
            const quickAi = document.getElementById('quickRepliesAI');
            const quickHuman = document.getElementById('quickRepliesHuman');

            let activeChannel = 'AI'; // 'AI' hoặc 'HUMAN'
            let isAiThinking = false;
            let isSubmitting = false;
            let lastUserInteraction = Date.now();
            let isSessionClosed = false;

            // Bộ nhớ ID tin nhắn đã render của từng luồng
            const renderedAiIds = new Set();
            const renderedHumanIds = new Set();
            let isAiInitialLoaded = false;
            let isHumanInitialLoaded = false;

            // Chuyển đổi tab 2 luồng chat
            window.switchCustomerTab = async function(channel) {
                if (channel !== 'AI' && channel !== 'HUMAN') channel = 'AI';
                activeChannel = channel;
                recordUserInteraction();

                if (channel === 'AI') {
                    if (tabAiBtn) tabAiBtn.className = 'chat-mode-btn active mode-ai';
                    if (tabHumanBtn) tabHumanBtn.className = 'chat-mode-btn';
                    if (bannerAi) bannerAi.classList.remove('d-none');
                    if (bannerHuman) bannerHuman.classList.add('d-none');
                    if (boxAi) boxAi.classList.remove('d-none');
                    if (boxHuman) boxHuman.classList.add('d-none');
                    if (quickAi) quickAi.classList.remove('d-none');
                    if (quickHuman) quickHuman.classList.add('d-none');
                    if (input) input.placeholder = 'Hỏi Trợ lý AI về tour, giá vé, ưu đãi... (Enter để gửi)';
                    await fetchChannelMessages('AI');
                    if (boxAi) boxAi.scrollTop = boxAi.scrollHeight;
                } else {
                    if (tabAiBtn) tabAiBtn.className = 'chat-mode-btn';
                    if (tabHumanBtn) tabHumanBtn.className = 'chat-mode-btn active mode-human';
                    if (bannerAi) bannerAi.classList.add('d-none');
                    if (bannerHuman) bannerHuman.classList.remove('d-none');
                    if (boxAi) boxAi.classList.add('d-none');
                    if (boxHuman) boxHuman.classList.remove('d-none');
                    if (quickAi) quickAi.classList.add('d-none');
                    if (quickHuman) quickHuman.classList.remove('d-none');
                    if (tabHumanUnreadDot) tabHumanUnreadDot.classList.add('d-none');
                    if (input) input.placeholder = 'Nhập tin nhắn gửi nhân viên tư vấn... (Enter để gửi)';
                    await fetchChannelMessages('HUMAN');
                    if (boxHuman) boxHuman.scrollTop = boxHuman.scrollHeight;
                }
                if (input) input.focus();

                try {
                    await fetch(baseUrl + '?action=setMode&mode=' + encodeURIComponent(channel), {
                        method: 'POST',
                        credentials: 'same-origin'
                    });
                } catch(e) {}
            };

            if (launcher && panel) {
                launcher.addEventListener('click', function() {
                    panel.classList.toggle('is-open');
                    if (panel.classList.contains('is-open')) {
                        if (unreadBadge) unreadBadge.classList.add('d-none');
                        if (currentUserId > 0) {
                            lastUserInteraction = Date.now();
                            fetchChannelMessages(activeChannel);
                            if (input) input.focus();
                        }
                    }
                });
            }

            if (closeBtn && panel) {
                closeBtn.addEventListener('click', function() {
                    panel.classList.remove('is-open');
                });
            }

            if (currentUserId > 0 && form && input) {
                function recordUserInteraction() {
                    lastUserInteraction = Date.now();
                    if (isSessionClosed) {
                        isSessionClosed = false;
                        if (banner) banner.classList.add('d-none');
                        input.disabled = false;
                    }
                }

                function checkCustomerInactivity() {
                    if (!isSessionClosed && (Date.now() - lastUserInteraction >= INACTIVITY_TIMEOUT_MS)) {
                        isSessionClosed = true;
                        if (banner) banner.classList.remove('d-none');
                        panel.classList.remove('is-open');
                    }
                }

                // Xóa lịch sử trò chuyện của đúng luồng đang chọn
                if (clearBtn) {
                    clearBtn.addEventListener('click', async function() {
                        const channelName = activeChannel === 'AI' ? 'Trợ lý AI' : 'Nhân viên tư vấn';
                        if (!confirm('Bạn có muốn xóa toàn bộ lịch sử và làm mới cuộc trò chuyện trong luồng [' + channelName + '] không?')) return;
                        try {
                            const res = await fetch(baseUrl, {
                                method: 'POST',
                                credentials: 'same-origin',
                                headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
                                body: 'action=clearHistory&channel=' + encodeURIComponent(activeChannel)
                            });
                            if (res.ok) {
                                if (activeChannel === 'AI') {
                                    renderedAiIds.clear();
                                    isAiInitialLoaded = true;
                                    if (boxAi) {
                                        boxAi.innerHTML = '<div class="text-center text-secondary small py-4 chat-welcome-placeholder">'
                                            + '<div class="mb-2"><span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-3 py-1 fw-bold"><i class="bi bi-robot me-1"></i> Trợ lý AI (24/7)</span></div>'
                                            + 'Cuộc trò chuyện với AI đã được làm mới! Bạn có thể hỏi bất cứ tour nào nhé.'
                                            + '</div>';
                                    }
                                } else {
                                    renderedHumanIds.clear();
                                    isHumanInitialLoaded = true;
                                    if (boxHuman) {
                                        boxHuman.innerHTML = '<div class="text-center text-secondary small py-4 chat-welcome-placeholder">'
                                            + '<div class="mb-2"><span class="badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill px-3 py-1 fw-bold"><i class="bi bi-headset me-1"></i> Nhân viên tư vấn</span></div>'
                                            + 'Lịch sử trao đổi với nhân viên đã được xóa. Hãy để lại tin nhắn khi bạn cần hỗ trợ nhé.'
                                            + '</div>';
                                    }
                                }
                                if (input) input.focus();
                            }
                        } catch(e) {}
                    });
                }

                // Tải tin nhắn của từng luồng
                async function fetchChannelMessages(channel) {
                    if (channel === 'AI' && isAiThinking) return;
                    const box = channel === 'AI' ? boxAi : boxHuman;
                    const idSet = channel === 'AI' ? renderedAiIds : renderedHumanIds;
                    const isInitial = channel === 'AI' ? !isAiInitialLoaded : !isHumanInitialLoaded;

                    try {
                        const res = await fetch(baseUrl + '?channel=' + encodeURIComponent(channel), { credentials: 'same-origin' });
                        if (!res.ok) return;
                        const data = await res.json();
                        if (!Array.isArray(data)) return;

                        if (isInitial) {
                            if (channel === 'AI') isAiInitialLoaded = true;
                            else isHumanInitialLoaded = true;

                            if (data.length > 0 && box) {
                                const placeholder = box.querySelector('.chat-welcome-placeholder');
                                if (placeholder) placeholder.remove();
                                box.innerHTML = '';
                                data.forEach(function(msg) {
                                    idSet.add(msg.id);
                                    appendMessageToBox(box, msg.content, msg.senderRole, msg.senderId, msg.createdAt, msg.id, false, channel);
                                });
                                box.scrollTop = box.scrollHeight;
                            }
                            return;
                        }

                        // Polling: Chỉ append tin nhắn MỚI chưa từng có trong danh sách
                        let hasNewFromOthers = false;
                        data.forEach(function(msg) {
                            if (idSet.has(msg.id)) return;

                            // Kiểm tra tin nhắn pending của chính user
                            const pendingMsg = box.querySelector('.msg-bubble[data-pending="true"][data-role="' + msg.senderRole + '"]');
                            if (pendingMsg && pendingMsg.getAttribute('data-raw-content') === msg.content) {
                                pendingMsg.removeAttribute('data-pending');
                                pendingMsg.setAttribute('data-msg-id', msg.id);
                                idSet.add(msg.id);
                                return;
                            }

                            // Xóa placeholder chào mừng nếu có tin nhắn mới tới
                            const placeholder = box.querySelector('.chat-welcome-placeholder');
                            if (placeholder) placeholder.remove();

                            idSet.add(msg.id);
                            appendMessageToBox(box, msg.content, msg.senderRole, msg.senderId, msg.createdAt, msg.id, false, channel);
                            if (Number(msg.senderId) !== currentUserId && msg.senderRole !== 'USER') {
                                hasNewFromOthers = true;
                            }
                        });

                        if (hasNewFromOthers) {
                            playNotificationSound();
                            if (!panel.classList.contains('is-open') && unreadBadge) {
                                unreadBadge.classList.remove('d-none');
                            }
                            if (channel === 'HUMAN' && activeChannel !== 'HUMAN' && tabHumanUnreadDot) {
                                tabHumanUnreadDot.classList.remove('d-none');
                            }
                        }
                    } catch(e) {}
                }

                function appendMessageToBox(container, content, senderRole, senderId, createdAt, msgId, isPending, channel) {
                    if (!container) return null;
                    const div = document.createElement('div');
                    const timeStr = (createdAt || '').replace('.0', '').substring(11, 16);
                    div.setAttribute('data-role', senderRole);
                    div.setAttribute('data-raw-content', content);
                    if (msgId) {
                        div.setAttribute('data-msg-id', msgId);
                    }
                    if (isPending) {
                        div.setAttribute('data-pending', 'true');
                    }

                    if (senderRole === 'AI') {
                        div.className = 'msg-bubble ai-bubble';
                        div.innerHTML = '<div class="d-flex align-items-center justify-content-between mb-1">'
                            + '<span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-2 py-0 fw-semibold" style="font-size:0.7rem;"><i class="bi bi-robot"></i> Trợ lý AI Hịn Hò</span>'
                            + '</div>'
                            + '<div class="msg-text">' + formatMarkdown(content) + '</div>'
                            + '<small class="text-secondary text-end">' + timeStr + '</small>';
                    } else if (senderRole === 'ADMIN') {
                        div.className = 'msg-bubble admin-bubble';
                        div.innerHTML = '<div class="d-flex align-items-center justify-content-between mb-1">'
                            + '<span class="badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill px-2 py-0 fw-semibold" style="font-size:0.7rem;"><i class="bi bi-headset"></i> Nhân viên tư vấn TourBooking</span>'
                            + '</div>'
                            + '<div class="msg-text">' + escapeHtml(content) + '</div>'
                            + '<small class="text-secondary text-end">' + timeStr + '</small>';
                    } else {
                        const isMine = Number(senderId) === currentUserId || senderRole === 'USER';
                        div.className = 'msg-bubble ' + (isMine ? 'mine' : 'theirs');
                        let waitingSub = '';
                        if (channel === 'HUMAN' && isMine && isPending) {
                            waitingSub = '<div class="text-white-50 extra-small mt-1" style="font-size:0.7rem;"><i class="bi bi-clock-history"></i> Đã gửi nhân viên...</div>';
                        }
                        div.innerHTML = '<div class="msg-text">' + escapeHtml(content) + '</div>'
                            + '<small>' + timeStr + '</small>' + waitingSub;
                    }
                    container.appendChild(div);
                    container.scrollTop = container.scrollHeight;
                    return div;
                }

                if (restartBtn) {
                    restartBtn.addEventListener('click', function() {
                        recordUserInteraction();
                        if (input) input.focus();
                    });
                }

                window.quickSend = function(text) {
                    if (!input || !form || isAiThinking) return;
                    input.value = text;
                    if (form.requestSubmit) {
                        form.requestSubmit();
                    } else {
                        form.dispatchEvent(new Event('submit', { cancelable: true }));
                    }
                };

                input.addEventListener('keydown', function(e) {
                    if (e.isComposing || e.keyCode === 229) return;
                    if (e.key === 'Enter' && !e.shiftKey) {
                        e.preventDefault();
                        if (!isSubmitting && !isAiThinking) {
                            if (form.requestSubmit) {
                                form.requestSubmit();
                            } else {
                                form.dispatchEvent(new Event('submit', { cancelable: true }));
                            }
                        }
                    }
                });

                form.addEventListener('submit', async function(e) {
                    e.preventDefault();
                    if (isSubmitting || isAiThinking) return;

                    const text = input.value.trim();
                    if (!text) return;

                    const sendChannel = activeChannel; // 'AI' hoặc 'HUMAN'
                    const targetBox = sendChannel === 'AI' ? boxAi : boxHuman;
                    const targetIdSet = sendChannel === 'AI' ? renderedAiIds : renderedHumanIds;

                    isSubmitting = true;
                    if (sendChannel === 'AI') {
                        isAiThinking = true;
                        if (typingIndicator) {
                            typingIndicator.classList.remove('d-none');
                            if (boxAi) boxAi.scrollTop = boxAi.scrollHeight;
                        }
                    }

                    input.disabled = true;
                    if (sendBtn) sendBtn.disabled = true;

                    recordUserInteraction();

                    // Xóa placeholder chào mừng nếu có
                    if (targetBox) {
                        const placeholder = targetBox.querySelector('.chat-welcome-placeholder');
                        if (placeholder) placeholder.remove();
                    }

                    // Hiện ngay bubble của khách hàng vào đúng box của luồng
                    const now = new Date();
                    const timeNow = String(now.getHours()).padStart(2, '0') + ':' + String(now.getMinutes()).padStart(2, '0');
                    const userBubble = appendMessageToBox(targetBox, text, 'USER', currentUserId, timeNow, null, true, sendChannel);
                    input.value = '';

                    const body = new URLSearchParams();
                    body.append('content', text);
                    body.append('channel', sendChannel);
                    body.append('mode', sendChannel);

                    try {
                        const res = await fetch(baseUrl, {
                            method: 'POST',
                            credentials: 'same-origin',
                            headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
                            body: body
                        });

                        if (res.ok) {
                            const result = await res.json();
                            if (result.userMsgId) {
                                targetIdSet.add(result.userMsgId);
                                if (userBubble) {
                                    userBubble.removeAttribute('data-pending');
                                    userBubble.setAttribute('data-msg-id', result.userMsgId);
                                }
                            }

                            // CHỈ KHI Ở LUỒNG AI: nhận câu trả lời từ AI
                            if (sendChannel === 'AI' && result.aiReply) {
                                const aiTime = new Date();
                                const aiTimeStr = String(aiTime.getHours()).padStart(2, '0') + ':' + String(aiTime.getMinutes()).padStart(2, '0');
                                appendMessageToBox(boxAi, result.aiReply, 'AI', 1, aiTimeStr, result.aiMsgId || null, false, 'AI');
                                if (result.aiMsgId) {
                                    renderedAiIds.add(result.aiMsgId);
                                }
                                playNotificationSound();
                            }
                        }
                    } catch(err) {
                        console.error("Chat error:", err);
                    } finally {
                        if (typingIndicator) typingIndicator.classList.add('d-none');
                        isAiThinking = false;
                        isSubmitting = false;
                        input.disabled = false;
                        if (sendBtn) sendBtn.disabled = false;
                        input.focus();
                        await fetchChannelMessages(sendChannel);
                    }
                });

                // Polling kiểm tra tin nhắn mới mỗi 3 giây cho luồng đang xem
                setInterval(function() {
                    if (panel && panel.classList.contains('is-open')) {
                        fetchChannelMessages(activeChannel);
                        // Thỉnh thoảng kiểm tra tin nhắn mới từ luồng còn lại
                        const otherChannel = activeChannel === 'AI' ? 'HUMAN' : 'AI';
                        fetchChannelMessages(otherChannel);
                    }
                    checkCustomerInactivity();
                }, 3000);
            }
        }

        /* =========================================================================
         * 2. LOGIC QUẢN TRỊ VIÊN (ADMIN MULTI-CUSTOMER BUBBLES & AI MONITORING)
         * ========================================================================= */
        if (role === 'ADMIN') {
            const masterBubble = document.getElementById('adminMasterBubble');
            const bubblesStack = document.getElementById('adminCustomerBubblesStack');
            const totalUnreadBadge = document.getElementById('adminTotalUnreadBadge');
            const chatHubPanel = document.getElementById('adminChatHubPanel');
            const chatHubClose = document.getElementById('adminChatHubClose');
            const messagesBox = document.getElementById('adminChatMessages');
            const currentAvatar = document.getElementById('adminCurrentAvatar');
            const currentName = document.getElementById('adminCurrentCustomerName');
            const currentSub = document.getElementById('adminCurrentCustomerSub');
            const statusText = document.getElementById('adminCustomerStatusText');
            const lastActiveText = document.getElementById('adminCustomerLastActive');
            const form = document.getElementById('adminChatForm');
            const input = document.getElementById('adminChatInput');

            let selectedCustomerId = null;
            let activeCustomerContacts = [];
            let lastKnownMessageIds = new Set();
            let isFirstAdminLoad = true;

            async function fetchAdminContacts() {
                try {
                    const res = await fetch(baseUrl + '?action=contacts', { credentials: 'same-origin' });
                    if (!res.ok) return;
                    activeCustomerContacts = await res.json();
                    renderCustomerBubbles();
                } catch(e) {}
            }

            function renderCustomerBubbles() {
                if (!bubblesStack) return;
                bubblesStack.innerHTML = '';

                activeCustomerContacts.forEach(function(cust) {
                    const bubble = document.createElement('div');
                    bubble.className = 'customer-bubble-item' + (cust.id === selectedCustomerId ? ' active' : '');
                    bubble.onclick = function() { selectCustomer(cust.id); };

                    const initials = (cust.fullName || 'KH').split(' ').map(function(w) { return w[0]; }).join('').substring(0, 2).toUpperCase();
                    const isOnline = cust.isActive;

                    const avatar = document.createElement('div');
                    avatar.className = 'customer-avatar-circle';
                    avatar.textContent = initials;

                    const dot = document.createElement('span');
                    dot.className = 'customer-status-badge ' + (isOnline ? 'online' : 'offline');
                    dot.title = isOnline ? 'Đang hoạt động (<10p)' : 'Không hoạt động >10p';
                    avatar.appendChild(dot);

                    const textWrap = document.createElement('div');
                    textWrap.className = 'd-flex flex-column';
                    textWrap.style.minWidth = '0';

                    const nameSpan = document.createElement('span');
                    nameSpan.className = 'customer-bubble-name';
                    nameSpan.textContent = cust.fullName;

                    const msgSmall = document.createElement('small');
                    msgSmall.className = 'text-secondary text-truncate';
                    msgSmall.style.fontSize = '0.7rem';
                    msgSmall.style.maxWidth = '130px';
                    msgSmall.textContent = cust.lastMessage || 'Bắt đầu chat...';

                    textWrap.appendChild(nameSpan);
                    textWrap.appendChild(msgSmall);

                    bubble.appendChild(avatar);
                    bubble.appendChild(textWrap);
                    bubblesStack.appendChild(bubble);
                });

                if (totalUnreadBadge) {
                    if (activeCustomerContacts.length > 0) {
                        totalUnreadBadge.textContent = activeCustomerContacts.length;
                        totalUnreadBadge.classList.remove('d-none');
                    } else {
                        totalUnreadBadge.classList.add('d-none');
                    }
                }
            }

            async function selectCustomer(customerId) {
                if (selectedCustomerId !== customerId) {
                    lastKnownMessageIds = new Set();
                    isFirstAdminLoad = true;
                }
                selectedCustomerId = customerId;
                const cust = activeCustomerContacts.find(function(c) { return c.id === customerId; });
                if (cust) {
                    const initials = (cust.fullName || 'KH').split(' ').map(function(w) { return w[0]; }).join('').substring(0, 2).toUpperCase();
                    if (currentAvatar) currentAvatar.textContent = initials;
                    if (currentName) currentName.textContent = cust.fullName;
                    if (currentSub) currentSub.textContent = '@' + cust.username;
                    
                    if (statusText) {
                        if (cust.isActive) {
                            statusText.innerHTML = '<i class="bi bi-circle-fill text-success me-1"></i> Đang hoạt động (< 10p)';
                        } else {
                            statusText.innerHTML = '<i class="bi bi-clock text-secondary me-1"></i> Tạm dừng (Không tương tác > 10p)';
                        }
                    }
                    if (lastActiveText) {
                        lastActiveText.textContent = (cust.lastMessageAt || '').substring(11, 16);
                    }
                }

                renderCustomerBubbles();
                if (chatHubPanel) chatHubPanel.classList.add('is-open');
                await fetchAdminMessages();
                if (input) input.focus();
            }

            async function fetchAdminMessages() {
                if (!selectedCustomerId) return;
                try {
                    const res = await fetch(baseUrl + '?customerId=' + encodeURIComponent(selectedCustomerId) + '&channel=ALL', { credentials: 'same-origin' });
                    if (!res.ok) return;
                    const messages = await res.json();
                    renderAdminMessages(messages);
                } catch(e) {}
            }

            function renderAdminMessages(list) {
                if (!messagesBox) return;
                messagesBox.innerHTML = '';
                if (!list.length) {
                    messagesBox.innerHTML = '<div class="text-center text-secondary small py-4">Chưa có tin nhắn nào từ khách hàng này.</div>';
                    return;
                }

                let hasNewUserMsg = false;
                list.forEach(function(msg) {
                    const div = document.createElement('div');
                    const timeStr = (msg.createdAt || '').replace('.0', '').substring(11, 16);

                    if (msg.senderRole === 'AI') {
                        div.className = 'msg-bubble ai-bubble';
                        div.innerHTML = '<div class="d-flex align-items-center justify-content-between mb-1">'
                            + '<span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-2 py-0 fw-semibold" style="font-size:0.7rem;"><i class="bi bi-robot"></i> Trợ lý AI (Luồng AI):</span>'
                            + '</div>'
                            + '<div class="msg-text">' + formatMarkdown(msg.content) + '</div>'
                            + '<small class="text-secondary text-end">' + timeStr + '</small>';
                    } else if (msg.senderRole === 'ADMIN') {
                        div.className = 'msg-bubble mine';
                        div.innerHTML = '<div class="small fw-bold text-light mb-1"><i class="bi bi-person-badge me-1"></i>Bạn (Nhân viên tư vấn):</div>'
                            + '<div class="msg-text">' + escapeHtml(msg.content) + '</div>'
                            + '<small class="text-white-50 text-end">' + timeStr + '</small>';
                    } else {
                        const channelBadge = (msg.channel === 'HUMAN')
                            ? '<span class="badge bg-primary-subtle text-primary border border-primary-subtle rounded-pill px-2 py-0 fw-semibold ms-1" style="font-size:0.68rem;"><i class="bi bi-headset"></i> Hỏi Người thật</span>'
                            : '<span class="badge bg-success-subtle text-success border border-success-subtle rounded-pill px-2 py-0 fw-semibold ms-1" style="font-size:0.68rem;"><i class="bi bi-robot"></i> Hỏi AI</span>';

                        div.className = 'msg-bubble theirs';
                        div.innerHTML = '<div class="small fw-bold text-primary mb-1 d-flex align-items-center justify-content-between"><span><i class="bi bi-person-fill me-1"></i>Khách hàng:</span>' + channelBadge + '</div>'
                            + '<div class="msg-text">' + escapeHtml(msg.content) + '</div>'
                            + '<small class="text-secondary text-end">' + timeStr + '</small>';

                        if (!lastKnownMessageIds.has(msg.id)) {
                            if (!isFirstAdminLoad) {
                                hasNewUserMsg = true;
                            }
                        }
                    }

                    lastKnownMessageIds.add(msg.id);
                    messagesBox.appendChild(div);
                });
                isFirstAdminLoad = false;
                if (hasNewUserMsg) {
                    playNotificationSound();
                }
                messagesBox.scrollTop = messagesBox.scrollHeight;
            }

            if (masterBubble && chatHubPanel) {
                masterBubble.addEventListener('click', function() {
                    if (chatHubPanel.classList.contains('is-open')) {
                        chatHubPanel.classList.remove('is-open');
                    } else {
                        chatHubPanel.classList.add('is-open');
                        if (!selectedCustomerId && activeCustomerContacts.length > 0) {
                            selectCustomer(activeCustomerContacts[0].id);
                        } else if (!selectedCustomerId) {
                            fetchAdminContacts().then(function() {
                                if (activeCustomerContacts.length > 0) selectCustomer(activeCustomerContacts[0].id);
                            });
                        }
                    }
                });
            }

            if (chatHubClose && chatHubPanel) {
                chatHubClose.addEventListener('click', function() {
                    chatHubPanel.classList.remove('is-open');
                });
            }

            window.adminQuickReply = function(text) {
                if (!input || !form) return;
                input.value = text;
                form.dispatchEvent(new Event('submit'));
            };

            if (form && input) {
                input.addEventListener('keydown', function(e) {
                    if (e.key === 'Enter' && !e.shiftKey) {
                        e.preventDefault();
                        if (form.requestSubmit) {
                            form.requestSubmit();
                        } else {
                            form.dispatchEvent(new Event('submit', { cancelable: true }));
                        }
                    }
                });

                form.addEventListener('submit', async function(e) {
                    e.preventDefault();
                    const text = input.value.trim();
                    if (!text || !selectedCustomerId) return;

                    const body = new URLSearchParams();
                    body.append('content', text);
                    body.append('customerId', selectedCustomerId);
                    body.append('channel', 'HUMAN');

                    input.value = '';
                    const res = await fetch(baseUrl, {
                        method: 'POST',
                        credentials: 'same-origin',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8' },
                        body: body
                    });
                    if (res.ok) {
                        await fetchAdminMessages();
                        fetchAdminContacts();
                    }
                });
            }

            // Polling liên tục danh sách khách & tin nhắn mới cho Admin
            fetchAdminContacts();
            setInterval(function() {
                fetchAdminContacts();
                if (chatHubPanel && chatHubPanel.classList.contains('is-open') && selectedCustomerId) {
                    fetchAdminMessages();
                }
            }, 2500);
        }
    })();
</script>


