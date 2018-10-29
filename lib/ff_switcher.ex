defmodule FfSwitcher do
  alias FfSwitcher.ConfigParser
  alias FfSwitcher.Firefox

  @moduledoc """
  Documentation for FfSwitcher.
  """

  @doc """
  Hello world.

  """
  def main([query | _] \\ []) do
    query_group = ConfigParser.get_query_group(query)
    Firefox.clear_closed_groups()
    Firefox.open(query_group, query)
  end
end
