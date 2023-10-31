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

Para ello, se expone un módulo `UrlShortener.Link` que al crearse, con una url, y un nombre de identificacion, relaciona el link, que despues podremos servir en nuestro dominio. Cabe destacar que por el momento no es importante el que devuelva una url mas alla que se pueda tener la informacion que relacione una url y el string generado que formaria parte de ese link minimalista.

Para crear un nuevo link deberemos crear uno por medio del supervisor

```elixir
UrlShortener.LinkDynamicSupervisor.create_link("https://example.com/aftermath.html")


:ok
```

Basta con llamar a crear un link, que creara no solo un link, despues de eso el `UrlShortener.Link` creado posee toda la informacion necesaria para poder generar una url acortada y saber a que url completa pertenece.

## El ejercicio

Este proyecto funciona, pero tiene algunos problemas notables:

* Si creamos dos links con la misma url, tendremos dos instancias con dos url acortadas identicas, en este caso deberia guardarse en un solo proceso y que se tenga una url con una lista de url acortadas que pertenecen al mismo link
* Estamos tambien guardando el link y la url en un proceso (`UrlShortener.Link`) que deberia responder a los pedidos del sistema por parte de un usuario, deberia este proceso encargarse de guardar una pequenia porcion del estado del sistema?
* La aplicacion no esta distribuida aun, incluso conectando varios nodos, sigue sin estarlo.

Mediante estos problemas se pide:

- Por medio de `libcluster`, interconectar un cluster de nodos que pueden crearse manualmente
- Distribuir la aplicacion, y en particular el estado de la misma, que es lo importante, es decir, que no este toda la informacion en un solo nodo. Se puede utilizar `horde`, aunque no es necesario para resolver esto.
- Resolver el problema de que puedan tenerse una lista de url acortadas por cada url que queremos ingresar al sistema.


### En una segunda parte

Se piden estos requerimientos

- Replicar el estado de un dato, en todos los nodos, sabiendo cual es el nodo principal que contiene dicho dato.
- Que sea tolerante y pueda recuperarse el estado frente a fallos.
