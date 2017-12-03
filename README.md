# Overview

Relink URL shortner package.

# Usage

### Login to ECS

<a href="go/awssetup">Requires AWS cli setup.</a>

```bash
make login
```

### Pull images from ECR

```bash
docker pull 649907491639.dkr.ecr.us-west-2.amazonaws.com/mongo
docker pull 649907491639.dkr.ecr.us-west-2.amazonaws.com/relink
```

### Run locally

```bash
docker run -p 27017:27017 649907491639.dkr.ecr.us-west-2.amazonaws.com/mongo
docker run -p 80:8080 649907491639.dkr.ecr.us-west-2.amazonaws.com/relink
```

@TODO: docker-compose

### Local override for host

```bash
sudo vi /etc/hosts
127.0.0.1   go
```

### Test

You should be able to use something like http://go:8080/ and start using the service locally.
