/**
 * TourBooking Multi-Language (i18n) Engine
 * Supports: Tiếng Việt (VI 🇻🇳) & English (EN 🇬🇧)
 */
const i18nDictionary = {
    vi: {
        'nav.home': 'Trang chủ',
        'nav.tours': 'Danh sách Tour',
        'nav.mybookings': 'Tour của tôi',
        'nav.admin': 'Quản trị',
        'nav.login': 'Đăng nhập',
        'nav.register': 'Đăng ký',
        'nav.logout': 'Đăng xuất',
        'nav.client': 'Trang khách',
        'hero.title': 'Khám Phá Danh Sách Tour Du Lịch',
        'hero.subtitle': 'Lịch trình trọn gói, giá tốt và dịch vụ hàng đầu.',
        'btn.search': 'Tìm kiếm',
        'btn.filter': 'Lọc',
        'btn.reset': 'Đặt lại',
        'btn.booknow': 'Đặt Tour Ngay',
        'btn.viewdetail': 'Xem chi tiết',
        'btn.printticket': 'In Vé / Tải PDF',
        'btn.apply': 'Áp dụng',
        'admin.overview': 'Tổng quan',
        'admin.tours': 'Quản lý tour',
        'admin.bookings': 'Đơn đặt tour',
        'admin.refunds': 'Hoàn / Hủy',
        'admin.coupons': 'Mã giảm giá',
        'admin.customers': 'Khách hàng',
        'admin.reviews': 'Đánh giá',
        'admin.audit': 'Nhật ký Log'
    },
    en: {
        'nav.home': 'Home',
        'nav.tours': 'All Tours',
        'nav.mybookings': 'My Bookings',
        'nav.admin': 'Admin Dashboard',
        'nav.login': 'Sign In',
        'nav.register': 'Register',
        'nav.logout': 'Sign Out',
        'nav.client': 'Customer Portal',
        'hero.title': 'Explore Our Premium Tour Packages',
        'hero.subtitle': 'All-inclusive itineraries, best rates and top-tier services.',
        'btn.search': 'Search',
        'btn.filter': 'Filter',
        'btn.reset': 'Reset',
        'btn.booknow': 'Book Tour Now',
        'btn.viewdetail': 'View Details',
        'btn.printticket': 'Print E-Ticket / PDF',
        'btn.apply': 'Apply',
        'admin.overview': 'Overview',
        'admin.tours': 'Tour Management',
        'admin.bookings': 'Bookings',
        'admin.refunds': 'Refunds',
        'admin.coupons': 'Vouchers & Coupons',
        'admin.customers': 'Customers',
        'admin.reviews': 'Reviews',
        'admin.audit': 'Audit Logs'
    }
};

function getCurrentLang() {
    return localStorage.getItem('tourbooking_lang') || 'vi';
}

function setLanguage(lang) {
    localStorage.setItem('tourbooking_lang', lang);
    applyLanguage(lang);
    updateLangSwitcherUI(lang);
}

function applyLanguage(lang) {
    const dict = i18nDictionary[lang] || i18nDictionary.vi;
    document.querySelectorAll('[data-i18n]').forEach(el => {
        const key = el.getAttribute('data-i18n');
        if (dict[key]) {
            el.innerText = dict[key];
        }
    });
}

function updateLangSwitcherUI(lang) {
    document.querySelectorAll('.js-lang-btn').forEach(btn => {
        if (btn.dataset.lang === lang) {
            btn.classList.add('active', 'btn-warning');
            btn.classList.remove('btn-outline-light');
        } else {
            btn.classList.remove('active', 'btn-warning');
            btn.classList.add('btn-outline-light');
        }
    });
}

// Auto init on page load
window.addEventListener('DOMContentLoaded', () => {
    const savedLang = getCurrentLang();
    applyLanguage(savedLang);
    updateLangSwitcherUI(savedLang);
});

