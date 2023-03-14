os_release =
  File.read!("/etc/os-release")
  |> String.split(["\n", "="], trim: true)
  |> Enum.chunk_every(2)
  |> Map.new(fn [k, v] -> {k, v} end)

uptime =
  File.read!("/proc/uptime")
  |> String.split(" ")
  |> hd
  |> String.to_float()
  |> round
  |> then(&Time.add(~T[00:00:00], &1, :second))

shell = System.get_env("SHELL")

version =
  File.read!("/proc/sys/kernel/osrelease")
  |> String.trim()

mem =
  File.read!("/proc/meminfo")
  |> then(&Regex.named_captures(~r/^MemTotal:\s*(?<all>\d+)\X*^MemFree:\s*(?<free>\d+)/m, &1))
  |> Map.new(fn {k, v} -> {k, String.to_integer(v) |> div(1024)} end)

cpu =
  File.read!("/proc/cpuinfo")
  |> then(&Regex.run(~r/^model name\W*(\N+)/m, &1, capture: :all_but_first))
  |> List.to_string()
  |> String.downcase()

user = System.get_env("USER")

hostname =
  File.read!("/etc/hostname")
  |> String.trim()
