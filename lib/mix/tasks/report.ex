defmodule Mix.Tasks.Report do
  use Mix.Task

  def run(_) do
    ScanTest.run()
  end
end
