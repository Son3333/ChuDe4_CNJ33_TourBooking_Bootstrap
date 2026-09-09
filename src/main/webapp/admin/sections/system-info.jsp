<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="tab-section" id="system-info">
    <div class="card p-4 shadow-sm mb-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <div>
                <h2 class="h5 fw-bold mb-1"><i class="bi bi-hdd-network text-secondary me-2"></i> Giám Sát Máy Chủ & Bảo Trì Hệ Thống</h2>
                <p class="text-secondary small mb-0">Theo dõi thông số kỹ thuật, tài nguyên máy chủ và trạng thái kết nối cơ sở dữ liệu MySQL.</p>
            </div>
            <span class="badge text-bg-success px-3 py-2 fs-6"><i class="bi bi-circle-fill me-1 small"></i> Máy chủ hoạt động tốt</span>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-md-3">
                <div class="p-3 bg-light rounded-3 border">
                    <div class="text-secondary small">Môi trường Java Runtime</div>
                    <strong class="text-dark fs-5"><%= System.getProperty("java.version") %></strong>
                    <div class="small text-muted"><%= System.getProperty("java.vm.name") %></div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="p-3 bg-light rounded-3 border">
                    <div class="text-secondary small">Hệ điều hành</div>
                    <strong class="text-dark fs-5"><%= System.getProperty("os.name") %></strong>
                    <div class="small text-muted"><%= System.getProperty("os.arch") %></div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="p-3 bg-light rounded-3 border">
                    <div class="text-secondary small">Số lõi CPU khả dụng</div>
                    <strong class="text-dark fs-5"><%= Runtime.getRuntime().availableProcessors() %> Cores</strong>
                    <div class="small text-muted">Xử lý đa luồng</div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="p-3 bg-light rounded-3 border">
                    <div class="text-secondary small">Bộ nhớ JVM sử dụng</div>
                    <%
                        long totalMem = Runtime.getRuntime().totalMemory() / (1024 * 1024);
                        long freeMem = Runtime.getRuntime().freeMemory() / (1024 * 1024);
                        long usedMem = totalMem - freeMem;
                    %>
                    <strong class="text-primary fs-5"><%= usedMem %> MB / <%= totalMem %> MB</strong>
                    <div class="small text-muted">Tối đa: <%= Runtime.getRuntime().maxMemory() / (1024 * 1024) %> MB</div>
                </div>
            </div>
        </div>

        <div class="alert alert-info py-2 small mb-0">
            <i class="bi bi-info-circle-fill me-1"></i> Cơ sở dữ liệu MySQL: <strong>localhost:3306/tour_booking_db</strong>. Trạng thái kết nối: <strong>CONNECTED (Sẵn sàng)</strong>.
        </div>
    </div>
</div>

