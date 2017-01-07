defmodule FsharpEx do
    @moduledoc """
    Access F# interactive (FSI) from Elixir.
    """

    use GenServer
    require Logger

    @port_line_max 1024 * 8
    @timeout 10 * 1000

    # Client API
    @doc """
    Starts an F# session
    """
    def start_link do
        GenServer.start_link(__MODULE__, :ok, [])
    end

    @doc """
    Quits an F# sessionF
    """
    def quit(server) do
        GenServer.cast(server, :quit)
    end

    @doc """
    Sends a string of F# code to be evaluated and returns the output of the
    expression as an unformatted string
    """
    def eval(server, expression) do
        GenServer.call(server, {:eval, expression})
    end

    @doc """
    Sends a string of F# code to be evaluated and displays the output of the
    expression.
    """
    def print(server, expression) do
        result = eval(server, expression)
        result
        |> String.trim_leading
        |> String.trim_trailing
        |> add_gutter
        |> IO.puts
    end

    ## Server Callbacks
    def init(:ok) do
        Process.flag(:trap_exit, true)
        port = Port.open({:spawn_executable, find_fsi_path},
                        [:binary, :exit_status,
                         {:args, ["--gui-", "--nologo", "--utf8output"]}])
        {:ok, %{port: port}}
    end

    def handle_call({:eval, "#quit"}, _from, state) do
        {:stop, :normal, :ok, state}
    end

    def handle_call({:eval, expression}, _from, %{port: port} = state) do
        send_data_to_fsi(port, expression)

        case collect_responses(port) do
            {:response, response} ->
                {:reply, response, state}
            :timeout ->
                {:stop, :port_timeout, state}
        end
    end

    def handle_cast(:quit, _state) do
        exit(:normal)
    end

    def handle_info({_port, {:exit_status, 0}}, _state) do
        exit(:normal)
    end

    def handle_info({:EXIT, port, reason}, %{port: port} = state) do
        {:stop, {:port_terminated, reason}, state}
    end

    def handle_info(unexpected, state) do
        Logger.debug "Ignoring: #{inspect unexpected}"
        {:noreply, state}
    end

    def terminate(_reason, %{port: port}) do
        if Port.info port != nil do
            Logger.debug "Closing port [#{inspect port}]."
            Port.close port
        end
    end

    ## Helper functions
    defp add_gutter(multi_line_text) do
        prefixed = "\n" <> multi_line_text
        gutter = "\n#{IO.ANSI.cyan_background}#{IO.ANSI.white}F#:"
                 <> "#{IO.ANSI.default_background}#{IO.ANSI.default_color} "
        String.replace(prefixed, "\n", gutter)
    end

    defp collect_responses(port) do
        collect_responses(port, "")
    end

    defp collect_responses(_port, accumulator) do
        receive do
            {_port, {:exit_status, 0}} ->
                exit(:normal)
            {port, {:data, data}} ->
                Logger.debug "#{inspect {port, {:data, data}}}"

                combined = accumulator <> data
                if String.ends_with?(data, "> ") do
                    response = combined
                        |> String.trim_trailing("> ")
                        |> String.trim
                    {:response, response}
                else
                    collect_responses(port, combined)
                end
        after @timeout ->
            :timeout
        end
    end

    defp find_fsi_path do
        fsi_names = Application.get_env(:fsharp_ex, :fsi_names)

        fsi = fsi_names
            |> Enum.find_value(&System.find_executable/1)

        if fsi == nil do
            raise "Could not locate the interactive in the path."
                <> " Searched for #{inspect fsi_names}."
        else
            fsi
        end
    end

    defp send_data_to_fsi(port, msg_to_fsi) do
        cmd = (msg_to_fsi
                |> String.trim_trailing
                |> String.trim_trailing(";;"))
                <> ";;\n"
        Port.command(port, cmd)
    end
end
