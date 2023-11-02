# Url Shortener

### Instalacion

Para instalar hay que hacer solo un `mix deps.get`, para bajar las dependencias

Que pasa si recibo un error como el siguiente?

```
{:failed_connect, [{:to_address, {'repo.hex.pm', 443}}, {:inet, [:inet], {:option, :server_only, :honor_cipher_order}}]}
```

Vamos a tener que ejecutar el siguiente comando -> `mix local.hex` y despues ejecutar el primer comando.

## Como pruebo los cambios desde iex??

Cargando las dependencias y el modulo mediante mix, ejecutando el siguiente comando:

`iex -S mix`

## Introducción

Este repositorio contiene el código de una aplicación `elixir/otp` que permite generar versiones acortadas las urls que el usuario ingresa. Las urls acortadas se pueden obtener en cualquier momento, llamando al proceso que contiene dicha información. 

Para ello, se expone un módulo `UrlShortener.Link` que, al crearse con una url, relaciona dicha url con la versión acortada de la misma.

Podemos crear un nuevo link por medio del supervisor:

```elixir
{:ok, pid} = UrlShortener.LinkDynamicSupervisor.create_link("https://example.com/aftermath.html")
UrlShortener.Link.get_shorten_link(pid)
"http://localhost/74Vn4j3"
```

## Requerimientos

### Parte 1

1. Queremos poder mantener, para cada url, una lista de sus correspondientes urls acortadas, en vez de tener solo una url acortada por `UrlShortener.Link`.

2. Queremos que si crashea o muere un actor `UrlShortener.Link` no se pierdan las urls acortadas que ya fueron generadas. 

3. Por medio de `libcluster`, interconectar un cluster de nodos. Los nodos pueden crearse manualmente.

> Una forma de comprobar de que esto funciona correctamente es que que se puedan ver la lista de nodos. Esto se puede verificar en cualquier nodo del cluster corriendo:

```elixir
Node.list([:this, :visible])
```

4. Distribuir el estado de la aplicacion de forma que, al acortar varias urls, no todas estén almacenadas en el mismo nodo. Por ahora no nos centraremos en la _replicación_, solo nos interesa _particionar_ el estado entre los nodos del cluster.

> Nota: Se puede utilizar `horde`, aunque no es necesario para resolver esto, ya que pueden hacerlo manualmente.

### Parte 2

1. Implementar un esquema _primary/secondary_, donde el estado de cada link se replique en todos los demás nodos, sabiendo cuál es el nodo principal que contiene el estado.

> Nota: En caso de que hayan utilizado `horde`, recuerden que esta librería no resuelve la replicación de los datos. Solamente permite que se puedan crear procesos en distintos nodos. 

2. Ante la caída de un nodo, queremos evitar la pérdida de datos. Los nodos deberían poder levantarse manualmente, y recuperar el estado que tenían antes de caerse.
