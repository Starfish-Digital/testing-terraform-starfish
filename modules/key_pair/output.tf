output "key_names" {
  description = "Map of created key names"
  value = {
    for key, kp in aws_key_pair.kp :
    key => kp.key_name
  }
}

output "private_key_pems" {
  description = "Map of private key PEMs for created key pairs"
  value = {
    for key, pk in tls_private_key.pk :
    key => pk.private_key_pem
  }
  sensitive = true
}
