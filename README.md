# laradockctl
laradockctl is a command wrapper for Laradock.

## What Does laradockctl Do?
laradockctl allows you to complete Laradock operations with short commands without having to move to your `laradock` directory while in your project root directory:
```console
laradockctl workspace:composer install
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
   export PATH=/PATH_TO_LARADOCKCTL/bin:$PATH
   ```
   We recommend using [direnv](https://direnv.net/).
4. Go to the Usage section.

## Basic Usage
### Execute laradockctl Commands
All laradockctl commands begin with `laradockctl`. The available commands are as follows:
* `list` List commands
* `laravel:artisan` Execute an Artisan command
* `laravel:logs` View Laravel logs
* `workspace:composer` Execute a Composer command
* `workspace:npm`  Execute an NPM command

### Execute Docker Compose Commands
To execute Docker Compose commands, which is not defined as laradockctl command, you can use the `--docker-compose-command` or `-d` option:
```console
laradockctl --docker-compose-command='down'
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

local NAME='my:up'
local DESCRIPTION='Start up my development environment'

handle() {
  cp -f ../.laradock/env-development .env
  docker-compose up -d nginx mysql mailhog workspace
  cp ../.env.development ../.env
  docker-compose exec -u laradock workspace composer install
  docker-compose exec -u laradock workspace php artisan key:generate
  docker-compose exec -u laradock workspace php artisan migrate
  docker-compose exec -u laradock workspace npm install
  docker-compose exec -u laradock workspace npm run dev
}
```
**Note:** The current path when executing the custom command is your `laradock` directory.

You need to add your custom command file or the directory where your custom command is located to the `PATH` environment variable:
```bash
export LARADOCKCTL_COMMAND_PATH=/PATH_TO_YOUR_COMMAND:/PATH_TO_LARADOCKCTL/commands
```
Now you can run the custom command:
```console
laradockctl my:up
```

## License
laradockctl is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT).
