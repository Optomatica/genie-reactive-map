### What do we understand about internals?

*Model* is the central part of the app that holds the state of the app. It is a dictionary that holds the values of the reactive variables. It is also responsible for triggering the reactive code when a reactive variable changes. To declare a model we use `@app` macro like this:
```
  @app begin
    ...
  end
```
or by providing model name
```
@app my_model begin
  ...
end
```
The model name is essential in our case so that we can initialize the model in the `GET` request and use it after that.
#### How does communication work between the model and the UI?
using websockets. The model is the server and the UI is the client. The UI sends a message to the model and the model responds with a message. The message is a JSON object that contains the name of the reactive variable and its value. The UI then updates the value of the reactive variable in the model. The model then triggers the reactive code if there is any.

Websockets cannot be used to send files so we'll need to use HTTP requests to send files. Once the http request is arrived we set the value of the reactive variable in the model.

### What is exactly a mixin?

Mixin is a macro that enables us to attach an inner model to the current model. An organizing way to group like variables in a model. There are 2 main ways to use it: 
1. With prefix
```
@mixin data::DataModel
```

2. Without prefix
```
@mixin ScatterModel
```

### Should I use `ui.jl` or `ui.jl.html`?

I personally find dealing with XML like syntax in `ui.jl.html` is much better because it's easy to nest components and format them in a readable way. However, We could not do that because we needed to use the `StippleUI.layout` component. The problem is that we could not easily write `<layout>` because `MethodError: no method matching layout` will be thrown. So, we have to use `ui.jl` instead.

### Hot reloading does not really work

It only works when changing a statement inside @onchange. Changes in ui.jl and modules do not trigger auto-reload making the dev process to be slower.

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

when listing multiple variables in @onchange they should be separated by a comma.

### Are @in and @out conventions?

We tested changing @out variable from the ui and it worked.



### Code UI editor did not work
![Alt text](image.png)

### The new documentation is great but it's not complete
### Is there a way to make a loading screen? `isprocessing` is not working

### Resources
1. https://plotly.com/javascript/mapbox-layers/
2. https://learn.genieframework.com/examples/reactive-ui/mutating-reactive-variables
3. https://learn.geniecloud.io/guides/implementing-the-app-logic
4. https://quasar.dev/components/
