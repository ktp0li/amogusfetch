os_release = File.read!("/etc/os-release")
             |> String.split(["\n", "="], trim: true)
             |> Enum.chunk_every(2)
             |> Map.new(fn [k, v] -> {k, v} end)
uptime = File.read!("/proc/uptime")
         |> String.split(" ")
         |> hd 
         |> String.to_float
         |> round
         |> then(fn sec -> Time.add(~T[00:00:00], sec, :second) end)
shell = System.get_env("SHELL")
version = File.read!("/proc/sys/kernel/osrelease")
          |> String.trim
