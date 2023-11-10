/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>4.63.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.5.1"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = "us-west1"
}
provider "aws" {
  region = "us-east-1"
}
# Enable related service
resource "google_project_service" "gcp_services" {
  for_each                   = toset(var.gcp_service_list)
  project                    = var.project_id
  service                    = each.key
  disable_dependent_services = false
  disable_on_destroy         = false
}
resource "random_id" "tf_prefix" {
  byte_length = 4
  depends_on = [google_project_service.gcp_services]
}
resource "google_certificate_manager_dns_authorization" "default" {
  name        = "${random_id.tf_prefix.hex}-dnsauth"
  description = "The ${var.domain} dns auth"
  domain      = var.domain
  labels = {
    "terraform" : true
  }
}

data "aws_route53_zone" "selected" {
  name = "${var.domain}."
}

# aws cname for dns auth
resource "aws_route53_record" "cname" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = google_certificate_manager_dns_authorization.default.dns_resource_record[0].name
  type    = google_certificate_manager_dns_authorization.default.dns_resource_record[0].type
  ttl     = 300
  records = [google_certificate_manager_dns_authorization.default.dns_resource_record[0].data]
}

#resource "google_dns_record_set" "cname" {
#  name         = google_certificate_manager_dns_authorization.default.dns_resource_record[0].name
#  managed_zone = google_dns_managed_zone.default.name
#  type         = google_certificate_manager_dns_authorization.default.dns_resource_record[0].type
#  ttl          = 300
#  rrdatas      = [google_certificate_manager_dns_authorization.default.dns_resource_record[0].data]
#}

resource "google_certificate_manager_certificate" "root_cert" {
  name        = "${random_id.tf_prefix.hex}-rootcert"
  description = "The ${var.domain} wildcard cert"
  managed {
    domains = [var.domain, "*.${var.domain}"]
    dns_authorizations = [
      google_certificate_manager_dns_authorization.default.id
    ]
  }
  labels = {
    "terraform" : true
  }
}

resource "google_certificate_manager_certificate_map" "certificate_map" {
  name        = "certmap-${random_id.tf_prefix.hex}"
  description = "${var.domain} certificate map"
  labels = {
    "terraform" : true
  }
}

resource "google_certificate_manager_certificate_map_entry" "first_entry" {
  name        = "first-entry-${random_id.tf_prefix.hex}"
  description = "example certificate map entry"
  map         = google_certificate_manager_certificate_map.certificate_map.name
  labels = {
    "terraform" : true
  }
  certificates = [google_certificate_manager_certificate.root_cert.id]
  hostname     = var.domain
}

resource "google_certificate_manager_certificate_map_entry" "second_entry" {
  name        = "second-entity-${random_id.tf_prefix.hex}"
  description = "example certificate map entry"
  map         = google_certificate_manager_certificate_map.certificate_map.name
  labels = {
    "terraform" : true
  }
  certificates = [google_certificate_manager_certificate.root_cert.id]
  hostname     = "*.${var.domain}"
}
