##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#

resource "google_service_account" "cloudrun_sa" {
  account_id   = local.release_name
  display_name = "${local.release_name} Service Account"
  description  = "Service Account for ${local.release_name} Cloud Run Application"
}

resource "google_project_iam_member" "gae_api" {
  project = google_service_account.cloudrun_sa.project
  role    = "roles/compute.networkUser"
  member  = google_service_account.cloudrun_sa.member
}

resource "google_project_iam_member" "log_writer" {
  project = google_service_account.cloudrun_sa.project
  role    = "roles/logging.logWriter"
  member  = google_service_account.cloudrun_sa.member
}

resource "google_project_iam_member" "registry_writer" {
  project = google_service_account.cloudrun_sa.project
  role    = "roles/artifactregistry.writer"
  member  = google_service_account.cloudrun_sa.member
}

resource "google_project_iam_member" "act_as" {
    project = google_service_account.cloudrun_sa.project
    role    = "roles/iam.serviceAccountUser"
    member  = google_service_account.cloudrun_sa.member
}
# data "google_service_account" "deployment_sa" {
#   count      = var.deployment_sa != "" ? 1 : 0
#   account_id = var.deployment_sa
# }
#
# resource "google_service_account_iam_binding" "sa_user" {
#   count              = var.deployment_sa != "" ? 1 : 0
#   service_account_id = data.google_service_account.deployment_sa[0].id
#   role               = "roles/iam.serviceAccountUser"
#   members            = [google_service_account.cloudrun_sa.member]
# }
#
#
