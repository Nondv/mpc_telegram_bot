# mpc_telegram_bot

MPD telegram bot.

# Usage

### Plain ruby

```
git clone git@github.com:Nondv/mpc_telegram_bot.git
cd mpc_telegram_bot
ruby bot/runner --help
ruby bot/runner -t <YOUR TOKEN>
```


### Docker

```
docker run -d -e TOKEN=<token> -e MPD_HOST=<address> --name mpc_bot nondv/mpc_bot
```

If MPD is running on localhost consider `--network host`:

```
docker run -d -e TOKEN=<token> --network host --name mpc_bot nondv/mpc_bot
```

Commands description for BotFather can be found [here](bot/commands.txt).
