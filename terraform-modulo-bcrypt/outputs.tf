output "this_password" {
  value = random_password.this.result
  sensitive = true
}

output "this_password_bcrypt" {
  value = bcrypt(random_password.this.result)
  sensitive = true
}