defmodule TpLinkHs100.Switch do

  @default_options [
    # Port used for broadcasts.
    broadcast_port: 9999,
    # Address used for broadcasts.
    broadcast_address: "255.255.255.255",
    # Sending broadcasts every milliseconds.
    refresh_interval: 5000
  ]

  defmodule State do
    defstruct [
      options: [],
      socket: nil,
      timer: nil,
      devices: %{},
    ]
  end


  use GenServer
  require Logger

  alias TpLinkHs100.Encryption

  #--- Public

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    opts = Keyword.merge(@default_options, opts)

    {:ok, socket} = create_udp_socket()

    {:ok, timer} = :timer.apply_interval(opts[:refresh_interval], __MODULE__, :refresh, [self()])

    {:ok, %State{options: opts, socket: socket, timer: timer}}
  end

  def refresh(process) do
    GenServer.cast(process, :refresh)
  end

  def off(id) do
    IO.puts "turning off"
    GenServer.cast(__MODULE__, {:off, id})
  end

  def on(id) do
    IO.puts "turning on"
    GenServer.cast(__MODULE__, {:on, id})
  end

  def devices do
    IO.puts "\n------------------"
    GenServer.call(__MODULE__, :get_devices)
  end

  #--- Callbacks

  def handle_cast(:refresh, state) do
    :ok = :gen_udp.send(
      state.socket,
      to_charlist(state.options[:broadcast_address]),
      state.options[:broadcast_port],
      Encryption.encrypt(Poison.encode!(%{"system" => %{"get_sysinfo" => %{}}}))
    )
    {:noreply, state}
  end

  def handle_cast({:off, id}, state) do
    ip = state.devices
    |> Map.get(id)
    |> Map.get(:ip)

    :gen_udp.send(
      state.socket,
      to_charlist(ip),
      state.options[:broadcast_port],
      Encryption.encrypt(%{system: %{set_relay_state: %{state: 0}}} |> Poison.encode!)
    )
    {:noreply, state}
  end

  def handle_cast({:on, id}, state) do
    ip = state.devices
    |> Map.get(id)
    |> Map.get(:ip)

    :gen_udp.send(
      state.socket,
      to_charlist(ip),
      state.options[:broadcast_port],
      Encryption.encrypt(%{system: %{set_relay_state: %{state: 1}}} |> Poison.encode!)
    )
    {:noreply, state}
  end

  def handle_call(:get_devices, _from, state) do
    resp = state.devices
    {:reply, resp, state}
  end

  def handle_info(resp = {:udp, socket, ip, port, data}, %State{socket: socket} = state) do
    state = handle_response(state, ip, port, data)
    {:noreply, state}
  end

  #--- Internals

  defp handle_response(%State{} = state, ip, port, data) do
    case decrypt_and_parse(data) do
      %{"system" => %{"get_sysinfo" => sysinfo}} ->
        set_device(state, ip_to_string(ip), port, sysinfo)
      other ->
        IO.puts "unknown message to parse"
        IO.inspect state
    end
  end

  defp create_udp_socket() do
    :gen_udp.open(0, [
     :binary, # Sending data as binary.
     {:broadcast, true}, # Allowing broadcasts.
     {:active, true}, # New messages will be given to handle_info()
   ])
 end

  defp set_device(state, ip, port, %{"deviceId" => device_id} = sysinfo) do
    device_info = %{ip: ip, port: port, sysinfo: sysinfo}
    %{state|
      devices: Map.put(state.devices, device_id, device_info)
    }
  end

  defp ip_to_string({ip1, ip2, ip3, ip4}), do: "#{ip1}.#{ip2}.#{ip3}.#{ip4}"

  defp decrypt_and_parse(data), do: data |> Encryption.decrypt |> Poison.decode!

end
