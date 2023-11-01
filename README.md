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

Este repositorio contiene el código de una aplicación `elixir/otp`, que permite acortar la longitud de una url que se le pasa al sistema, y que se puede obtener en cualquier momento, llamando al proceso que contiene dicha informacion. 

Para ello, se expone un módulo `UrlShortener.Link` que al crearse, con una url, y un nombre de identificacion, relaciona el link, que despues podremos servir en nuestro dominio.

Para crear un nuevo link deberemos crear uno por medio del supervisor

```elixir
{:ok, pid} = UrlShortener.LinkDynamicSupervisor.create_link("https://example.com/aftermath.html")
UrlShortener.Link.get_shorten_link(pid)
"http://localhost/74Vn4j3"
```

Basta con llamar a crear un link, que creara no solo un link, despues de eso el `UrlShortener.Link` creado posee toda la informacion necesaria para poder generar una url acortada y saber a que url completa pertenece.

## Requerimientos

### Parte 1

1. Queremos poder mantener, para cada url, una lista de sus correspondientes urls acortadas, en vez de tener solo una url acortada por `UrlShortener.Link`.

2. Queremos que si se crashea o muere un actor `UrlShortener.Link`, no se pierdan los links acortados que ya fueron generados. 

3. Por medio de `libcluster`, interconectar un cluster de nodos que pueden crearse manualmente

> Una forma de comprobar de que esto funciona correctamente es que que se puedan ver la lista de nodos. Esto se puede verificar en cualquier nodo del cluster corriendo

```elixir
Node.list([:this, :visible])
```

4. Distribuir el estado de la aplicacion, de forma que al acortar varios links, no todos esten almacenados en el mismo nodo. Por ahora no nos centraremos en la _replicacion_, solo nos interesa _particionar_ el estado entre los nodos del cluster.

> Nota: Se puede utilizar `horde`, aunque no es necesario para resolver esto, ya que pueden hacerlo manualmente.


### Parte 2

1. Replicar el estado de un dato, en todos los nodos, sabiendo cual es el nodo principal que contiene dicho dato. El esquema que queremos implementar en este caso, es el de _primary/secondary_.

> Nota: En caso de que hayan utilziado `horde`, recuerden que esta libreria no resuelve la replicacion de los datos. Solamente permite que se puedan crear procesos en distintos nodos. 

2. Ante la caida de un nodo, queremos evitar la perdida de datos. Los nodos deberian poder levantarse, manualmente, y recuperar el estado que tenian antes de caerse.