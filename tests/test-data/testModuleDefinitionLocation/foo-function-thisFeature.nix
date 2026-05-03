{ thisFeature }:

{ config, ... }:

{
  config.features.${thisFeature} = {
    order = if config.pedantic then 7 else 8;
  };
}
