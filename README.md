# docker-qlik-data-movement-gateway

Scripts for building and running Qlik Data Movement Gateway as a container.


### Commands:

Source the `qlik-data-movement-gateway-init` script and the commands below will become available.

| Command                               | Description                                                                                     |
|:--------------------------------------|:------------------------------------------------------------------------------------------------|
|  **qlik_data_movement_gateway**       | Root command calls config before executing subsequent commands in the function chain.           |
|  **qlik_data_movement_gateway_download** | Downloads the latest qlik data movement gateway image from a repo.  Currently uses personal github repo with git lfs.  Should eventually point to a qlik repo.  Takes a single required argument --token=<github token> |
|  **qlik_data_movement_gateway_build** | Create a qlik data movement gateway image.                                                      |
|  **qlik_data_movement_gateway_setup** | Pulls necessary docker images and creates data volumes and docker networks.                     |
|  **qlik_data_movement_gateway_init**  | Start a qlik data movement gateway container for the first.                                     |
|  **qlik_data_movement_gateway_registration **  | Print out the registration key for a gateway container.                                |
|  **qlik_data_movement_gateway_start** | Start the gateway service in an existing qlik data movement gateway container.                  |
|  **qlik_data_movement_gateway_stop**  | Stop the gateway service in an existing qlik data movement gateway container.                   |
|  qlik_data_movement_gateway_config    | Common configuration context for all commands captured as local function variables. Invoked by prior to other commands. |


### Usage

Download the latest RPM from edwardost/qlik-releases github repository.

    gateway download

Build the gateway docker image.

    gateway docker

Initialize a the gateway instance.

    gateway init

Initializing a gateway instance will create a new container using the docker image.  The first time the container starts it will generate a registration key and
then stop to provide time for manual registration of the key in Qlik Cloud.

Print out the registration key.  It can also be found in the Docker log.

    gateway registration

Register the gateway interactively in the Qlik Cloud UI.

Stop the gateway service while leaving the gateway container running.

    gateway stop

Start the service from a running gateway container.

    gateway start

Create a shell for interactively running commands in the gateway container.

    gateway shell

A shell command is always a terminating command since it results in an enteractive session.

Run an ad-hoc command within the gateway container.

    gateway ps -ef

All arguments after gateway command are passed to /bin/bash within gateway container.  An ad-hoc command is always a terminating command.


### Design

Only local variables are used for configuration.  They are initialized by the config function and are only scoped within that function.

All  commands use function chaining to just call whatever arguments are passed as subcommands.  So subsequent subcommands execute within the same function scope.

Local shell variables are initialized to any prior existing value, so they can be overridden by simply setting them before calling the qlik_data_gateway function.


### Example

````bash
source qlik-data-movement-gateway-init
qlik_data_movement_gateway qlik_data_movement_gateway_download
qlik_data_movement_gateway qlik_data_movement_gateway_build
qlik_data_movement_gateway qlik_data_movement_gateway_server
````

By convention, all commands support function chaining.  So they can be concatenated in a single command to execute in a common context.

````bash
qlik_data_movement_gateway qlik_data_movement_gateway_download qlik_data_movement_gateway_build qlik_data_movement_gateway_server
````

By convention, all commands recognize abbreviations for other subcommands.

````bash
qlik_data_movement_gateway download build server
````

`gatway` and `qlik_gateway` are synonyms for the qlik_data_movement_gateway function.

````bash
gateway download build server
````

By convention, config only sets variables which do not already have a prior value.  To override a config setting set a global shell variable
of the same name and it will be picked up each time the config initializes the context.

````bash
source qlik-data-movement-gateway-init
qlik_data_movement_gateway_package_rpm_version="2023.11-5"
qlik_data_movement_gateway_package_rpm_platform="x86_64"
qlik_data_movement_gateway_package_rpm="some_rpm_file_name.rpm"
qlik_data_movement_gateway build server
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
gateway2 build server

gateway3() {
  qlik_data_movement_gateway_package_rpm_version="2023.11-5"
  qlik_data_movement_gateway_package_rpm_platform="x86_64"
  qlik_data_movement_gateway_package_rpm="another_rpm_file_name.rpm"
  qlik_data_movement_gateway "$@"
}
gateway3 build server
````
