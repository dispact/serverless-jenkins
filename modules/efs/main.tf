# Variables that are being passed in
variable "prefix" {}
variable "efs_sg" {}
variable "private_subnets" { type = list }

# Creating the EFS
resource "aws_efs_file_system" "efs" {
   creation_token = "${var.prefix}-efs"
   encrypted      = true

   tags = {
      Name = "${var.prefix}-efs"
   }
}

# Creating EFS mount targets in each private subnet
# and attaching the jenkins-efs security group
resource "aws_efs_mount_target" "storage" {
   count             = length(var.private_subnets)
   file_system_id    = aws_efs_file_system.efs.id
   subnet_id         = var.private_subnets[count.index].id
   security_groups   = [var.efs_sg]
}

# This is the EFS access point
resource "aws_efs_access_point" "efs_ap" {
   # Specifying the EFS ID
   file_system_id = aws_efs_file_system.efs.id

   # This is the OS user and group applied to all
   # file system requests made through this access point
   posix_user {
      uid = 0 # POSIX user ID
      gid = 0 # POSIX group ID
   }

   # The directory that this access point points to
   root_directory {
      path = "/var/jenkins_home"
      # POSIX user/group owner of this directory
      creation_info {
        owner_uid    = 1000 # Jenkins user
        owner_gid    = 1000 # Jenkins group
        permissions  = "0755" 
      }
   }

   tags = {
      Name = "${var.prefix}-efs-ap"
   }
}