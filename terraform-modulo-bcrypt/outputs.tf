output "password_plain" {
  value = random_password.this.result
  sensitive = true
}

output "password_bcrypt" {
  value = bcrypt(random_password.this.result)
  sensitive = true
}