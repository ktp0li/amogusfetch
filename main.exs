defmodule Amogusfetch do
  defp os_release do
    File.read!("/etc/os-release")
    |> String.split(["\n", "="], trim: true)
    |> Enum.chunk_every(2)
    |> Map.new(fn [k, v] -> {k, v} end)
  end

  defp uptime do
    File.read!("/proc/uptime")
    |> String.split(" ")
    |> hd
    |> String.to_float()
    |> round
    |> then(&Time.add(~T[00:00:00], &1, :second))
  end

  defp shell, do: System.get_env("SHELL")

  defp version do
    File.read!("/proc/sys/kernel/osrelease")
    |> String.trim()
  end

  defp mem do
    File.read!("/proc/meminfo")
    |> then(&Regex.named_captures(~r/^MemTotal:\s*(?<all>\d+)\X*^MemFree:\s*(?<free>\d+)/m, &1))
    |> Map.new(fn {k, v} -> {k, String.to_integer(v) |> div(1024)} end)
  end

  defp cpu do
    File.read!("/proc/cpuinfo")
    |> then(&Regex.run(~r/^model name\W*(\N+)/m, &1, capture: :all_but_first))
    |> List.to_string()
    |> String.downcase()
  end

  defp user, do: System.get_env("USER")

  defp hostname do
    File.read!("/etc/hostname")
    |> String.trim()
  end

  defp colors do
    Enum.map(1..7, fn x -> "\x1b[#{40 + x}m   \x1b[0m" end)
    |> List.to_string
  end

  def debug do
    IO.puts(
    "\x1b[1m#{user()}@#{hostname()}\x1b[0m\n" <>
    "os: #{os_release()["ID"]}\n" <>
    "version: #{version()}\n" <>
    "mem: #{mem()["free"]}/#{mem()["all"]} mib\n" <>
    "cpu: #{cpu()}\n" <>
    "uptime: #{uptime()}\n" <>
    "shell: #{shell()}\n" <>
    "colors: #{colors()}"
    )
  end
end

Amogusfetch.debug()
