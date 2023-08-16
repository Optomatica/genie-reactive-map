### Should I use `ui.jl` or `ui.jl.html`?
I personally find dealing with XML like syntax in `ui.jl.html` is much better because it's easy to nest components and format them in a readable way. However, We could not do that because we needed to use the `StippleUI.layout` component. The problem is that we could not easily write `<layout>` because `MethodError: no method matching layout` will be thrown. So, we have to use `ui.jl` instead.

### Hot reloading does not really work

### @onchange example
documentation is not actually right
```
  @app begin
      # reactive variables taking their value from the UI
      @in N = 0
      @in M = 0
      @out result = 0
      # reactive code to be executed when N changes
      @onchange N M begin
          result = 10*N*M
      end
  end
```


