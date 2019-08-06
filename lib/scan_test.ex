defmodule ScanTest do
  @num_runs 1000
  @increments 4

  def run do
    IO.puts("SCAN 0 MATCH x* COUNT <count>")
    IO.puts("")

    values(@increments)
    |> Enum.sort_by(&elem(&1, 0))
    |> report()

    IO.puts("")

    values(@increments)
    |> Enum.sort_by(&elem(&1, 1))
    |> report()
  end

  defp report(values) do
    ["avg ms", "dbsize", "count"]
    |> print_columns(underline: true)

    values
    |> Enum.each(fn {dbsize, count} ->
      measure(dbsize, count)
    end)
  end

  def values(inc) do
    for count_factor <- 1..inc, dbsize_factor <- 2..(inc + 1) do
      dbsize = round(:math.pow(10, dbsize_factor))
      count = round(:math.pow(10, count_factor))
      {dbsize, count}
    end
  end

  defp measure(dbsize, count) do
    Redix.command(:redix, ["FLUSHDB"])
    create_dataset(dbsize)

    {time, _result} =
      :timer.tc(fn ->
        1..@num_runs
        |> Enum.each(fn _ ->
          scan(count)
        end)
      end)

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
    Redix.command(:redix, ["SCAN", 0, "MATCH", "x*", "COUNT", count])
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
