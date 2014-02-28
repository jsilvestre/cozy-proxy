@app.get '/.well-known/host-meta.?:ext', @webfingerHostMeta
@app.all '/.well-known/:module', @webfingerAccount