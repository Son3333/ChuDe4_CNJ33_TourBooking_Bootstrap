package vn.edu.eaut.tour.model;

import vn.edu.eaut.tour.util.CryptoUtil;

public class User {
    private int id;
    private String username;
    private String password;
    private String fullName;
    private String role; // ADMIN, MANAGER, STAFF, USER
    private boolean blocked;

    public User() {}

    public User(int id, String username, String password, String fullName, String role) {
        this(id, username, password, fullName, role, false);
    }

    public User(int id, String username, String password, String fullName, String role, boolean blocked) {
        this.id = id;
        this.username = username;
        this.password = password;
        this.fullName = fullName;
        this.role = role != null ? role.toUpperCase() : "USER";
        this.blocked = blocked;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getDecryptedUsername() {
        return CryptoUtil.decrypt(this.username);
    }

    public String getMaskedUsername() {
        return CryptoUtil.maskUsername(this.username);
    }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role != null ? role.toUpperCase() : "USER"; }

    public boolean isBlocked() { return blocked; }
    public void setBlocked(boolean blocked) { this.blocked = blocked; }

    public boolean isAdmin() { return "ADMIN".equalsIgnoreCase(role); }
    public boolean isManager() { return "MANAGER".equalsIgnoreCase(role); }
    public boolean isStaff() { return "STAFF".equalsIgnoreCase(role); }
    public boolean isCustomer() { return "USER".equalsIgnoreCase(role) || role == null; }
    public boolean canManageTours() { return isManager() || isStaff(); }
    public boolean canViewFinancials() { return isManager(); } // Admin KHÔNG xem doanh thu
}