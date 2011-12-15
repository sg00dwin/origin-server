Cloud SDK Quickstart
====================

Installing via RPM
------------------

To install a built version of the Cloud SDK Common from the repository, just use:

    sudo yum install cloud-sdk-common

To install everything from the source tree, we use a tool called Tito (https://github.com/dgoodwin/tito):

    sudo yum install tito

Next, you can have tito build and install the RPM from HEAD with:

    sudo tito build --rpm -i --test

You could also have tito build and install off the latest stable tag with:

    sudo tito build --rpm -i

You can also have tito build the tarball, source RPM and other things:

    sudo tito build --tgz
    sudo tito build --srpm

Installing via Gem
------------------

To support multiple operating systems, the Cloud Common also supports RubyGem installations.  To install a built version of the Cloud Common RubyGem from the repository, just use:

    sudo gem install cloud-sdk-common

To build and install the gem from the source tree, use:

    gem build cloud-sdk-common.gemspec
    sudo gem install cloud-sdk-*.gem

Local Checkout
--------------

To install required gems, you will first need some RPMs

	sudo yum -y install ruby rubygems rpm-build createrepo

Install the required gems

	sudo gem install rake bundler
	sudo bundle

To run from a local checkout run:

    eval $( rake local_env | tail -n +1 )


