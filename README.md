# laradockctl
laradockctl is a command wrapper for Laradock.

## What Does laradockctl Do?
laradockctl allows you to complete Laradock operations with short commands without having to move to your `laradock` directory while in your project root directory:
```console
laradockctl up
laradockctl composer update
laradockctl down
```
It also allows you to add custom commands.

## Requirements
* [Bash](https://www.gnu.org/software/bash/)
* [Git](https://git-scm.com/)
* [Docker](https://www.docker.com/)
* [Laradock](https://laradock.io/)
  * Laradock must be added to your project root directory

## Installation
1. Add laradockctl to your project root directory as a submodule:
   ```console
   git submodule add https://github.com/ngmy/laradockctl.git
   ```
2. Make sure your directory structure looks like the following:
   ```
   * project
   *   laradock
   *   laradockctl
   ```
3. Add the `bin` directory of laradockctl to your `PATH` environment variable:
   ```bash
   export PATH=/PATH_TO_LARADOCKCTL_DIR/bin:$PATH
   ```
   We recommend using [direnv](https://direnv.net/).
4. Go to the Usage section.

## Basic Usage
### Available Environment Variables
The available environment variables are as follows:
| Environment Variable | Description |
| --- | --- |
| `LARADOCKCTL_ADDITIONAL_COMMAND_DIRS` | Fully qualified paths of your custom laradockctl command directories, separated by `:`. For example: `$PWD/.laradock/commands`. |
| `LARADOCKCTL_CONTAINER_NAMES` | Names of containers to start up, separated by `,`. For example: `nginx,mysql`. If omitted, start up the workspace container only. |
| `LARADOCKCTL_ENV_FILE` | The fully qualified path of your environment variables file to copy to `.env`. For example: `$PWD/.laradock/env-development`. If ommited, use `.env` in the `laradock` directory.  |
| `LARADOCKCTL_PHIVE_HOME_DIR_CONTAINER` | The fully qualified path or path relative to `/var/www` of the PHIVE home directory in the workspace container. For example: `.laradock/data/phive`. If ommited, use the PHIVE default. |

### Default Commands
All laradockctl commands begin with `laradockctl`. The available commands are as follows:
* `artisan` Execute an Artisan command in the workspace container
* `composer` Execute a Composer command in the workspace container
* `destroy` Destory a development environment
* `down` Shut down a development environment
* `list` List commands
* `logs` View application logs
* `npm` Execute an NPM command in the workspace container
* `phive` Execute a PHIVE command in the workspace container
* `up` Start up a development environment

### Execute Docker Compose Commands
To execute Docker Compose commands, which is not defined as the laradockctl command, you can use the `--docker-compose-command` or `-d` option:
```console
laradockctl --docker-compose-command='exec workspace bash'
```

### More Usage
To see more usage, please use the `--help` or `-h` option.
```console
laradockctl --help
```

## Custom Commands
You can write custom commands by Bash and add it to laradockctl.
You must define the `NAME` constant, `DESCRIPTIPON` constant and `handle` function in your custom command.

The `NAME` constant allow you to define a command name. It is possible to define a namespace by separating the command name with `:`.
The `DESCRIPTIPON` constant allow you to define a description of the command.
The `NAME` and `DESCRIPTIPON` constants are used to display your custom command in the result of the `list` command.
The `handle` function will be called when your custom command is executed. You may write the logic of the command in this function.

The following is an example of a custom command to start up the Laravel application development environment:
```bash
#!/bin/bash

set -Ceuo pipefail

local NAME='namespace:command'
local DESCRIPTION='The command description'

handle() {
  #
}
```
**Note:** The current path when executing the custom command is your `laradock` directory.

You need to add your custom command file or the directory where your custom command is located to the `PATH` environment variable:
```bash
export LARADOCKCTL_ADDITIONAL_COMMAND_DIRS=/PATH_TO_YOUR_CUSTOM_COMMAND_DIR
```
Now you can run the custom command:
```console
laradockctl namespace:command
```

## License
laradockctl is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT).
