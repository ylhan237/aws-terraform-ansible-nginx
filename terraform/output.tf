output "web_servers" {
  description = "Web servers information"

  value = {
    for name, instance in aws_instance.web : name => {
      public_ip  = instance.public_ip
      private_ip = instance.private_ip
    }
  }
}