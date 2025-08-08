output "instance_id" {
description = "ID of the Phoenix target instance"
value
= aws_instance.phoenix_target.id
}
output "instance_public_ip" {
description = "Public IP address of target instance"
value
= aws_instance.phoenix_target.public_ip
}
output "web_url" {
description = "URL to access the web server"
value
= "http://${aws_instance.phoenix_target.public_ip}"
}
output "lambda_function_name" {
description = "Name of the Phoenix response Lambda"
value
= aws_lambda_function.phoenix_response.function_name
}
output "alarm_name" {
description = "Name of the CloudWatch alarm"
value
= aws_cloudwatch_metric_alarm.phoenix_breach_alarm.alarm_name
}