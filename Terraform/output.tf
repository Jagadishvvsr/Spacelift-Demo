output "Public_IP" {
    value =  {
        for k,v in aws_instance.aws_ec2_tf_spacelift :
        k => v.public_ip
    }
     
}
