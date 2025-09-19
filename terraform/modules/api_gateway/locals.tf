locals {
  allowed_origins = [
    "https://xomper.com",
    "http://localhost:4200"
  ]

  cors_vtl = join("\n", [
    "#set($origin = $input.params().header.get('Origin'))",
    "#if($origin == '') #set($origin = $input.params().header.get('origin')) #end",
    "#set($allowedOrigins = ['https://xomper.com','http://localhost:4200'])",
    "#set($found = false)",
    "#foreach($o in $allowedOrigins)",
    "  #if($origin == $o)",
    "    #set($context.responseOverride.header.Access-Control-Allow-Origin = $origin)",
    "    #set($found = true)",
    "  #end",
    "#end",
    "#if(!$found) #set($context.responseOverride.header.Access-Control-Allow-Origin = 'null') #end",
    "#set($context.responseOverride.header.Access-Control-Allow-Headers = 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token')",
    "#set($context.responseOverride.header.Access-Control-Allow-Methods = 'GET,POST,OPTIONS')",
    "#set($context.responseOverride.header.Access-Control-Allow-Credentials = 'true')"
  ])

 resource_id = length(aws_api_gateway_resource.api_gateway_resource) > 0 ? aws_api_gateway_resource.api_gateway_resource[0].id : var.parent_resource_id
}