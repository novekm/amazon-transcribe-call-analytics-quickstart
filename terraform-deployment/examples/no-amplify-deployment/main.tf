// This is a template file for a deployment without the Amplify Application.
// Modify the parameters below with actual values
module "tca-qs" {
  // location of the module - can be local or git repo
  source = "./modules/tca-qs"

  # SNS
  tca_sns_email_endpoint = "yusuke@spiritgun.com"

  # Amplify
  create_amplify_app             = false
  create_tca_amplify_branch_main = false // default value is true
  create_tca_amplify_branch_dev  = false // default value is true

  # Admin Users to create
  tca_admin_cognito_users = {
    DefaultAdmin : {
      username       = "admin"
      given_name     = "Default"
      family_name    = "Admin"
      email          = "example@example.com"
      email_verified = true
    },
    ErenYeagar : {
      username       = "rumbling"
      given_name     = "Eren"
      family_name    = "Yeagar"
      email          = "example@example.com"
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

}
