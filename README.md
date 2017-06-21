# Health Check

A repository of various services health checking scripts.

## Usage

All checks here are monitoring system independant. That being said, they should adhere to the [Nagios plugin specification][nagios-plugin-spec] to ensure maximum compatibility with various systems for monitoring such as: [Nagios][nagios], [Consul][consul], [Sensu][sensu] and more.

All checks will have sensible defaults. For example, scripts that require hostnames for service checks will default to `localhost`.

## Basics ##

* Single line out output for service messages/detail
* Return codes:

| Status  | Return Code |
| ------- | ----------- |
| OK      | 0           |
| WARNING | 1           |
| ERROR   | 2           |
| UNKNOWN | 3           |

Where possible, minimal or NO dependencies will be required to run these scripts.

Current dependencies:

* Netcat (`nc`)
* cURL (`curl`)
* tail (`tail`)
* awk (`awk`)
* TR (`tr`)
* grep (`grep`)

## Functions

The following convenience functions are provided:

### `usage`

When called, outputs the usage information from the current source file. Usage information is retrieved by grepping the entire file and looking for lines that begin with `#/`.

### `exit_report(code, message, ...)`

Exits the process with the specified code, after printing out the supplied message. The message can be a single string, or any number of arguments which will be combined into a string.

## Documentation ##

Each check shall provide its own documentation within the script itself.

Each service directory may additionally contain a readme to cover information and references about the service specification etc.

## Contributing

Contributing is simple. Fork this repository, create your new plugin/check code in an appropriately named directory, and submit a pull request.

No contribution is wrong.

Reviews will simply be checks and measures to ensure it follows the standard approach listed above in "Usage", and that its safe code to execute on production systems.

## License

All checks, files and sources are MIT licenced unless otherwise stated.

[nagios-plugin-spec]: https://assets.nagios.com/downloads/nagioscore/docs/nagioscore/3/en/pluginapi.html
[nagios]: https://www.nagios.org/
[consul]: https://www.consul.io/
[sensu]: https://sensuapp.org/
