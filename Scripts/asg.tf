# Create asg

resource "aws_autoscaling_group" "asg" {
  vpc_zone_identifier  = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id, aws_subnet.private_subnet_3.id]
  name                 = "apache-asg"
  max_size             = 3
  min_size             = 2
  health_check_type    = "ELB"
  termination_policies = ["OldestInstance"]
  launch_template {
    id      = aws_launch_template.apache_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_alb_target_group.tg.arn]
}

# Create Scale-Out policy
resource "aws_autoscaling_policy" "apache_policy_up" {
  name                   = "apache_policy_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

# Create scale-up alarm

resource "aws_cloudwatch_metric_alarm" "apache_cpu_alarm_up" {
  alarm_name          = "apache_cpu_alarm_up"
  threshold           = "60"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  period              = "120"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  namespace           = "AWS/EC2"

  dimensions = {
    AutoscalingGroupName = aws_autoscaling_group.asg.name
  }
  alarm_description = "This alarm monitors asg cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.apache_policy_up.arn]
}

# Create Scale-In policy

resource "aws_autoscaling_policy" "apache_policy_in" {
  name                   = "apache_policy_in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

# Create scale-down alarm

resource "aws_cloudwatch_metric_alarm" "apache_cpu_alarm_down" {
  alarm_name          = "apache_cpu_alarm_down"
  threshold           = "10"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  period              = "120"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  namespace           = "AWS/EC2"

  dimensions = {
    AutoscalingGroupName = aws_autoscaling_group.asg.name
  }
  alarm_description = "This alarm monitors asg cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.apache_policy_in.arn]
}