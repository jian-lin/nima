{ config, ... }:

{
  order = if config.pedantic then 2 else 3;
}
