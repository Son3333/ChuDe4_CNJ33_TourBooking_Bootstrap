package vn.edu.eaut.tour.model;

import java.sql.Timestamp;

public class TourIncident {
    private int id;
    private int tourId;
    private int reportedBy;
    private String reporterName;
    private String incidentType;
    private String description;
    private String severity;
    private String status;
    private String resolution;
    private Timestamp reportedAt;
    private Timestamp resolvedAt;

    public TourIncident() {}

    public TourIncident(int id, int tourId, int reportedBy, String reporterName, String incidentType, String description, String severity, String status, String resolution, Timestamp reportedAt, Timestamp resolvedAt) {
        this.id = id;
        this.tourId = tourId;
        this.reportedBy = reportedBy;
        this.reporterName = reporterName;
        this.incidentType = incidentType;
        this.description = description;
        this.severity = severity;
        this.status = status;
        this.resolution = resolution;
        this.reportedAt = reportedAt;
        this.resolvedAt = resolvedAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getTourId() { return tourId; }
    public void setTourId(int tourId) { this.tourId = tourId; }

    public int getReportedBy() { return reportedBy; }
    public void setReportedBy(int reportedBy) { this.reportedBy = reportedBy; }

    public String getReporterName() { return reporterName; }
    public void setReporterName(String reporterName) { this.reporterName = reporterName; }

    public String getIncidentType() { return incidentType; }
    public void setIncidentType(String incidentType) { this.incidentType = incidentType; }
    public String getTitle() { return incidentType; }
    public void setTitle(String title) { this.incidentType = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getSeverity() { return severity; }
    public void setSeverity(String severity) { this.severity = severity; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getResolution() { return resolution; }
    public void setResolution(String resolution) { this.resolution = resolution; }

    public Timestamp getReportedAt() { return reportedAt; }
    public void setReportedAt(Timestamp reportedAt) { this.reportedAt = reportedAt; }

    public Timestamp getResolvedAt() { return resolvedAt; }
    public void setResolvedAt(Timestamp resolvedAt) { this.resolvedAt = resolvedAt; }
}

