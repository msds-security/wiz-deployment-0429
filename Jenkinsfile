pipeline {
  agent any
  environment {
    AWS_REGION             = 'us-east-1'
    AWS_ACCOUNT_ID         = '562517367791'
    TF_VAR_project_name    = 'wiz-deployment-0429'
    TF_VAR_account_id      = '562517367791'
    TF_VAR_aws_region      = 'us-east-1'
    // Unique per-build marker, lands on every resource as tag WizDeploymentRun.
    TF_VAR_deployment_id   = "build-${env.BUILD_NUMBER}"
  }
  parameters {
    choice(name: 'ACTION', choices: ['plan','apply','destroy'], description: 'Action')
    choice(name: 'PHASE',  choices: ['phase1-s3-public','phase2-secret-cross-account','phase3-kms-policy'], description: 'Resource group to deploy')
    booleanParam(name: 'AUTO_APPROVE', defaultValue: false, description: 'Skip approval')
    string(name: 'EXTERNAL_ACCOUNT_ID', defaultValue: '000000000000', description: 'Phase 2 only: external AWS account granted secret read')
    string(name: 'TRUSTED_ROLE_ARNS_JSON', defaultValue: '[]', description: 'Phase 3 only: JSON array of role ARNs granted Encrypt/Decrypt, e.g. ["arn:aws:iam::562517367791:role/Foo"]')
  }
  stages {
    stage('Checkout') { steps { checkout scm } }
    stage('Validate AWS') { steps { sh 'aws sts get-caller-identity' } }
    stage('Install Terraform') {
      steps { sh 'if ! command -v terraform; then curl -fsSL https://releases.hashicorp.com/terraform/1.7.5/terraform_1.7.5_linux_amd64.zip -o /tmp/tf.zip && unzip -o /tmp/tf.zip -d /tmp && sudo mv /tmp/terraform /usr/local/bin/terraform; fi && terraform version' }
    }
    stage('Record Start Time') {
      steps {
        script {
          env.APPLY_START_UTC = sh(returnStdout: true, script: 'date -u +%Y-%m-%dT%H:%M:%SZ').trim()
          // Phase-specific TF_VARs:
          env.TF_VAR_external_account_id = params.EXTERNAL_ACCOUNT_ID
          env.TF_VAR_trusted_role_arns   = params.TRUSTED_ROLE_ARNS_JSON
          echo "=== BUILD START (UTC): ${env.APPLY_START_UTC} | build #${env.BUILD_NUMBER} | phase=${params.PHASE} ==="
        }
      }
    }
    stage('Terraform Init') {
      steps { dir("terraform/wiz-deployment-0429/${params.PHASE}") { sh 'terraform init -upgrade -reconfigure -backend-config=bucket=wiz-ciem-tfstate-562517367791 -backend-config=key=wiz-deployment-0429/${PHASE}/terraform.tfstate -backend-config=region=us-east-1' } }
    }
    stage('Terraform Plan') {
      steps { dir("terraform/wiz-deployment-0429/${params.PHASE}") { sh 'terraform plan -out=tfplan || true' } }
    }
    stage('Terraform Apply') {
      when { expression { params.ACTION == 'apply' } }
      steps {
        dir("terraform/wiz-deployment-0429/${params.PHASE}") { sh 'terraform apply -auto-approve tfplan' }
        script {
          env.APPLY_END_UTC = sh(returnStdout: true, script: 'date -u +%Y-%m-%dT%H:%M:%SZ').trim()
        }
      }
    }
    stage('Terraform Destroy') {
      when { expression { params.ACTION == 'destroy' } }
      steps { dir("terraform/wiz-deployment-0429/${params.PHASE}") { sh 'terraform destroy -auto-approve' } }
    }
    stage('Deployment Summary') {
      when { expression { params.ACTION == 'apply' } }
      steps {
        dir("terraform/wiz-deployment-0429/${params.PHASE}") {
          sh '''
            echo "============================================================"
            echo "  DEPLOYMENT COMPLETE - START WIZ DETECTION TIMER NOW"
            echo "============================================================"
            echo "  Build:        #${BUILD_NUMBER}  (${BUILD_URL})"
            echo "  Phase:        ${PHASE}"
            echo "  Account:      ${AWS_ACCOUNT_ID}"
            echo "  Region:       ${AWS_REGION}"
            echo "  Apply start:  ${APPLY_START_UTC}"
            echo "  Apply end:    ${APPLY_END_UTC}"
            echo "  Tag marker:   WizDeploymentRun=${TF_VAR_deployment_id}"
            echo "------------------------------------------------------------"
            echo "  Terraform outputs (paste these into Wiz Inventory search):"
            terraform output || true
            echo "------------------------------------------------------------"
            echo "  Resources in state:"
            terraform state list || true
            echo "============================================================"
          '''
        }
      }
    }
  }
  post {
    success {
      script {
        def ts = sh(returnStdout: true, script: 'date -u +%Y-%m-%dT%H:%M:%SZ').trim()
        echo "BUILD SUCCESS @ ${ts} UTC -- record this as t0 for Wiz detection latency."
      }
    }
    failure { echo 'BUILD FAILED' }
    cleanup { dir('terraform/wiz-deployment-0429') { sh 'rm -f tfplan || true' } }
  }
}
