defmodule FfSwitcher do
  import System
  @moduledoc """
  Documentation for FfSwitcher.
  """

  @doc """
  Hello world.

  """
  def main([query | _] \\ []) do
    %URI{path: path} = URI.parse(query)
    {type, formatted_query} = get_url(path)

    config = parse_config

    query_group =
      case type do
        :domain -> match_query_group(config, to_charlist formatted_query)
        _ -> :search
      end
    IO.puts query_group

    open(query_group, query)
  end

  def open_and_get_new_firefox_window_id do
    spawn fn -> cmd("firefox", []) end 
    :timer.sleep(1000)
    {window_list1, 0} = cmd("xdotool", ["search", "--classname", "Navigator"])
    {window_list2, 0} = cmd("xdotool", ["search", "--class", "Firefox"])
    l1 = String.split window_list1
    l2 = String.split window_list2
    
    IO.inspect l1
    IO.inspect l2
     [window_id | _] = (l1 -- (l1 -- l2))
    IO.puts "hrereer"
    IO.puts window_id

     window_id
  end

  defp set_name_for_firefox_window(window_id, name) do
    t = cmd("xdotool", ["set_window", "--name", name, window_id])
    IO.inspect t
  end

  defp focus_window_id(window_id) do
    cmd("xdotool", ["windowactivate", window_id])
  end

  defp parse_config do
    List.flatten(:yamerl_constr.file("config.yaml"))
  end


  def search_window_id_by_group(group) do
    IO.puts to_string group
    IO.puts "group"
    case cmd("xdotool", ["search", "--name", to_string group]) do
      {group_id, 0} -> List.first(String.split group_id)
      {_, 1}        -> window_id = open_and_get_new_firefox_window_id; IO.puts "here window_id"; IO.inspect window_id; set_name_for_firefox_window(window_id, to_string group);window_id
    end
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

  defp get_url(path) do
    case Domainatrex.parse(path) do
      {:ok, %{domain: domain, tld: tld}} -> {:domain, domain <> tld}
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
