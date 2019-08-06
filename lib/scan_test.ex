defmodule ScanTest do
  @num_runs 1000

  def run do
    IO.puts("SCAN 0 MATCH x* COUNT <count>")
    IO.puts("")

    values = [
      [100, 10],
      [1000, 10],
      [10000, 10],
      [100_000, 10],
      [100, 100],
      [1000, 100],
      [10000, 100],
      [100_000, 100],
      [100, 1000],
      [1000, 1000],
      [10000, 1000],
      [100_000, 1000],
      [100, 10000],
      [1000, 10000],
      [10000, 10000],
      [100_000, 10000]
    ]

    ["avg time", "dbsize", "count"]
    |> print_columns(underline: true)

    values
    |> Enum.sort_by(fn [dbsize, _count] -> dbsize end)
    |> Enum.each(fn [dbsize, count] ->
      measure(dbsize, count)
    end)

    IO.puts("")

    ["avg time", "dbsize", "count"]
    |> print_columns(underline: true)

    values
    |> Enum.sort_by(fn [_dbsize, count] -> count end)
    |> Enum.each(fn [dbsize, count] ->
      measure(dbsize, count)
    end)
  end

  defp measure(dbsize, count) do
    Redix.command(:redix, ["FLUSHDB"])
    create_dataset(dbsize)
    {time, _result} = :timer.tc(fn -> scan(count) end)
    avg_ms = time / 1000 / @num_runs

    [avg_ms, dbsize, count]
    |> print_columns
  end

  defp print_columns(columns, underline \\ false) do
    line =
      columns
      |> Enum.map(&format/1)
      |> Enum.join(" ")

    IO.puts(line)

    if underline do
      line
      |> String.replace(~r/./, "-")
      |> IO.puts()
    end
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
