{ config, ... }:

{
  config.features.foo-function-standard = {
    order = if config.pedantic then 5 else 6;
  };
}
