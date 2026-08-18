# GAPSI-iOS_EXAMEN

Proyecto desarrollado como parte de una evaluación técnica de iOS.

# Walmart Product Search - iOS

Aplicación nativa para iOS que permite buscar productos del catálogo de Walmart mediante la API proporcionada a través de RapidAPI.

## Tecnologías

* Swift 6+
* UIKit
* UICollectionView
* UITableView
* Alamofire
* MVVM
* async/await
* UserDefaults
* iOS 16+

## Funcionalidades

* Búsqueda de productos por palabra clave.
* Consulta de productos mediante la API proporcionada.
* Visualización de:
  * Imagen del producto.
  * Título.
  * Precio.
* Paginación automática al realizar scroll.
* Historial de búsquedas.
* Persistencia del historial después de cerrar y volver a abrir la aplicación.
* Manejo de estados de carga y errores.
* Manejo de estados vacíos cuando no existen resultados.
* La interfaz permanece disponible mientras se realizan las peticiones de red.

## Arquitectura

El proyecto utiliza una arquitectura basada en **MVVM**, separando la presentación, lógica de negocio, acceso a datos y comunicación con la API.

```text
SearchViewController
        ↓
SearchViewModel
        ↓
    APIClient
        ↓
   Alamofire
        ↓
   RapidAPI
```

### Responsabilidades

**SearchViewController**

* Gestiona la interfaz de usuario.
* Configura y actualiza la `UICollectionView`.
* Gestiona las interacciones del usuario.
* Observa los cambios publicados por el ViewModel.

**SearchViewModel**

* Contiene la lógica de presentación.
* Gestiona el estado de búsqueda.
* Coordina la paginación.
* Gestiona el historial de búsquedas.
* Expone los estados de carga, resultados y errores.

**APIClient**

* Centraliza las peticiones HTTP.
* Gestiona la comunicación con RapidAPI.
* Decodifica las respuestas.
* Gestiona los errores relacionados con la comunicación de red.

## Configuración de API

La aplicación requiere una API Key para consumir el servicio proporcionado mediante RapidAPI.

La clave se configura mediante `Info.plist` utilizando la propiedad:

```text
REMOTE_SERVICE_KEY
```

El valor almacenado en `Info.plist` se encuentra codificado en Base64 y es decodificado en tiempo de ejecución mediante `APIConfiguration`.

### Configuración local

1. Abrir `Info.plist`.
2. Agregar la propiedad `REMOTE_SERVICE_KEY`.
3. Establecer como valor la API Key codificada en Base64.
4. Ejecutar la aplicación.

Ejemplo:

```text
REMOTE_SERVICE_KEY = <BASE64_API_KEY>
```

> **Nota de seguridad:** Base64 es un mecanismo de codificación y no de cifrado. Para un entorno productivo, las credenciales sensibles deberían mantenerse fuera de la aplicación cliente y gestionarse mediante un backend seguro.

## Persistencia

El historial de búsquedas se almacena utilizando `UserDefaults`, permitiendo conservar las búsquedas realizadas incluso después de cerrar y volver a abrir la aplicación.

## Networking

Las peticiones de red se realizan mediante **Alamofire** y utilizan `async/await` para facilitar el manejo de operaciones asíncronas.

La capa `APIClient` centraliza la comunicación con la API y mantiene desacoplada la lógica de red respecto de la interfaz de usuario.

## Paginación

La aplicación implementa paginación automática al realizar scroll.

Cuando el usuario se aproxima al final de la lista:

1. Se verifica si existe una siguiente página.
2. Se evita realizar múltiples solicitudes simultáneas.
3. Se solicita la siguiente página.
4. Los nuevos resultados se agregan a los existentes.
5. La colección se actualiza manteniendo los resultados previamente cargados.

## Manejo de estados

La interfaz contempla diferentes estados durante el ciclo de búsqueda:

* Estado inicial.
* Cargando.
* Resultados disponibles.
* Sin resultados.
* Error de red o de API.
* Carga de páginas adicionales.

Esto permite proporcionar retroalimentación al usuario y evitar interacciones inconsistentes mientras se realizan las peticiones.

## Decisiones técnicas

* **UIKit:** utilizado para mantener control sobre la composición y comportamiento de la interfaz.
* **MVVM:** utilizado para separar responsabilidades y facilitar el mantenimiento de la lógica de presentación.
* **Alamofire:** utilizado para simplificar la construcción y gestión de las solicitudes HTTP.
* **async/await:** utilizado para manejar operaciones asíncronas de forma clara y mantener separada la lógica de red de la interfaz.
* **UserDefaults:** utilizado para persistir el historial de búsquedas, debido a que se trata de información pequeña y sencilla.
* **UICollectionView:** utilizada para representar el catálogo de productos y soportar la carga incremental mediante paginación.

## Requisitos

* Xcode compatible con Swift 6+
* iOS 16+
* Conexión a Internet
* API Key válida para RapidAPI

## Ejecución

1. Clonar el repositorio.
2. Abrir el proyecto en Xcode.
3. Configurar `REMOTE_SERVICE_KEY` en `Info.plist`.
4. Seleccionar un simulador o dispositivo con iOS 16+.
5. Ejecutar el proyecto.

## Consideraciones

Este proyecto fue desarrollado como parte de una evaluación técnica y busca demostrar:

* Desarrollo nativo con UIKit.
* Implementación de arquitectura MVVM.
* Consumo de APIs REST.
* Manejo de concurrencia con `async/await`.
* Manejo de estados de UI.
* Paginación.
* Persistencia local.
* Separación de responsabilidades.
* Manejo de errores.
* Integración con servicios externos.

