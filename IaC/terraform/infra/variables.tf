locals {
  service_name      = "gitops-aks"
  service_shortname = "gitopsaks"
  team              = "srinidev"
  brand             = "sk"     
  dataprivacylevel  = "internal"
  env               = "exp"

  tags = {
    team             = local.team
    dataprivacylevel = local.dataprivacylevel
    brand            = local.brand
    project          = local.service_name
    env              = local.env
  }

  location       = "West US 2"
  location_short = "wus2"
}