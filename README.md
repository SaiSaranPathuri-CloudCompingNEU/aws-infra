# aws-infra

STEPS FOR SETTING UP INFRASTRUCTURE FOR TERRAFORM: .
-> Create AWS account
-> Create IAM user and assign admin permission
-> Install AWS CLI
-> Create access keys from the aws portal
-> Use the access keys to configure the aws cli for a profile
-> Install terraform
-> Use the profile name in the terraform and setup the profile, source, version, region
-> `aws iam update-server-certificate --server-certificate-name ExampleCertificate --new-server-certificate-name CloudFrontCertificate --new-path /cloudfront/`
-> `aws iam upload-server-certificate --server-certificate-name certificate_object_name --certificate-body file://path to your certificate file --private-key file://path to your private key file --certificate-chain file://path to your CA-bundle file`
->`aws acm import-certificate --certificate file://Certificate.pem --certificate-chain file://CertificateChain.pem --private-key file://PrivateKey.pem`
