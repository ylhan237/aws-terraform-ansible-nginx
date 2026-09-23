output "web_servers" {
  description = "Web servers information"

  # The CI pipeline uses these public IPs to build Ansible's dynamic inventory.
  value = {
    for name, instance in aws_instance.web : name => {
      public_ip  = instance.public_ip
      private_ip = instance.private_ip
    }
  }
}