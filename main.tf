##
# (c) 2021-2025
#     Cloud Ops Works LLC - https://cloudops.works/
#     Find us on:
#       GitHub: https://github.com/cloudopsworks
#       WebSite: https://cloudops.works
#     Distributed Under Apache v2.0 License
#
locals {
  tags = merge(var.extra_tags, {
    Environment = format("%s-%s", var.release.name, var.namespace)
    Namespace   = var.namespace
    Release     = var.release.name
  })
  qualifier    = try(var.release.qualifier, "")
  release_name = length(local.qualifier) > 0 ? format("%s-%s-%s", var.release.name, var.namespace, local.qualifier) : format("%s-%s", var.release.name, var.namespace)
  is_service   = lower(var.cloudrun.type) == "service"
  is_job       = lower(var.cloudrun.type) == "job"
  is_worker    = lower(var.cloudrun.type) == "worker" || lower(var.cloudrun.type) == "worker_pool"
  ingress_setting = try(var.cloudrun.ingress, "all") == "all" ? "INGRESS_TRAFFIC_ALL" : (
    try(var.cloudrun.ingress, "all") == "internal" ? "INGRESS_TRAFFIC_INTERNAL_ONLY" :
    "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  )
}

resource "google_cloud_run_v2_service" "this" {
  count               = local.is_service ? 1 : 0
  name                = local.release_name
  location            = var.region
  ingress             = local.ingress_setting
  deletion_protection = try(var.cloudrun.deletion_protection, false)
  dynamic "scaling" {
    for_each = length(try(var.cloudrun.scaling, {})) > 0 ? [1] : []
    content {
      min_instance_count    = try(var.cloudrun.scaling.min, null)
      max_instance_count    = try(var.cloudrun.scaling.max, null)
      scaling_mode          = try(upper(var.cloudrun.scaling.mode), null)
      manual_instance_count = try(var.cloudrun.scaling.count, null)
    }
  }
  template {
    dynamic "volumes" {
      for_each = { for vol in try(var.cloudrun.volumes, []) : vol.name => vol }
      content {
        name = volumes.value.name
        dynamic "secret" {
          for_each = try(volumes.value.secret, []) != [] ? [1] : []
          content {
            secret       = volumes.value.secret.secret_name
            default_mode = try(volumes.value.secret.default_mode, null)
            dynamic "items" {
              for_each = try(volumes.value.secret.items, [])
              content {
                path    = items.value.path
                version = try(items.value.version, null)
              }
            }
          }
        }
        dynamic "cloud_sql_instance" {
          for_each = try(volumes.value.instances, []) != [] ? [1] : []
          content {
            instances = volumes.value.instances.connection_name
          }
        }
        dynamic "empty_dir" {
          for_each = length(try(volumes.value.empty_dir, [])) > 0 ? [1] : []
          content {
            medium     = try(volumes.value.empty_dir.medium, "MEMORY")
            size_limit = try(volumes.value.empty_dir.size_limit, null)
          }
        }
        dynamic "gcs" {
          for_each = length(try(volumes.value.gcs, [])) > 0 ? [1] : []
          content {
            bucket        = volumes.value.gcs.bucket_name
            read_only     = try(volumes.value.gcs.read_only, null)
            mount_options = try(volumes.value.gcs.mount_options, null)
          }
        }
        dynamic "nfs" {
          for_each = length(try(volumes.value.nfs, [])) > 0 ? [1] : []
          content {
            server    = volumes.value.nfs.server
            path      = volumes.value.nfs.path
            read_only = try(volumes.value.nfs.read_only, null)
          }
        }
      }
    }

    containers {
      image = format("%s/%s:%s", var.container_registry, var.release.name, var.release.source.version)
      dynamic "resources" {
        for_each = length(try(var.cloudrun.limits, {})) > 0 ? [1] : []
        content {
          limits = var.cloudrun.limits
        }
      }
      dynamic "env" {
        for_each = { for var in try(var.cloudrun.environment.variables, []) : var.name => var }
        content {
          name  = env.value.name
          value = env.value.value
        }
      }
      dynamic "env" {
        for_each = try(var.cloudrun.environment.secrets, [])
        content {
          name = env.value.name
          value_from {
            secret_key_ref {
              secret  = env.value.secret_name
              version = try(env.value.version, null)
            }
          }
        }
      }
      dynamic "ports" {
        for_each = try(var.cloudrun.ports, [])
        content {
          name           = try(ports.value.name, null)
          container_port = ports.value.port
        }
      }
      dynamic "volume_mounts" {
        for_each = { for vol in try(var.cloudrun.volumes_mounts, []) : vol.name => vol }
        content {
          name       = volume_mounts.value.name
          mount_path = volume_mounts.value.mount_path
          sub_path   = try(volume_mounts.value.sub_path, null)
        }
      }
    }
    service_account = google_service_account.cloudrun_sa.email
  }
  labels = local.all_tags
}