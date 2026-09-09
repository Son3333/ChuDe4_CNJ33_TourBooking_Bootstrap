package vn.edu.eaut.tour.model;

import java.sql.Timestamp;

public class LoginHistory {
    private int id;
    private Integer userId;
    private String username;
    private String ipAddress;
    private String deviceInfo;
    private String status;
    private String failureReason;
    private Timestamp loginTime;

    public LoginHistory() {}

    public LoginHistory(int id, Integer userId, String username, String ipAddress, String deviceInfo, String status, String failureReason, Timestamp loginTime) {
        this.id = id;
        this.userId = userId;
        this.username = username;
        this.ipAddress = ipAddress;
        this.deviceInfo = deviceInfo;
        this.status = status;
        this.failureReason = failureReason;
        this.loginTime = loginTime;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getIpAddress() { return ipAddress; }
    public void setIpAddress(String ipAddress) { this.ipAddress = ipAddress; }

    public String getDeviceInfo() { return deviceInfo; }
    public void setDeviceInfo(String deviceInfo) { this.deviceInfo = deviceInfo; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getFailureReason() { return failureReason; }
    public void setFailureReason(String failureReason) { this.failureReason = failureReason; }

    public Timestamp getLoginTime() { return loginTime; }
    public void setLoginTime(Timestamp loginTime) { this.loginTime = loginTime; }
}

