Helpful Commands
- **`terraform init`** - Initialize Terraform
- **`terraform plan`** - Plan Terraform deployment
- **`terraform apply`** - Apply the Terraform plan
- **`terraform apply --auto-approve`** - Apply the Terraform plan without prompts

Use one of the Examples in `./examples` and paste it in your `main.tf` to get started. If using the Amplify App, ensure you list at least one cognito user in `main.tf`
Ex:
```go
  # Admin Users to create
  tca_admin_cognito_users = {
    DefaultAdmin : {
      username       = "admin"
      given_name     = "Naruto"
      family_name    = "Uzumaki"
      email          = "naruto@hokage.com"
      email_verified = true
    },
    SasukeUchiha : {
      username       = "novekm"
      given_name     = "Sasuke"
      family_name    = "Uchiha"
      email          = "sasuke@uchiha.com"
      email_verified = true
    }
  }
  # Standard Users to create
  tca_standard_cognito_users = {
    DefaultStandardUser : {
      username       = "default"
      given_name     = "Default"
      family_name    = "User"
      email          = "example@example.com"
      email_verified = false
    }
  }
```

To help shorten commands, it's recommended to use aliases
Ex: **`tf plan`**, **`tf apply`** instead of the full word terraform
More info:
ZSH - https://linuxhint.com/configure-use-aliases-zsh/
Bash - https://linuxize.com/post/how-to-create-bash-aliases/
