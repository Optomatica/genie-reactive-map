module App

using GenieFramework
@genietools




@app begin
  @in messge = ""
  @out vowels = 0


  @onchange messge begin
    vowels = length(message)
  end
end


@page("/", "ui.jl")
end
