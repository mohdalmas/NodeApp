node {
    def app

    stage('Clone repository') {
        /* Cloning the Repository to our Workspace */

        git poll: true, url: 'https://github.com/saquibm6/NodeApp.git'
    }

    stage('Build image') {
        /* This builds the actual image */

        app = docker.build("hello-world")
    }

    stage('Test image') {
        
        app.inside {
            echo "Tests passed"
        }
    }

    stage('Push image') {
        /* 
			You would need to first register with DockerHub before you can push images to your account
		*/
        docker.withRegistry('http://363081308058.dkr.ecr.us-east-2.amazonaws.com/hello-world', 'ecr:us-east-2:login-ecr') {
            app.push("${BUILD_NUMBER}")
            app.push("latest")
            } 
                echo "Pushed Docker Build to ECR"
    }
    stage ('Deploy to ECS') {
        sh 'chmod +x deploy.sh'
        sh './deploy.sh'
    }
}
