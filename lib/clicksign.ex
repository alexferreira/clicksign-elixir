defmodule Clicksign do
 
  def config do
    Application.get_env(:clicksign, Clicksign) |> Enum.into(%{})
  end

  def all do
    HTTPoison.get!("#{config.host}/#{config.api_version}/documents?access_token==#{config.token}", ["Accept": "application/json"])
      |> Map.get(:body)
      |> JSX.decode([{:labels, :atom}])
  end

  def show(key) do
    url = "#{config.host}/#{config.api_version}/documents/#{key}?access_token==#{config.token}"

    HTTPoison.get!(url, ["Accept": "application/json"])
      |> Map.get(:body)
      |> JSX.decode([{:labels, :atom}])
  end

  def process_signer(payload) do
    Enum.map(payload, fn{k, v} -> {"signers[][#{k}]", v} end)
  end

  def process_signers(payload) do
    Enum.reduce(payload, [], &(&2 ++ process_signer(&1)))
  end

  def process_file(payload) do
    {
      payload.name, 
      payload.file, 
      { ["form-data"], [name: "document[archive][original]", filename: payload.name]},
      []
    }
  end

  def process_payload(payload) do
    skip_email = if payload.skip_email, do: "true", else: "false"
    list = [] ++ process_signers(payload.signers)
    list = list ++ [{"skip_email", skip_email}]
    list = list ++ [process_file(payload.document)]

    {:multipart, list}
  end

  def create(payload) do
    headers = ["Accept": "application/json", "Content-Type": "multipart/form-data; boundary=----WebKitFormBoundaryjm7rLhiPSO6cEjWs"]
    url = "#{config.host}/#{config.api_version}/documents?access_token=#{config.token}"
    params = process_payload(payload)

    case HTTPoison.post(url, params, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, result} = JSX.decode(body, [{:labels, :atom}]) 
        result |> Map.get(:document)
      {:ok, %HTTPoison.Response{status_code: 401, body: body}} ->
        body
      {:ok, %HTTPoison.Response{status_code: 404, body: body}} ->
        "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end

  def list(key, payload) do
    headers = ["Accept": "application/json"]
    url = "#{config.host}/#{config.api_version}/documents/#{key}/list?access_token=#{config.token}"
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

  def cancel(key) do
    headers = ["Accept": "application/json"]
    url = "#{config.host}/#{config.api_version}/documents/#{key}/cancel?access_token=#{config.token}"

    case HTTPoison.post(url, [], headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, result} = JSX.decode(body, [{:labels, :atom}]) 
        result |> Map.get(:document)
      {:ok, %HTTPoison.Response{status_code: 401, body: body}} ->
        body
      {:ok, %HTTPoison.Response{status_code: 404, body: body}} ->
        "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
  end
end
