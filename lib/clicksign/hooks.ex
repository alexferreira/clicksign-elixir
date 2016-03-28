defmodule Clicksign.Hooks do
  
  def config do
    Application.get_env(:clicksign, Clicksign) |> Enum.into(%{})
  end

  def all(key) do
    headers = ["Accept": "application/json", "Content-Type": "application/json"]
    url = "#{config.host}/#{config.api_version}/documents/#{key}/hooks?access_token=#{config.token}"

    HTTPoison.get!(url, headers)
      |> Map.get(:body)
      |> JSX.decode!([{:labels, :atom}])
  end

  def create(key, payload) do
    headers = ["Accept": "application/json", "Content-Type": "application/json"]
    url = "#{config.host}/#{config.api_version}/documents/#{key}/hooks?access_token=#{config.token}"
    
    params = JSX.encode!(payload)

    case HTTPoison.post(url, params, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, result} = JSX.decode(body, [{:labels, :atom}])
        result
      {:ok, %HTTPoison.Response{status_code: 401, body: body}} ->
        body
      {:ok, %HTTPoison.Response{status_code: 404, body: body}} ->
        "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end

  def delete(key, id) do
    headers = ["Accept": "application/json", "Content-Type": "application/json"]
    url = "#{config.host}/#{config.api_version}/documents/#{key}/hooks/#{id}?access_token=#{config.token}"
  
    case HTTPoison.delete(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 204, body: body}} ->
        :ok
      {:ok, %HTTPoison.Response{status_code: 401, body: body}} ->
        body
      {:ok, %HTTPoison.Response{status_code: 404, body: body}} ->
        "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end


end
