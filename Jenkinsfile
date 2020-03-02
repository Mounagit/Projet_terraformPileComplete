node {

    stage ('clone git'){ 
        git url: 'https://github.com/Mounagit/Projet_terraformPileComplete.git'
    }
    
    stage ('terraform job'){
        withCredentials([file(credentialsId: 'mounaneko', variable: 'FILE')]){
            sh 'terraform init'
            sh 'terraform plan -out=out.tfstate -var-file=main.tfvars -var-file=FILE'
            sh 'terraform apply out.tfstate'
        }
    }






    

}
