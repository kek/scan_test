defmodule Mix.Tasks.Report do
  use Mix.Task

  def run(_) do
    Application.ensure_all_started(:scan_test)
    ScanTest.run()
  end
end
