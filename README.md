**BASH-AWS-EC2**

I made these bash scripts when I start practicing with "AWS  Command  Line  Interface".

The basic idea is to have an easy and quick way to launch an instance on AWS cloud if you need it.

The first bash script "***launch_instance.sh***":

* launches one "statically defined" ec2 instance (e.g. debian8, micro, 1-2 extra volume)

* does some provisioning on the "new born" aws ec2 instance with "***aws-kickstart.sh***" script


Finally the "***delete_instance.sh***" script just deletes everything when you finish to play.

It's nothing special but I started to know "aws cli" on that way ... it's just a nice memory.

LICENSE

GPL - http://www.gnu.org/licenses/gpl-3.0.html
