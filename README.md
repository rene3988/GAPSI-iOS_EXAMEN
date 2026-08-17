# GAPSI-iOS_EXAMEN
Proyecto para evaluación de iOS

# Walmart Product Search - iOS

Aplicación nativa para iOS que permite buscar productos del catálogo de Walmart utilizando la API proporcionada mediante RapidAPI.

## Tecnologías

- Swift 6+
- UIKit
- UICollectionView
- Alamofire
- MVVM
- async/await
- UserDefaults
- iOS 16+

## Funcionalidades

- Búsqueda de productos por palabra clave.
- Consulta de productos mediante la API proporcionada.
- Visualización de:
  - Imagen del producto.
  - Título.
  - Precio.
- Paginación automática al realizar scroll.
- Historial de búsquedas.
- Persistencia del historial después de cerrar y volver a abrir la aplicación.
- Manejo de estados de carga y errores.
- La interfaz permanece disponible mientras se realizan las peticiones de red.

## Arquitectura

El proyecto utiliza una arquitectura basada en MVVM, separando la presentación, lógica de negocio, acceso a datos y comunicación con la API.

```text
SearchViewController
        ↓
SearchViewModel
        ↓
ProductRepository
        ↓
APIClient
        ↓
Alamofire
        ↓
RapidAPI
