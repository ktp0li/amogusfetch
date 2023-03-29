defmodule Amogusfetch do
  def main do
    {args, _, _} =
      System.argv()
      |> OptionParser.parse(
        aliases: [b: :body_color, w: :window_color],
        strict: [body_color: :string, window_color: :string]
      )

    Enum.zip([Amogusfetch.picture(args[:body_color], args[:window_color]), Amogusfetch.values()])
    |> Enum.map(fn {x, y} -> x <> String.duplicate(" ", 5) <> y end)
    |> IO.puts()
  end

  defp term, do: System.get_env("TERM") |> String.downcase()

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
    |> then(fn x ->
      if(x.hour > 23, do: "#{div(x.hour, 24)}d ", else: "") <>
        if(0 < x.hour and x.hour < 24, do: "#{rem(x.hour, 24)}h ", else: "") <>
        "#{x.minute}m"
    end)
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
    |> String.replace(["intel(r) core(tm) ", "cpu ", "amd"], "")
  end

  defp user, do: System.get_env("USER")

  defp hostname do
    File.read!("/etc/hostname")
    |> String.trim()
  end

  defp colors do
    Enum.map(1..7, fn x -> "\x1b[#{40 + x}m   \x1b[0m" end)
    |> List.to_string()
  end

  def picture(fir, sec) do
    [fir, sec] = Enum.map([fir, sec], &String.to_atom(to_string(&1)))

    colors =
      Enum.zip(
        ["gray", "red", "green", "yellow", "blue", "violet", "light_blue", "white"],
        30..37
      )
      |> Enum.map(fn {x, y} -> {String.to_atom(x), y} end)

    win = "\x1b[#{colors[sec]}m"
    clear = "\x1b[0m"
    body = "\x1b[#{colors[fir]}m"

    [
      "      #{body}.mmmmmmmmmmmmmmm.#{clear}        ",
      " #{win}.+oooooooooooo+.#{clear}#{body}     'm.#{clear}      ",
      "#{win}oooooooooooooooooo#{clear}#{body}       mmmmm.#{clear}",
      "#{win}oooooooooooooooooo#{clear}#{body}       m::::m#{clear}",
      " #{win}'+oooooooooooo+'#{clear}#{body}        m::::m#{clear}",
      "     #{body}m                   m::::m#{clear}",
      "     #{body}m   +mmmmmmm.       mmmmm'#{clear}",
      "     #{body}m    'm     'm      m#{clear}     ",
      "     #{body}.mmmm.#{clear}        #{body}.mmmm.#{clear}      "
    ]
  end

  def values do
    clear = "\x1b[0m"
    bold = "\x1b[1m"

    [
      "#{bold}#{user()}@#{hostname()}#{clear}\n",
      "os: #{os_release()["ID"]}\n",
      "kernel: #{version()}\n",
      "mem: #{mem()["all"] - mem()["free"]}/#{mem()["all"]} mib\n",
      "cpu: #{cpu()}\n",
      "uptime: #{uptime()}\n",
      "shell: #{shell()}\n",
      "term: #{term()}\n",
      "#{colors()}"
    ]
  end
end

Amogusfetch.main()
