use Mix.Config

config :fsharp_ex,
    fsi_names: ["fsi", "fsharpi"]

config :logger,
    level: :info

config :logger,
    :console,
    format: "\n$time $metadata[$level] $levelpad$message\n"
