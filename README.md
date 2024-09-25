# BotCity CI/CD Pipeline Utilities

BotCity natively supports GitHub Actions usage via the [BotCity Actions - Bots](https://github.com/marketplace/actions/botcity-actions-bots).

As a way to support many other CI/CD pipeline technologies we provide you with the Bash scripts detailed below.

> [!TIP]
> Check out our examples for many CI/CD pipelines technologies [clicking here](./examples/README.md).

## Bot Management Script

`bot.sh` is a versatile Bash script designed to handle common bot management tasks, including deploying, updating, and releasing bots through the BotCity Orchestrator API.

This script simplifies bot management operations in CI/CD pipelines by providing an easy-to-use command-line interface.

### Features

- **Deploy a bot**: Upload and deploy a new version of a bot.
- **Update a bot**: Update the version of an existing bot.
- **Release a bot**: Release a bot version in the BotCity Orchestrator platform.

### Requirements

- **cURL**: Used to send HTTP requests.
- **Environment Variables**: You must set the following environment variables for authentication:
  - `SERVER`: The BotCity Orchestrator API server URL.
  - `LOGIN`: Your BotCity Orchestrator API login.
  - `KEY`: Your BotCity Orchestrator API key.

> [!TIP]
> You can find your Orchestrator API login and key in the `Dev. Environment` menu.
> More information available in our [documentation](https://documentation.botcity.dev/maestro/features/dev-environment/).

### Usage

The script supports three subcommands: `deploy`, `update`, and `release`. Below are the detailed instructions for using each subcommand.

#### Deploy a Bot

To deploy a bot, use the `deploy` subcommand. This will both deploy and upload a bot to BotCity Orchestrator.

**Required Parameters:**

- `-version`: The version of the bot.
- `-botFile`: The path to the bot's file.
- `-botId`: The bot's unique identifier.
- `-type`: The technology type of the bot (e.g., `python`, `java`, etc.).
- `-repository`: (Optional) The repository label. Defaults to `DEFAULT` if not specified.

```bash
./bot.sh deploy -version "1.0.0" -botFile "/path/to/bot.zip" -botId "MyBotId" -type "python" -repository "DEFAULT"
```

#### Update a Bot

To update a bot, use the `update` subcommand. This command will update the version of the specified bot in BotCity Orchestrator.

**Required Parameters:**

- `-version`: The version of the bot.
- `-botFile`: The path to the bot's file.
- `-botId`: The bot's unique identifier.

```bash
./bot.sh update -version "1.0.0" -botFile "/path/to/bot.zip" -botId "MyBotId"
```

#### Release a Bot

To release a bot, use the `release` subcommand. This subcommand requires only the bot ID and version.

**Required Parameters:**

- `-version`: The version of the bot.
- `-botId`: The bot's unique identifier.

```bash
./bot.sh release -version "1.0.0" -botId "MyBotId"
```

### Example Commands

#### Deploy Example

```bash
./bot.sh deploy -version "1.2.0" -botFile "/home/user/bot.zip" -botId "MyCoolBot" -type "python" -repository "ProductionRepo"
```

#### Update Example

```bash
./bot.sh update -version "1.2.0" -botFile "/home/user/bot_update.zip" -botId "MyCoolBot"
```

#### Release Example

```bash
./bot.sh release -version "1.2.0" -botId "MyCoolBot"
```

### Error Handling

- If the required parameters are not provided, the script will output a usage message and terminate.
- If the API request fails (non-200 status code), an error message will be displayed with details.

## Contributing

Feel free to submit issues or pull requests to improve this script. Contributions are always welcome!

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.
