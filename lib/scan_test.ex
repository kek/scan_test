defmodule ScanTest do
  def run do
    measure(100, 10)
    measure(1000, 10)
    measure(10000, 10)
    measure(100_000, 10)
    IO.puts("---")
    measure(100, 100)
    measure(1000, 100)
    measure(10000, 100)
    measure(100_000, 100)
    IO.puts("---")
    measure(100, 1000)
    measure(1000, 1000)
    measure(10000, 1000)
    measure(100_000, 1000)
    IO.puts("---")
    measure(100, 10000)
    measure(1000, 10000)
    measure(10000, 10000)
    measure(100_000, 10000)
    IO.puts("Done")
  end

  defp measure(dbsize, count) do
    Redix.command(:redix, ["FLUSHDB"])
    {_time, _result} = :timer.tc(fn -> create_dataset(dbsize) end)
    # ms = time / 1000
    # IO.puts("Created dataset size #{dbsize} in #{ms} ms")
    {time, _result} = :timer.tc(fn -> scan(count) end)
    ms = time / 1000
    IO.puts("Scanned dataset size #{format(dbsize)} with count #{format(count)} in #{ms} ms")
    # count_factor = count / ms
    # dbsize_factor = dbsize / ms
    # IO.puts("Count factor: #{count_factor}. Dbsize factor: #{dbsize_factor}")
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
    1..100
    |> Enum.each(fn _ ->
      Redix.command(:redix, ["SCAN", 0, "MATCH", "x*", "COUNT", count])
    end)
  end

  defp format(number) do
    number
    |> inspect()
    |> String.pad_leading(6)
  end
end
