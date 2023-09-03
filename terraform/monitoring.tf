resource "google_monitoring_uptime_check_config" "uptime_check" {
  project      = var.gcp_project
  for_each     = var.components
  display_name = "${var.environment_name}-${each.key}"
  timeout      = "60s"
  selected_regions = [
    "EUROPE",
    "ASIA_PACIFIC",
    "SOUTH_AMERICA"
  ]

  http_check {
    path           = each.value.path
    port           = "443"
    request_method = each.value.request_method
    content_type   = "TYPE_UNSPECIFIED"
    use_ssl        = true

    accepted_response_status_codes {
      status_value = 200
    }
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.gcp_project
      host       = each.value.host
    }
  }

  content_matchers {
    content = each.value.content
    matcher = each.value.matcher
    dynamic "json_path_matcher" {
      for_each = each.value.matcher == "MATCHES_JSON_PATH" ? [1] : []
      content {
        json_path    = each.value.json_path
        json_matcher = each.value.json_matcher
      }
    }
  }

}

resource "google_monitoring_notification_channel" "email" {
  project      = var.gcp_project
  display_name = "Les Sagas MP3"
  type         = "email"
  labels = {
    email_address = var.notifications_email
  }
  force_delete = false
}

resource "google_monitoring_alert_policy" "alert_policy" {
  project      = var.gcp_project
  depends_on   = [google_monitoring_uptime_check_config.uptime_check]
  for_each     = var.components
  display_name = "${var.environment_name}-${each.key}"
  combiner     = "OR"
  conditions {
    display_name = "${var.environment_name}-${each.key}"
    condition_threshold {
      filter          = format("metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\" AND metric.label.checker_location=\"eur-belgium\" AND metric.label.\"check_id\"=\"%s\" AND resource.type=\"uptime_url\"", google_monitoring_uptime_check_config.uptime_check[each.key].uptime_check_id)
      duration        = "300s"
      comparison      = "COMPARISON_LT"
      threshold_value = "1"
      trigger {
        count = 1
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.id]

  user_labels = {
    environment = var.environment_name
    component   = each.key
    managedby   = "terraform"
  }
}