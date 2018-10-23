defmodule FfSwitcher.ConfigParser do
  @domain_config "./config.yaml"

  def get_query_group(query) do
    %URI{path: path} = URI.parse(query)
    {type, formatted_query} = get_url(path)
    config = load_config

    query_group =
      case type do
        :domain -> match_query_group(config, to_charlist(formatted_query))
        _ -> :search
      end

    IO.puts("the group is #{query_group}")
    query_group
  end

  defp load_config do
    List.flatten(:yamerl_constr.file(@domain_config))
  end

  defp match_query_group([{group_name, [first_url | _]} | _], query) when query == first_url do
    List.to_atom(group_name)
  end

  defp match_query_group([{group_name, [first_url | others_urls]} | other_groups], query)
       when query != first_url do
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
end
