defmodule FfSwitcher do
  @moduledoc """
  Documentation for FfSwitcher.
  """

  @doc """
  Hello world.

  """
  def main(args \\ []) do
    %URI{path: path} = URI.parse args
    IO.puts path
    config_yaml = :yamerl_constr.file("config.yaml")
  end

  def open({_, 1}, url) do
    System.cmd("firefox", [url])
  end

  def open({window_ids, 0}, url) do
  
  end
end
