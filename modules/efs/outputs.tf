output "efs" {
   description = "The ID of the EFS"
   value = aws_efs_file_system.efs.id
}

output "efs_ap" {
   description = "The ID of the EFS access point"
   value = aws_efs_access_point.efs_ap.id
}