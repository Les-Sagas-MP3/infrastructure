gcp_subnetwork_cidr = "10.1.0.0/24"
environment_name    = "production"
app_subdomain       = "app"
api_subdomain       = "api"
components = {
  api : {
    host           = "api.les-sagas-mp3.fr"
    path           = "/actuator/health"
    request_method = "GET"
    matcher        = "MATCHES_JSON_PATH"
    content        = "\"UP\""
    json_path      = "$.status"
    json_matcher   = "EXACT_MATCH"
  }
  web : {
    host           = "app.les-sagas-mp3.fr"
    path           = "/"
    request_method = "GET"
    matcher        = "CONTAINS_STRING"
    content        = "<app-root></app-root>"
  }
}