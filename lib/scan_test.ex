defmodule ScanTest do
  @num_runs 1000

  def run do
    IO.puts("Scan test")

    ["avg time", "dbsize", "count"]
    |> print_columns

    measure(100, 10)
    measure(1000, 10)
    measure(10000, 10)
    measure(100_000, 10)
    IO.puts("")
    measure(100, 100)
    measure(1000, 100)
    measure(10000, 100)
    measure(100_000, 100)
    IO.puts("")
    measure(100, 1000)
    measure(1000, 1000)
    measure(10000, 1000)
    measure(100_000, 1000)
    IO.puts("")
    measure(100, 10000)
    measure(1000, 10000)
    measure(10000, 10000)
    measure(100_000, 10000)
  end

  defp measure(dbsize, count) do
    Redix.command(:redix, ["FLUSHDB"])
    {_time, _result} = :timer.tc(fn -> create_dataset(dbsize) end)
    # ms = time / 1000
    # IO.puts("Created dataset size #{dbsize} in #{ms} ms")
    {time, _result} = :timer.tc(fn -> scan(count) end)
    avg_ms = time / 1000 / @num_runs

    [avg_ms, dbsize, count]
    |> print_columns

    # count_factor = count / ms
    # dbsize_factor = dbsize / ms
    # IO.puts("Count factor: #{count_factor}. Dbsize factor: #{dbsize_factor}")
  end

  defp print_columns(columns) do
    columns
    |> Enum.map(&format/1)
    |> Enum.join(" ")
    |> IO.puts()
  end

  defp create_dataset(dbsize) do
    commands =
      1..dbsize
      |> Enum.map(fn i ->
        ["SET", i, 1]
      end)

    Redix.pipeline(:redix, commands)
  end

  defp scan(count) do
    1..@num_runs
    |> Enum.each(fn _ ->
      Redix.command(:redix, ["SCAN", 0, "MATCH", "x*", "COUNT", count])
    end)
  end

  defp format(string) when is_binary(string) do
    string
    |> String.pad_trailing(8)
  end

  defp format(number) when is_float(number) do
    number
    |> Float.round(4)
    |> inspect()
    |> format()
  end

  defp format(number) when is_integer(number) do
    number
    |> Integer.to_string()
    |> format()
  end
end
