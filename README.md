# docker-qlik-data-movement-gateway

Scripts for building and running Qlik Data Movement Gateway as a container.

* [Commands](#commands)
* [Usage](#usage)
* [Install](#install)
* [Design](#design)
* [Examples](#examples)


## Commands:

Source the `qlik-data-movement-gateway-init` script and the commands below will become available.

| Command                             | Description                                                                                     |
|:------------------------------------|:------------------------------------------------------------------------------------------------|
|  **qlik_data_movement_gateway**     | Root command calls config before executing subsequent commands in the function chain.           |
|  **download**                       | Downloads the latest qlik data movement gateway image from a repo.  Currently uses personal github repo with git lfs.  Should eventually point to a qlik repo.  Takes a single required argument --token=<github token> |
|  **build**                          | Create a qlik data movement gateway image.                                                      |
|  **setup**                          | Pulls necessary docker images and creates data volumes and docker networks.                     |
|  **init**                           | Start a qlik data movement gateway container for the first.                                     |
|  **registration **                  | Print out the registration key for a gateway container.                                         |
|  **start**                          | Start the gateway container.                                                                    |
|  **stop**                           | Stop the gateway container.                                                                     |
|  **start**                          | Start the gateway service in an existing qlik data movement gateway container.                  |
|  **stop**                           | Stop the gateway service in an existing qlik data movement gateway container.                   |
|  **config**                         | Common configuration context for all commands captured as local function variables. Invoked by prior to other commands. |


## Usage

Download the latest RPM from edwardost/qlik-releases github repository.

    gateway download

Build the gateway docker image.

    gateway build

Initialize a gateway instance.

    gateway init

Initializing a gateway instance will create a new container using the docker image.
The first time the container starts it will generate a registration key and store it in `/root/registration.txt`.

Print out the registration key.  It can also be found in the Docker log.

    gateway registration

Register the gateway interactively in the Qlik Cloud UI.

Stop the gateway container.

    gateway stop

Start the gateway container.

    gateway start

Stop the replicate service running within the container.

    gateway service stop

Start the replicate service again.

    gateway service start

Run an ad-hoc command within the gateway container.

    gateway ps -ef

All arguments after gateway command are passed to /bin/bash within gateway container.  An ad-hoc command is always a terminating command.
This command should show the repagent and other processes are running.

Create a shell for interactively running commands in the gateway container.

    gateway shell

A shell command is always a terminating command since it results in an interactive session.


## Install

This has a dependency on the ubi8 project which provides the base image upon which it is built.  So first install the ubi8 project and build
the ubi8 standard image.

It also depends on being able to download the latest QCDI data movement gateway rpm from a github repo.  A sample repo is provided using the
`qlik-releases` repository.  Fork that repo, then clone it from your fork to your laptop, and download the latest gateway
rpm from the Qlik Cloud site.  Run the run the prepare.sh script and do a commit and push to your fork.

Now all of your dependent resources are prepared.

Clone this repository and customize the `qlik_data_movement_gateway_config.sh`.
Edit the `qlik_data_movement_gateway_organization` to be your github username for the `qlik-releases` fork you created above.
Now edit the the `qlik_data_movement_gateway_operator` property to reflect your docker username.  This will be prefixed to the docker images you create.

To create a gateway container:

    gateway download -t=<github_token> build init registration

The github_token reference asbove must be for a user that is allowed to access your forked `qlik-releases` repo.

This will print out the registration to the console.  Goto Qlik Cloud Management Console -> Data Gateways and
register the new gateway.

After the new gateway is registered it will show as Disconnected.  Refresh the browser.  It should show connected.  If it does not, 
Disable and then Enable it in Qlik Management Console.  If it still does not show as connected stop and then start the container.

    gateway stop
    gateway start

Now confirm that the replicate and agent processes are running by using the `gateway ps -ef` command.  It should look similar to below.

````
$ gateway ps -ef
config:
UID        PID  PPID  C STIME TTY          TIME CMD
root         1     0  0 14:19 ?        00:00:00 /sbin/docker-init -- /root/repagent_start.sh
root         7     1  0 14:19 ?        00:00:00 bash /root/repagent_start.sh
root        45     1 25 14:19 ?        00:00:11 /opt/qlik/gateway/movement/bin/agentctl -d /opt/qlik/gateway/movement/data service host -b
root        87     1  0 14:19 ?        00:00:00 /opt/qlik/gateway/movement/bin/repctl -d /opt/qlik/gateway/movement/data service start
root        88    87  3 14:19 ?        00:00:01 /opt/qlik/gateway/movement/bin/repctl -d /opt/qlik/gateway/movement/data service start
root       119     7  0 14:19 ?        00:00:00 /usr/bin/coreutils --coreutils-prog-shebang=sleep /usr/bin/sleep 600
root       124    45  0 14:19 ?        00:00:00 /bin/bash /opt/qlik/gateway/movement/qcs_agents/qdi-db-commands/bin/start.sh
root       133   124 99 14:19 ?        00:00:47 ../jvm/bin/java -cp /opt/qlik/gateway/movement/qcs_agents/qdi-db-commands/bin/*:/opt/qlik/gateway/movement/qcs_agents/qdi-db-commands/bin/../lib/* com.qlik.QdiDbCommands local
root       199    45  0 14:19 ?        00:00:00 /bin/bash /opt/qlik/gateway/movement/qcs_agents/external-data-provider/bin/start.sh
root       203   199 99 14:19 ?        00:00:57 ../jvm/bin/java -jar /opt/qlik/gateway/movement/qcs_agents/external-data-provider/bin/ext-data-provider-agent-1.0.2.jar
root       323     0  0 14:20 ?        00:00:00 ps -ef
````

If you prefer to download the gateway rpm directly you can use the customization methods described in the [design](#design) section below to
override the rpm config settings.  You can determine the platform, version, and release of the rpm by using the `rpm -qi` command.  Concatenate
the rpm version and release separated by a hyphen to derive the `qlik_data_movement_gateway_package_version`.

* qlik_data_movement_gateway_package
* qlik_data_movement_gateway_package_platform
* qlik_data_movement_gateway_package_version

````bash
source qlik-data-movement-gateway-init

my_gateway() {
  qlik_data_movement_gateway_package="qlik-data-gateway-data-movement.rpm"
  qlik_data_movement_gateway_package_platform="x86_64"
  qlik_data_movement_gateway_package_version="2023.11-4"
  qlik_data_movement_gateway "$@"
}

# now use the customized gateway to build the image and then start the container
my_gateway build init registration
````

## Design

Only local variables are used for configuration.  They are initialized by the config function and are only scoped within that function.

All  commands use function chaining so subsequent subcommands execute within the same function scope and inherit all local variables.
After function arguments are parsed, subsequent arguments are executed as subcommands within the same scope.

Local shell variables are initialized to any prior existing value before using hardcoded defaults, so they can be overridden by simply
setting them before calling the qlik_data_gateway function.


## Examples

````bash
source qlik-data-movement-gateway-init
qlik_data_movement_gateway qlik_data_movement_gateway_download
qlik_data_movement_gateway qlik_data_movement_gateway_build
qlik_data_movement_gateway qlik_data_movement_gateway_init
````

By convention, all commands support function chaining.  So they can be concatenated in a single command to execute in a common context.

````bash
qlik_data_movement_gateway qlik_data_movement_gateway_download qlik_data_movement_gateway_build qlik_data_movement_gateway_init
````

By convention, all commands recognize abbreviations for other subcommands.

````bash
qlik_data_movement_gateway download build init
````

`gatway` and `qlik_gateway` are synonyms for the qlik_data_movement_gateway function.

````bash
gateway download build init
````

By convention, config only sets variables which do not already have a prior value.  To override a config setting set a global shell variable
of the same name and it will be picked up each time the config initializes the context.

````bash
source qlik-data-movement-gateway-init
qlik_data_movement_gateway_package_rpm_version="2023.11-5"
qlik_data_movement_gateway_package_rpm_platform="x86_64"
qlik_data_movement_gateway_package_rpm="some_rpm_file_name.rpm"
qlik_data_movement_gateway build init
````

While a global override can be useful when there is only a single instance, if multiple instances have to run concurrently it is better to encapsulate each
in its own configuration function.  The configuration function can delegate the bulk of the configuration to the base config and override just targeted properties.
Multiple named instances can be created in this manner, each identified by its own configuration function.   The init only needs to be called once.

````bash
source qlik-data-movement-gateway-init

gateway2() {
  qlik_data_movement_gateway_package_rpm_version="2023.11-4"
  qlik_data_movement_gateway_package_rpm_platform="x86_64"
  qlik_data_movement_gateway_package_rpm="some_rpm_file_name.rpm"
  qlik_data_movement_gateway "$@"
}
gateway2 build init

gateway3() {
  qlik_data_movement_gateway_package_rpm_version="2023.11-5"
  qlik_data_movement_gateway_package_rpm_platform="x86_64"
  qlik_data_movement_gateway_package_rpm="another_rpm_file_name.rpm"
  qlik_data_movement_gateway "$@"
}
gateway3 build init
````
