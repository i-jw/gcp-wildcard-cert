# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

output "cert_map_id" {
  value       = google_certificate_manager_certificate_map.certificate_map.id
  description = "cert map id"
}
output "DescribeRootCert" {
  value       = "gcloud certificate-manager certificates describe ${google_certificate_manager_certificate.root_cert.name}"
  description = "describe root cert status"
}
output "UpdateGCLB" {
  value       = "gcloud compute target-https-proxies update HTTPS_TARGET_PROXY_NAME --certificate-map=${google_certificate_manager_certificate_map.certificate_map.name}"
  description = "update https target proxy with cert map"
}