defmodule FfSwitcher do
  alias FfSwitcher.ConfigParser
  import System

  @window_map "window_map.json"

  @moduledoc """
  Documentation for FfSwitcher.
  """

  @doc """
  Hello world.

  """
  def main([query | _] \\ []) do

    query_group = ConfigParser.get_query_group query
    clear_closed_groups
    open query_group, query
  end

  def clear_closed_groups do
    window_map = get_window_map
    window_list = Map.values window_map

    opened_window_list= case cmd("xdotool", ["search", "--classname", "Navigator"]) do 
      {t, 0} -> String.split t
      {_, 1} -> []
    end
    need_to_be_deleted = window_list -- opened_window_list;
    to_be_deleted = Enum.map need_to_be_deleted, fn x -> get_key_from_value window_map,x end

    new_window_map = Map.drop window_map, to_be_deleted
    IO.inspect new_window_map
    {:ok, new_window_map_encoded} = Poison.encode(new_window_map)
    IO.inspect new_window_map_encoded
    File.write @window_map, new_window_map_encoded 
    new_window_map
  end

  def get_key_from_value(map, value) do
    map
    |> Enum.find(fn {key, val} -> val == value end)
    |> elem(0)
  end

  def open_and_get_new_firefox_window_id do
    spawn fn -> cmd("firefox", []) end
    :timer.sleep(1000)
    {opened_window_list, 0} = cmd("xdotool", ["search", "--classname", "Navigator"])
    window_map = get_window_map
    IO.puts "here"
    IO.inspect window_map
    [new_window_id] = (String.split opened_window_list) -- (Map.values window_map)
    new_window_id
  end

  defp focus_window_id(window_id) do
    cmd("xdotool", ["windowactivate", window_id])
  end

  def search_window_id_by_group(group) do
    window_map = get_window_map
    case Map.fetch window_map,(to_string group) do
      {:ok, value} -> value
      :error -> new_window_id = open_and_get_new_firefox_window_id;update_window_map(new_window_id, group);new_window_id
    end
  end

  def get_window_map do
    {:ok, map_file} = File.open @window_map
    {:ok, window_map} =  Poison.decode(IO.read(map_file, :all))
    File.close map_file
    window_map
  end

  def update_window_map(window_id, group) do
    {:ok, map_file} = File.open @window_map
    {:ok, window_map} =  Poison.decode(IO.read(map_file, :all))
    File.close map_file
    new_window_map = Map.put window_map, group, window_id 
    IO.inspect new_window_map
    {:ok, new_window_map_encoded} = Poison.encode(new_window_map)
    IO.inspect new_window_map_encoded
    File.write @window_map, new_window_map_encoded 
    new_window_map
  end

  def open_firefox do
    cmd("firefox", [])
  end
  def open_firefox do
    cmd("firefox", [])
  end

  defp match_query_group([{group_name, [first_url | _]} | _], query) when query == first_url do
    List.to_atom group_name
  end

  defp match_query_group([{group_name, [first_url | others_urls]} | other_groups], query) when query != first_url do
    match_query_group([{group_name, others_urls} | other_groups], query)
  end

  defp match_query_group([{group_name, []} | other_groups], query) do
    match_query_group(other_groups, query)
  end

  defp match_query_group([], query) do
    :other
  end

  defp get_url(path) do
    case Domainatrex.parse(path) do
      {:ok, %{domain: domain, tld: tld}} -> {:domain, domain <> "." <> tld}
      {:error, _} -> {:non_domain, path}
    end
  end

  defp open(:search, search_query) do
    window_id = search_window_id_by_group(:search)
    focus_window_id(window_id)
    cmd("firefox", ["www.google.com/search?q=#{search_query}"])
  end

  defp open(group, query) do
    window_id = search_window_id_by_group(group)
    focus_window_id(window_id)
    cmd("firefox", [query])
  end
end
