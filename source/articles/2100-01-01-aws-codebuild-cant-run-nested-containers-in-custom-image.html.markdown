If you're using AWS CodeBuild and you want to run a Docker container **inside** your custom CodeBuild image you're out of luck. If you try you'll get the following error:

> docker: Cannot connect to the Docker daemon. Is the docker daemon running on this host?.
> [Container] 2017/05/04 21:31:58 Command did not exit successfully docker run -d [your_image_name] exit status 125

For example, I needed to run a java utility in the AWS CodeBuild python image. Instead of trying to build an image that installs both I thought it would be easier to just load an existing container already built for the utitlity I needed. 

You're free to even copy and build the actual [AWS CodeBuild Docker image](https://github.com/aws/aws-codebuild-docker-images/tree/master/ubuntu/docker/1.12.1) yourself. Go ahead...I'll wait while you give it a try. Any docker image...try and run it in your custom container.

You will see the same results. But why?

Okay, try one more thing: add the following to the `pre_build` or `install` phase in your `buildspec.yml` file:

    /usr/local/bin/dind docker daemon \
    	--host=unix:///var/run/docker.sock \
    	--host=tcp://0.0.0.0:2375 \
    	--storage-driver=overlay &>/var/log/docker.log &
    
Then run your build and you'll see the error below in your CloudWatch logs:

> mount: permission denied
> Could not mount /sys/kernel/security.
> AppArmor detection and --privileged mode might break.
> mount: permission denied

The reason is that the built-in AWS CodeBuild Docker image - the one provided by AWS for you - is given special consideration. When it gets run it is run with the `--priviledged` flag. This, amoung other things allows nested Docker containers. But it is also a security risk. Amazon doesn't want to allow custom images to run with the `--priviledged` flag, and they shouldn't. 

So in case you're trying to figure out why you can't duplicate the functionality of the AWS CodeBuild Docker image (like I was) hopefully this will help you with that. 

If you still need some functionality added, you'll just need to compose the containers you need and run them in the Docker image. Or just build a custom image that has everything you need installed.
