module App
using GenieFramework
@genietools

function count_vowels(message)
    sum([c ∈ ['a', 'e', 'i', 'o', 'u'] for c in lowercase(message)])
end

@app begin
    @in message = ""
    @out vowels = 0
    @onchange message begin
        vowels = count_vowels(message)
    end
end

@page("/", "app.jl.html")
end
