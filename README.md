# aws-infra

# install AWS CLI
1. install aws - ?
2. to check if it's installed....aws --version
3. to configure aws...aws configure
4. then enter the access key Id
5. then enter the secret access key
6. for default region name.....choose the one nearest to you....us-east-1
7. leave the default output format as it is
8. the key is now configured
9. these configurations are stored at (.aws) folder in your root directory. It has 2 files (config, credentials)....we can edit there configurations there or it's a matter of saying aws configure once again and giving the latest values
10. to configure your access tokens profile wise....use the command........aws configure --profile demo
11. so by setting your access tokens profile wise...everytime we run a command, we would be asked on which profile is the given command need to be executed?
12. always make sure to delete the keys associated with the admin accounts

# Terraform
1. terraform code is written in hashiCorp. each of the files have the extension .tf
2. install terraform - ?
3. commands to install terraform on ubuntu subsystem on windows 10
   1. get the zip folder link for terraform 
   2. wget url
   3. make sure unzip is installed on your ubuntu. If not use.....sudo apt-get install unzip
   4. then......unzip foldername
   5. then move to where the binaries reside.....sudo mv terraform /usr/local/bin
   6. now you must be able to access terraform from anywhere in your ubuntu subsystem.
4. to verify installation.........use...terraform --version
5. you'll find a main.tf, provider.tf, version.tf......all of these files are not mandatory...they are good practices
6. what terraform does it thar it looks for all the files ending with .tf extension and builds a single .tf file.
7. ** before you do anything with terraform, the first thing you need to do is you have to initialize your working directory
8. the reason being, terraform files have the definitions and the providers but they don't have the binaries. terraform itself comes with some core functionalities but the binaries for the providers like aws/google cloud has to be installed when we use them.
9.  init is what does that for us. ----- alias tfi='terraform init'
10. format, initialize, plan / apply
11. to format a terraform file......terraform fmt
12. before we raise a pull request in any environment, we want to know what this infrastructure change does, right? -- for this we need terraform plan (alias tfp). It tells you what terraform does.
13. so, once we write our versions, provider, and other tf files...we do (tfi && tfp) to know what changes it does to the infrastructure.
14. once we know what changes will be made...we do (terraform apply --- tfa) to apply our infrastructure changes to our aws account
15. we do (tfi && tfa)
16. terraform destroy ------ to destroy all that we have done. removes all the resources from the aws account
17. you can see the terraform.tfstate file has no much info now
18. Modules in terraform
    1.  modules are templates, they make our code reusable
    2.  create a folder called module -- mkdir module
    3.  then cd module/
    4.  then mkdir networking
    5.  then cd networking/
    6.  add your versions, variables, network files in here
    7.  create a new main.tf file and...........
19. to list/move/pull/push/remove all your resources......(terraform state list/mv/pull/push/rm)
20. if you want to import a resource.......terraform import resource-name resource-id
21. to tie dependencies in terraform.....we can use depends_on = [resource-name] --- 2.44 5th lec


# assignment hints
1. maintain an array/list of cidr ranges for subnets in your variables.tf file
2. can use depends_on constraint 
3. difference between a public and a private subnet - private subnets will not have an entry to the internet gateway, we are going to deploy our database servers in the private network
