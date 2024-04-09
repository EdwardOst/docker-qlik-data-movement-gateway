# docker-qlik-data-movement-gateway

Scripts for building and running Qlik Data Movement Gateway as a container.


### Commands:

Source the `qlik-data-movement-gateway-init` script and the commands below will become available.

  **qlik_data_movement_gateway_config**    Common configuration context for all commands captured as local function variables.
                                           It must be used to chain subsequent commands.

  **qlik_data_movement_gateway_download**  Downloads the latest qlik data movement gateway image from a repo.
                                           Currently uses personal github repo with git lfs.
                                           Should eventually point to a qlik repo.
                                           Takes a single required argument --token=<github token>

  **qlik_data_movement_gateway_build**     Create a qlik data movement gateway image.

  **qlik_data_movement_gateway_setup**     Pulls necessary docker images and creates data volumes and docker networks.

  **qlik_data_movement_gateway_server**    Start a qlik data movement gateway container.




### Usage

Only local variables are used for configuration.  They are initialized by the config function and are only scoped within that function.

All  commands use function chaining to just call whatever arguments are passed as subcommands.  So subsequent subcommands execute within the same function scope.

Local shell variables are initialized to any prior existing value, so they can be overridden by simply setting them before calling the config function.


### Example

````bash
source qlik-data-movement-gateway-init
qlik_data_movement_gateway_config qlik_data_movement_gateway_setup
qlik_data_movement_gateway_config qlik_data_movement_gateway_server
qlik_data_movement_gateway_config qlik_data_movement_gateway_client
````

By convention, all commands support function chaining.  So they can be concatenated in a single command to execute in a common context.

````bash
qlik_data_movement_gateway_config qlik_data_movement_gateway_setup qlik_data_movement_gateway_server qlik_data_movement_gateway_client
````

By convention, all commands recognize abbreviations for other subcommands.

````bash
qlik_data_movement_gateway_config setup server client
````

By convention, config only sets variables which do not already have a prior value.  To override a config setting set a global shell variable
of the same name and it will be picked up each time the config initializes the context.

````bash
source qlik-data-movement-gateway-init
qlik_data_movement_gateway_container_name="mysql2"
qlik_data_movement_gateway_volume="mysql-data2"
qlik_data_movement_gateway_host_port="3307"
````

While a global override can be useful when there is only a single instance, if multiple instances have to run concurrently it is better to encapsulate each
in its own configuration function.  The configuration function can delegate the bulk of the configuration to the base config and override just targeted properties.
Multiple named instances can be created in this manner, each identified by its own configuration function.   The init only needs to be called once.

````bash
source qlik-data-movement-gateway-init

gateway2() {
  qlik_data_movement_gateway_container_name="mysql2"
  qlik_data_movement_gateway_volume="mysql-data2"
  qlik_data_movement_gateway_host_port="3307"
  qlik_data_movement_gateway_config "$@"
}
gateway2 setup server client

gateway3() {
  qlik_data_movement_gateway_container_name="mysql3"
  qlik_data_movement_gateway_volume="mysql-data3"
  qlik_data_movement_gateway_host_port="3308"
  qlik_data_movement_gateway_config "$@"
}
gateway3 setup server client
````
