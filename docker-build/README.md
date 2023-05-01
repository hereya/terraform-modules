# Docker Build

Build a docker image from a project source and push it to ECR (private or public repository). 
Dockerfile is not required as it uses [buildpacks](https://buildpacks.io/) to build the image.
It requires `aws` cli to be present cause it uses codebuild to build and push the image.
